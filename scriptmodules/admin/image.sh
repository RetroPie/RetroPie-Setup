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
rp_module_flags="!arm"

function depends_image() {
    getDepends kpartx unzip qemu-user-static rsync parted squashfs-tools
}

function chroot_image() {
    mkdir -p "$md_build"
    pushd "$md_build"
    mkdir -p mnt/boot chroot
    local image=$(ls -1 *-raspbian-jessie-lite.img 2>/dev/null)
    if [[ ! -f "$image" ]]; then
        wget -c -O "raspbian_lite.zip" https://downloads.raspberrypi.org/raspbian_lite_latest
        unzip "raspbian_lite.zip"
        image=$(unzip -Z -1 "raspbian_lite.zip")
        rm "raspbian_lite.zip"
    fi

    # mount image
    kpartx -s -a "$image"

    mount /dev/mapper/loop0p2 mnt
    mount /dev/mapper/loop0p1 mnt/boot

    printMsgs "console" "Creating chroot"
    rsync -aAHX --numeric-ids --delete mnt/ chroot/

    umount -l mnt/boot mnt
    rm -rf mnt
    kpartx -d "$image"

    popd
}

function install_rp_image() {
    local platform="$1"
    [[ -z "$platform" ]] && return

    mkdir -p "$md_build"
    pushd "$md_build"

    # unmount on ctrl+c
    trap _umount_chroot INT

    # mount special filesytems to chroot
    mkdir -p chroot/dev/pts
    mount none -t devpts chroot/dev/pts
    mount -t proc /proc chroot/proc

    # required for emulated chroot
    cp "/usr/bin/qemu-arm-static" chroot/usr/bin/

    # so we can resolve inside the chroot
    echo "nameserver 192.168.1.1" >chroot/etc/resolv.conf

    # hostname to retropie
    echo "retropie" >chroot/etc/hostname
    sed -i "s/raspberrypi/retropie/" chroot/etc/hosts

    # quieter boot / disable plymouth (as without the splash parameter it
    # causes all boot messages to be displayed and interferes with people
    # using tty3 to make the boot even quieter)
    if ! grep -q consoleblank chroot/boot/cmdline.txt; then
        # extra quiet as the raspbian usr/lib/raspi-config/init_resize.sh does
        # sed -i 's/ quiet init=.*$//' /boot/cmdline.txt so this will remove the last quiet
        # and the init line but leave ours intact
        sed -i "s/quiet/quiet loglevel=3 consoleblank=0 plymouth.enable=0 quiet/" chroot/boot/cmdline.txt
    fi

    cat > chroot/home/pi/install.sh <<_EOF_
#!/bin/bash
cd
sudo apt-get update
sudo apt-get -y install git dialog xmlstarlet joystick
git clone https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
modules=(
    'raspbiantools apt_upgrade'
    'setup basic_install'
    'bluetooth depends'
    'raspbiantools enable_modules'
    'autostart enable'
    'usbromservice'
    'usbromservice enable'
    'samba depends'
    'samba install_shares'
    'splashscreen default'
    'splashscreen enable'
    'bashwelcometweak'
    'xpad'
)
for module in "\${modules[@]}"; do
    # rpi1 platform would use QEMU_CPU set to arm1176, but it seems buggy currently (lots of segfaults)
    sudo QEMU_CPU=cortex-a15 __platform=$platform __nodialog=1 ./retropie_packages.sh \$module
done
sudo apt-get clean
_EOF_

    # chroot and run install script
    HOME="/home/pi" chroot --userspec 1000:1000 chroot bash /home/pi/install.sh

    _umount_chroot

    >chroot/etc/resolv.conf
    rm chroot/home/pi/install.sh

    # remove any ssh host keys that may have been generated during any ssh package upgrades
    rm -f chroot/etc/ssh/ssh_host*

    popd
}

function _umount_chroot() {
    trap "" INT
    umount -l chroot/proc chroot/dev/pts
    trap INT
}

function create_image() {
    local image="$1"
    [[ -z "$image" ]] && return 1

    image+=".img"

    mkdir -p "$md_build"
    pushd "$md_build"

    # make image size 300mb larger than contents of chroot
    local mb_size=$(du -s --block-size 1048576 chroot 2>/dev/null | cut -f1)
    ((mb_size+=300))

    # create image
    printMsgs "console" "Creating image $image ..."
    dd if=/dev/zero of="$image" bs=1M count="$mb_size"

    # partition
    printMsgs "console" "partitioning $image ..."
    parted -s "$image" -- \
        mklabel msdos \
        mkpart primary fat16 4 64 \
        set 1 boot on \
        mkpart primary 64 -1

    # format
    printMsgs "console" "Formatting $image ..."
    kpartx -s -a "$image"

    mkfs.vfat -F 16 -n boot /dev/mapper/loop0p1
    mkfs.ext4 -O ^metadata_csum -L retropie /dev/mapper/loop0p2

    parted "$image" print

    # disable ctrl+c
    trap "" INT

    # mount
    printMsgs "console" "Mounting $image ..."
    mkdir -p mnt
    mount /dev/mapper/loop0p2 mnt
    mkdir -p mnt/boot
    mount /dev/mapper/loop0p1 mnt/boot

    # copy files
    printMsgs "console" "Rsyncing chroot to $image ..."
    rsync -aAHX --numeric-ids  chroot/ mnt/

    # unmount
    umount -l mnt/boot mnt
    rm -rf mnt
    kpartx -d "$image"

    trap INT

    printMsgs "console" "Compressing $image ..."
    gzip -f "$image"

    popd
}

# generate berryboot squashfs from filesystem
function create_bb_image() {
    local image="$1"
    [[ -z "$image" ]] && return 1

    image+="-berryboot.img256"

    mkdir -p "$md_build"
    pushd "$md_build"

    # replace fstab
    echo "proc            /proc           proc    defaults          0       0" >chroot/etc/fstab
    # remove any earlier image
    rm -f "$image"

    mksquashfs chroot "$image" -comp lzo -e boot -e lib/modules

    popd
}

function all_image() {
    local platform
    local image
    for platform in rpi1 rpi2; do
        platform_image "$platform"
    done
}

function platform_image() {
    local platform="$1"
    [[ -z "$platform" ]] && exit

    local image
    if [[ "$platform" == "rpi1" ]]; then
        image="retropie-${__version}-rpi1_zero"
    else
        image="retropie-${__version}-rpi2_rpi3"
    fi

    rp_callModule image chroot
    rp_callModule image install_rp "$platform"
    rp_callModule image create "$image"
    rp_callModule image create_bb "$image"
}
