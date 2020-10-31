#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="image"
rp_module_desc="Create/Manage RetroPie images"
rp_module_section=""
rp_module_flags=""

function depends_image() {
    local depends=(kpartx unzip binfmt-support rsync parted squashfs-tools dosfstools e2fsprogs)
    isPlatform "x86" && depends+=(qemu-user-static)
    getDepends "${depends[@]}"
}

function create_chroot_image() {
    local dist="$1"
    [[ -z "$dist" ]] && dist="stretch"

    local chroot="$2"
    [[ -z "$chroot" ]] && chroot="$md_build/chroot"

    mkdir -p "$md_build"
    pushd "$md_build"

    mkdir -p "$chroot"

    local url
    local image
    case "$dist" in
        jessie)
            url="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/2017-07-05-raspbian-jessie-lite.zip"
            ;;
        stretch)
            url="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip"
            ;;
        buster)
            url="https://downloads.raspberrypi.org/raspios_lite_armhf_latest"
            ;;
        *)
            md_ret_errors+=("Unknown/unsupported Raspbian version")
            return 1
            ;;
    esac

    local base="raspbian-${dist}-lite"
    local image="$base.img"
    if [[ ! -f "$image" ]]; then
        wget -c -O "$base.zip" "$url"
        unzip -o "$base.zip"
        mv "$(unzip -Z -1 "$base.zip")" "$image"
        rm "$base.zip"
    fi

    # mount image
    local partitions=($(kpartx -s -a -v "$image" | awk '{ print "/dev/mapper/"$3 }'))
    local part_boot="${partitions[0]}"
    local part_root="${partitions[1]}"

    local tmp="$(mktemp -d -p "$md_build")"
    mkdir -p "$tmp/boot"

    mount "$part_root" "$tmp"
    mount "$part_boot" "$tmp/boot"

    printMsgs "console" "Creating chroot from $image ..."
    rsync -aAHX --numeric-ids --delete "$tmp/" "$chroot/"

    umount -l "$tmp/boot" "$tmp"
    rm -rf "$tmp"

    kpartx -d "$image"

    popd
}

function install_rp_image() {
    local platform="$1"
    [[ -z "$platform" ]] && return

    local chroot="$2"
    [[ -z "$chroot" ]] && chroot="$md_build/chroot"

    # hostname to retropie
    echo "retropie" >"$chroot/etc/hostname"
    sed -i "s/raspberrypi/retropie/" "$chroot/etc/hosts"

    # quieter boot / disable plymouth (as without the splash parameter it
    # causes all boot messages to be displayed and interferes with people
    # using tty3 to make the boot even quieter)
    if ! grep -q consoleblank "$chroot/boot/cmdline.txt"; then
        # extra quiet as the raspbian usr/lib/raspi-config/init_resize.sh does
        # sed -i 's/ quiet init=.*$//' /boot/cmdline.txt so this will remove the last quiet
        # and the init line but leave ours intact
        sed -i "s/quiet/quiet loglevel=3 consoleblank=0 plymouth.enable=0 quiet/" "$chroot/boot/cmdline.txt"
    fi

    # set default GPU mem (videocore only) and overscan_scale so ES scales to overscan settings.
    iniConfig "=" "" "$chroot/boot/config.txt"
    if ! [[ "$platform" =~ rpi.*kms|rpi4 ]]; then
        iniSet "gpu_mem_256" 128
        iniSet "gpu_mem_512" 256
        iniSet "gpu_mem_1024" 256
    fi
    iniSet "overscan_scale" 1

    [[ -z "$__chroot_branch" ]] && __chroot_branch="master"
    cat > "$chroot/home/pi/install.sh" <<_EOF_
#!/bin/bash
cd
sudo apt-get update
sudo apt-get -y install git dialog xmlstarlet joystick
git clone -b "$__chroot_branch" https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
modules=(
    'raspbiantools apt_upgrade'
    'setup basic_install'
    'bluetooth depends'
    'raspbiantools enable_modules'
    'autostart enable'
    'usbromservice'
    'samba depends'
    'samba install_shares'
    'splashscreen default'
    'splashscreen enable'
    'bashwelcometweak'
    'xpad'
)
for module in "\${modules[@]}"; do
    sudo __platform=$platform __nodialog=1 __has_binaries=$__chroot_has_binaries ./retropie_packages.sh \$module
done

sudo rm -rf tmp
sudo apt-get clean
_EOF_

    # chroot and run install script
    rp_callModule image chroot "$chroot" bash /home/pi/install.sh

    rm "$chroot/home/pi/install.sh"

    # remove any ssh host keys that may have been generated during any ssh package upgrades
    rm -f "$chroot/etc/ssh/ssh_host"*
}

function _init_chroot_image() {
    # unmount on ctrl+c
    trap "_trap_chroot_image '$chroot'" INT

    # mount special filesytems to chroot
    mkdir -p "$chroot"/dev/pts
    mount none -t devpts "$chroot/dev/pts"
    mount -t proc /proc "$chroot/proc"

    # required for emulated chroot
    isPlatform "x86" && cp "/usr/bin/qemu-arm-static" "$chroot/usr/bin/"

    local nameserver="$__nameserver"
    [[ -z "$nameserver" ]] && nameserver="$(nmcli device show | grep IP4.DNS | awk '{print $NF; exit}')"
    # so we can resolve inside the chroot
    echo "nameserver $nameserver" >"$chroot/etc/resolv.conf"

    # move /etc/ld.so.preload out of the way to avoid warnings
    mv "$chroot/etc/ld.so.preload" "$chroot/etc/ld.so.preload.bak"
}

function _deinit_chroot_image() {
    local chroot="$1"
    [[ -z "$chroot" ]] && chroot="$md_build/chroot"

    trap "" INT

    >"$chroot/etc/resolv.conf"

    isPlatform "x86" && rm -f "$chroot/usr/bin/qemu-arm-static"

    # restore /etc/ld.so.preload
    mv "$chroot/etc/ld.so.preload.bak" "$chroot/etc/ld.so.preload"

    umount -l "$chroot/proc" "$chroot/dev/pts"
    trap INT
}

function _trap_chroot_image() {
    _deinit_chroot_image "$1"
    exit
}

function chroot_image() {
    local chroot="$1"
    [[ -z "$chroot" ]] && chroot="$md_build/chroot"
    shift

    printMsgs "console" "Chrooting to $chroot ..."
    _init_chroot_image "$chroot"
    HOME="/home/pi" chroot --userspec 1000:1000 "$chroot" "$@"
    _deinit_chroot_image "$chroot"
}

function create_image() {
    local image="$1"
    [[ -z "$image" ]] && return 1

    local chroot="$2"
    [[ -z "$chroot" ]] && chroot="$md_build/chroot"

    image+=".img"

    # make image size 300mb larger than contents of chroot
    local mb_size=$(du -s --block-size 1048576 "$chroot" 2>/dev/null | cut -f1)
    ((mb_size+=492))

    # create image
    printMsgs "console" "Creating image $image ..."
    dd if=/dev/zero of="$image" bs=1M count="$mb_size"

    # partition
    printMsgs "console" "partitioning $image ..."
    parted -s "$image" -- \
        mklabel msdos \
        unit mib \
        mkpart primary fat16 4 260 \
        set 1 boot on \
        mkpart primary 260 -1s

    # format
    printMsgs "console" "Formatting $image ..."

    # change to the image folder as kpartx has problems removing the
    # device mapper files when using a full path to the image
    local image_path="${image%/*}"
    local image_name="${image##*/}"
    pushd "$image_path"

    local partitions=($(kpartx -s -a -v "$image_name" | awk '{ print "/dev/mapper/"$3 }'))
    local part_boot="${partitions[0]}"
    local part_root="${partitions[1]}"

    mkfs.vfat -F 16 -n boot "$part_boot"
    mkfs.ext4 -O ^metadata_csum,^huge_file -L retropie "$part_root"

    parted "$image_name" print

    # disable ctrl+c
    trap "" INT

    # mount
    printMsgs "console" "Mounting $image_name ..."
    local tmp="$(mktemp -d -p "$md_build")"
    mount "$part_root" "$tmp"
    mkdir -p "$tmp/boot"
    mount "$part_boot" "$tmp/boot"

    # copy files
    printMsgs "console" "Rsyncing chroot to $image_name ..."
    rsync -aAHX --numeric-ids "$chroot/" "$tmp/"

    # we need to fix up the UUIDS for /boot/cmdline.txt and /etc/fstab
    local old_id="$(sed "s/.*PARTUUID=\([^-]*\).*/\1/" $tmp/boot/cmdline.txt)"
    local new_id="$(blkid -s PARTUUID -o value "$part_root" | cut -c -8)"
    sed -i "s/$old_id/$new_id/" "$tmp/boot/cmdline.txt"
    sed -i "s/$old_id/$new_id/g" "$tmp/etc/fstab"

    # unmount
    umount -l "$tmp/boot" "$tmp"
    rm -rf "$tmp"

    kpartx -d "$image_name"

    trap INT

    printMsgs "console" "Compressing $image ..."
    gzip -f "$image"
}

# generate berryboot squashfs from filesystem
function create_bb_image() {
    local image="$1"
    [[ -z "$image" ]] && return 1

    local chroot="$2"
    [[ -z "$chroot" ]] && chroot="$md_build/chroot"

    image+="-berryboot.img256"

    # replace fstab
    echo "proc            /proc           proc    defaults          0       0" >"$chroot/etc/fstab"

    # remove any earlier image
    rm -f "$image"

    mksquashfs "$chroot" "$image" -comp lzo -e boot -e lib/modules
}

function all_image() {
    local platform
    local image
    local dist="$1"
    local make_bb="$2"
    for platform in rpi1 rpi2 rpi4; do
        platform_image "$platform" "$dist" "$make_bb"
    done
}

function platform_image() {
    local platform="$1"
    local dist="$2"
    local make_bb="$3"
    [[ -z "$platform" ]] && return 1

    if [[ "$dist" == "stretch" && "$platform" == "rpi4" ]]; then
        printMsgs "console" "Platform $platform on $dist is unsupported."
        return 1
    fi

    local dest="$__tmpdir/images"
    mkdir -p "$dest"

    local image="$dest/retropie-${dist}-${__version}-"
    case "$platform" in
        rpi1)
            image+="rpi1_zero"
            ;;
        rpi2)
            image+="rpi2_rpi3"
            ;;
        rpi3|rpi4)
            image+="$platform"
            ;;
        *)
            fatalError "Unknown platform $platform for image building"
            ;;
    esac

    rp_callModule image create_chroot "$dist"
    rp_callModule image install_rp "$platform"
    rp_callModule image create "$image"
    [[ "$make_bb" -eq 1 ]] && rp_callModule image create_bb "$image"
}
