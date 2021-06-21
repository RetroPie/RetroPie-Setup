#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function setup_env() {

    __ERRMSGS=()
    __INFMSGS=()

    # if no apt-get we need to fail
    [[ -z "$(which apt-get)" ]] && fatalError "Unsupported OS - No apt-get command found"

    test_chroot

    get_platform
    get_os_version

    get_retropie_depends

    conf_memory_vars
    conf_binary_vars
    conf_build_vars

    if [[ -z "$__nodialog" ]]; then
        __nodialog=0
    fi
}

function test_chroot() {
    # test if we are in a chroot
    if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
        [[ -z "$QEMU_CPU" && -n "$__qemu_cpu" ]] && export QEMU_CPU=$__qemu_cpu
        __chroot=1
    # detect the usage of systemd-nspawn
    elif [[ -n "$(systemd-detect-virt)" && "$(systemd-detect-virt)" == "systemd-nspawn" ]]; then
        __chroot=1
    else
        __chroot=0
    fi
}


function conf_memory_vars() {
    __memory_total_kb=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
    __memory_total=$(( __memory_total_kb / 1024 ))
    if grep -q "^MemAvailable:" /proc/meminfo; then
        __memory_avail_kb=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    else
        local mem_free=$(awk '/^MemFree:/{print $2}' /proc/meminfo)
        local mem_cached=$(awk '/^Cached:/{print $2}' /proc/meminfo)
        local mem_buffers=$(awk '/^Buffers:/{print $2}' /proc/meminfo)
        __memory_avail_kb=$((mem_free + mem_cached + mem_buffers))
    fi
    __memory_avail=$(( __memory_avail_kb / 1024 ))
}

function conf_binary_vars() {
    [[ -z "$__has_binaries" ]] && __has_binaries=0

    # set location of binary downloads
    __binary_host="files.retropie.org.uk"
    __binary_base_url="https://$__binary_host/binaries"

    __binary_path="$__os_codename/$__platform"
    isPlatform "kms" && __binary_path+="/kms"
    __binary_url="$__binary_base_url/$__binary_path"

    __archive_url="https://files.retropie.org.uk/archives"

    # set the gpg key used by RetroPie
    __gpg_retropie_key="retropieproject@gmail.com"

    # if __gpg_signing_key is not set, set to __gpg_retropie_key
    [[ ! -v __gpg_signing_key ]] && __gpg_signing_key="$__gpg_retropie_key"

    # if the RetroPie public key is not installed, install it.
    if ! gpg --list-keys "$__gpg_retropie_key" &>/dev/null; then
        gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys DC9D77FF8208FFC51D8F50CCF1B030906A3B0D31
    fi
}

function conf_build_vars() {
    __gcc_version=$(gcc -dumpversion)

    # calculate build concurrency based on cores and available memory
    __jobs=1
    local unit=512
    isPlatform "64bit" && unit=$(($unit + 256))
    if [[ "$(nproc)" -gt 1 ]]; then
        local nproc="$(nproc)"
        # max one thread per unit (MB) of ram
        local max_jobs=$(($__memory_avail / $unit))
        if [[ "$max_jobs" -gt 0 ]]; then
            if [[ "$max_jobs" -lt "$nproc" ]]; then
                __jobs="$max_jobs"
            else
                __jobs="$nproc"
            fi
        fi
    fi
    __default_makeflags="-j${__jobs}"

    # set our default gcc optimisation level
    if [[ -z "$__opt_flags" ]]; then
        __opt_flags="$__default_opt_flags"
    fi

    # set default cpu flags
    [[ -z "$__cpu_flags" ]] && __cpu_flags="$__default_cpu_flags"

    # if default cxxflags is empty, use our default cflags
    [[ -z "$__default_cxxflags" ]] && __default_cxxflags="$__default_cflags"

    # add our cpu and optimisation flags
    __default_cflags+=" $__cpu_flags $__opt_flags"
    __default_cxxflags+=" $__cpu_flags $__opt_flags"

    # if not overridden by user, configure our compiler flags
    [[ -z "$__cflags" ]] && __cflags="$__default_cflags"
    [[ -z "$__cxxflags" ]] && __cxxflags="$__default_cxxflags"
    [[ -z "$__asflags" ]] && __asflags="$__default_asflags"
    [[ -z "$__makeflags" ]] && __makeflags="$__default_makeflags"

    # workaround for GCC ABI incompatibility with threaded armv7+ C++ apps built
    # on Raspbian's armv6 userland https://github.com/raspberrypi/firmware/issues/491
    if [[ "$__os_id" == "Raspbian" ]] && compareVersions $__gcc_version lt 5; then
        __cxxflags+=" -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2"
    fi

    # export our compiler flags so all child processes can see them
    export CFLAGS="$__cflags"
    export CXXFLAGS="$__cxxflags"
    export ASFLAGS="$__asflags"
    export MAKEFLAGS="$__makeflags"

    # if using distcc, add /usr/lib/distcc to PATH/MAKEFLAGS
    if [[ -n "$DISTCC_HOSTS" ]]; then
        PATH="/usr/lib/distcc:$PATH"
        MAKEFLAGS+=" PATH=$PATH"
    fi
}

function get_os_version() {
    # make sure lsb_release is installed
    getDepends lsb-release

    # get os distributor id, description, release number and codename
    local os
    # armbian uses a minimal shell script replacement for lsb_release with basic
    # parameter parsing that requires the arguments split rather than using -sidrc
    mapfile -t os < <(lsb_release -s -i -d -r -c)
    __os_id="${os[0]}"
    __os_desc="${os[1]}"
    __os_release="${os[2]}"
    __os_codename="${os[3]}"

    local error=""
    case "$__os_id" in
        Raspbian|Debian)
            # get major version (8 instead of 8.0 etc)
            __os_debian_ver="${__os_release%%.*}"

            # Debian unstable is not officially supported though
            if [[ "$__os_release" == "unstable" ]]; then
                __os_debian_ver=11
            fi

            # we still allow Raspbian 8 (jessie) to work (We show an popup in the setup module)
            if compareVersions "$__os_debian_ver" lt 8; then
                error="You need Raspbian/Debian Stretch or newer"
            fi

            # 64bit Raspberry Pi OS identifies as Debian, but functions (currently) as Raspbian
            # we will check package sources and set to Raspbian
            if isPlatform "aarch64" && apt-cache policy | grep -q "archive.raspberrypi.org"; then
                __os_id="Raspbian"
            fi

            # set a platform flag for osmc
            if grep -q "ID=osmc" /etc/os-release; then
                __platform_flags+=(osmc)
            fi

            # and for xbian
            if grep -q "NAME=XBian" /etc/os-release; then
                __platform_flags+=(xbian)
            fi

            # we provide binaries for RPI on Raspbian 9/10
            if isPlatform "rpi" && \
               isPlatform "32bit" && \
               compareVersions "$__os_debian_ver" gt 9 && compareVersions "$__os_debian_ver" lt 11; then
               # only set __has_binaries if not already set
               [[ -z "$__has_binaries" ]] && __has_binaries=1
            fi
            ;;
        Devuan)
            if isPlatform "rpi"; then
                error="We do not support Devuan on the Raspberry Pi. We recommend you use Raspbian to run RetroPie."
            fi
            # devuan lsb-release version numbers don't match jessie
            case "$__os_codename" in
                jessie)
                    __os_debian_ver="8"
                    ;;
                ascii)
                    __os_debian_ver="9"
                    ;;
                beowolf)
                    __os_debian_ver="10"
                    ;;
                ceres)
                    __os_debian_ver="11"
                    ;;
            esac
            ;;
        LinuxMint|Linuxmint)
            if [[ "$__os_desc" != LMDE* ]]; then
                if compareVersions "$__os_release" lt 18; then
                    error="You need Linux Mint 18 or newer"
                elif compareVersions "$__os_release" lt 19; then
                    __os_ubuntu_ver="16.04"
                    __os_debian_ver="8"
                elif compareVersions "$__os_release" lt 20; then
                    __os_ubuntu_ver="18.04"
                    __os_debian_ver="10"
                else
                    __os_ubuntu_ver="20.04"
                    __os_debian_ver="11"
                fi
            fi
            ;;
        Ubuntu|[Nn]eon|Pop)
            if compareVersions "$__os_release" lt 16.04; then
                error="You need Ubuntu 16.04 or newer"
            # although ubuntu 16.04/16.10 report as being based on stretch it is before some
            # packages were changed - we map to version 8 to avoid issues (eg libpng-dev name)
            elif compareVersions "$__os_release" le 16.10; then
                __os_debian_ver="8"
            elif compareVersions "$__os_release" lt 18.04; then
                __os_debian_ver="9"
            elif compareVersions "$__os_release" lt 20.04; then
                __os_debian_ver="10"
            else
                __os_debian_ver="11"
            fi
            __os_ubuntu_ver="$__os_release"
            ;;
        Zorin)
            if compareVersions "$__os_release" lt 14; then
                error="You need Zorin OS 14 or newer"
            elif compareVersions "$__os_release" lt 14; then
                __os_debian_ver="8"
            else
                __os_debian_ver="9"
            fi
            __os_ubuntu_ver="$__os_release"
            ;;
        Deepin)
            if compareVersions "$__os_release" lt 15.5; then
                error="You need Deepin OS 15.5 or newer"
            fi
            __os_debian_ver="9"
            ;;
        elementary)
            if compareVersions "$__os_release" lt 0.4; then
                error="You need Elementary OS 0.4 or newer"
            elif compareVersions "$__os_release" eq 0.4; then
                __os_ubuntu_ver="16.04"
                __os_debian_ver="8"
            else
                __os_ubuntu_ver="18.04"
                __os_debian_ver="10"
            fi
            ;;
        *)
            error="Unsupported OS"
            ;;
    esac

    [[ -n "$error" ]] && fatalError "$error\n\n$(lsb_release -idrc)"

    # configure Raspberry Pi graphics stack
    isPlatform "rpi" && get_rpi_video
}

function get_retropie_depends() {
    local depends=(git subversion dialog curl gcc g++ build-essential unzip xmlstarlet python3-pyudev ca-certificates dirmngr)

    [[ -n "$DISTCC_HOSTS" ]] && depends+=(distcc)

    if ! getDepends "${depends[@]}"; then
        fatalError "Unable to install packages required by $0 - ${md_ret_errors[@]}"
    fi

    # make sure we don't have xserver-xorg-legacy installed as it breaks launching x11 apps from ES
    if ! isPlatform "x11" && hasPackage "xserver-xorg-legacy"; then
        aptRemove xserver-xorg-legacy
    fi
}

function get_rpi_video() {
    local pkgconfig="/opt/vc/lib/pkgconfig"

    if [[ -z "$__has_kms" ]]; then
        # in chroot, use kms by default for rpi4 target
        [[ "$__chroot" -eq 1 ]] && isPlatform "rpi4" && __has_kms=1
        # detect driver via inserted module / platform driver setup
        [[ -d "/sys/module/vc4" ]] && __has_kms=1
    fi

    if [[ "$__has_kms" -eq 1 ]]; then
        __platform_flags+=(mesa kms)
        if [[ -z "$__has_dispmanx" ]]; then
            # in a chroot, unless __has_dispmanx is set, default to fkms (adding dispmanx flag)
            [[ "$__chroot" -eq 1 ]] && __has_dispmanx=1
            # if running fkms driver, add dispmanx flag
            [[ "$(ls -A /sys/bus/platform/drivers/vc4_firmware_kms/*.firmwarekms 2>/dev/null)" ]] && __has_dispmanx=1
        fi
        [[ "$__has_dispmanx" -eq 1 ]] && __platform_flags+=(dispmanx)
    else
        __platform_flags+=(videocore dispmanx)
    fi

    # delete legacy pkgconfig that conflicts with Mesa (may be installed via rpi-update)
    # see: https://github.com/raspberrypi/userland/pull/585
    rm -rf $pkgconfig/{egl.pc,glesv2.pc,vg.pc}

    # set pkgconfig path for vendor libraries
    export PKG_CONFIG_PATH="$pkgconfig"
}

function get_platform() {
    local architecture="$(uname --machine)"
    if [[ -z "$__platform" ]]; then
        case "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" in
            BCM*)
                # calculated based on information from https://github.com/AndrewFromMelbourne/raspberry_pi_revision
                local rev="0x$(sed -n '/^Revision/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)"
                # if bit 23 is not set, we are on a rpi1 (bit 23 means the revision is a bitfield)
                if [[ $((($rev >> 23) & 1)) -eq 0 ]]; then
                    __platform="rpi1"
                else
                    # if bit 23 is set, get the cpu from bits 12-15
                    local cpu=$((($rev >> 12) & 15))
                    case $cpu in
                        0)
                            __platform="rpi1"
                            ;;
                        1)
                            __platform="rpi2"
                            ;;
                        2)
                            __platform="rpi3"
                            ;;
                        3)
                            __platform="rpi4"
                            ;;
                    esac
                fi
                ;;
            ODROIDC)
                __platform="odroid-c1"
                ;;
            ODROID-C2)
                __platform="odroid-c2"
                ;;
            "Freescale i.MX6 Quad/DualLite (Device Tree)")
                __platform="imx6"
                ;;
            ODROID-XU[34])
                __platform="odroid-xu"
                ;;
            "Rockchip (Device Tree)")
                __platform="tinker"
                ;;
            Vero4K|Vero4KPlus)
                __platform="vero4k"
                ;;
            "Allwinner sun8i Family")
                __platform="armv7-mali"
                ;;
            *)
                # jetson nano and tegra x1 can be identified via /sys/firmware/devicetree/base/model
                local model_path="/sys/firmware/devicetree/base/model"
                if [[ -f "$model_path" ]]; then
                    # ignore end null to avoid bash warning
                    local model=$(tr -d '\0' <$model_path)
                    case "$model" in
                        "NVIDIA Jetson Nano Developer Kit")
                            __platform="jetson-nano"
                            ;;
                        icosa|icosa_emmc)
                            __platform="tegra-x1"
                            ;;
                    esac
                else
                    case $architecture in
                        i686|x86_64|amd64)
                            __platform="x86"
                            ;;
                    esac
                fi
                ;;
        esac
    fi

    if ! fnExists "platform_${__platform}"; then
        fatalError "Unknown platform - please manually set the __platform variable to one of the following: $(compgen -A function platform_ | cut -b10- | paste -s -d' ')"
    fi

    # check if we wish to target kms for platform
    if [[ -z "$__has_kms" ]]; then
        iniConfig " = " '"' "$configdir/all/retropie.cfg"
        iniGet "force_kms"
        [[ "$ini_value" == 1 ]] && __has_kms=1
        [[ "$ini_value" == 0 ]] && __has_kms=0
    fi

    set_platform_defaults
    platform_${__platform}
}

function set_platform_defaults() {
    __default_opt_flags="-O2"

    # add platform name and 32bit/64bit to platform flags
    __platform_flags=("$__platform" "$(getconf LONG_BIT)bit")
    __platform_arch=$(uname -m)
}

function cpu_arm1176() {
    __default_cpu_flags="-mcpu=arm1176jzf-s -mfpu=vfp"
    __platform_flags+=(arm armv6)
    __qemu_cpu=arm1176
}

function cpu_armv7() {
    local cpu="$1"
    if [[ -n "$cpu" ]]; then
        __default_cpu_flags="-mcpu=$cpu -mfpu=neon-vfpv4"
    else
        __default_cpu_flags="-march=armv7-a -mfpu=neon-vfpv4"
        cpu="cortex-a7"
    fi
    __platform_flags+=(arm armv7 neon)
    __qemu_cpu="$cpu"
}

function cpu_armv8() {
    local cpu="$1"
    __default_cpu_flags="-mcpu=$cpu"
    if isPlatform "32bit"; then
        __default_cpu_flags+="  -mfpu=neon-fp-armv8"
        __platform_flags+=(arm armv8 neon)
    else
        __platform_flags+=(aarch64)
    fi
    __qemu_cpu="$cpu"
}

function cpu_arm_state() {
    if isPlatform "32bit"; then
        __default_cpu_flags+=" -marm"
    fi
}

function platform_conf_glext() {
   # required for mali-fbdev headers to define GL functions
    __default_cflags="-DGL_GLEXT_PROTOTYPES"
}

function platform_rpi1() {
    cpu_arm1176
    __platform_flags+=(rpi gles)
}

function platform_rpi2() {
    cpu_armv7 "cortex-a7"
    __platform_flags+=(rpi gles)
}

function platform_rpi3() {
    cpu_armv8 "cortex-a53"
    __platform_flags+=(rpi gles)
}

function platform_rpi4() {
    cpu_armv8 "cortex-a72"
    __platform_flags+=(rpi gles gles3 gles31)
}

function platform_odroid-c1() {
    cpu_armv7 "cortex-a5"
    cpu_arm_state
    __platform_flags+=(mali gles)
}

function platform_odroid-c2() {
    cpu_armv8 "cortex-a72"
    cpu_arm_state
    __platform_flags+=(mali gles)
}

function platform_odroid-xu() {
    cpu_armv7 "cortex-a7"
    cpu_arm_state
    platform_conf_glext
    __platform_flags+=(mali gles)
}

function platform_tegra-x1() {
    cpu_armv8 "cortex-a57"
    __platform_flags+=(x11 gl)
}

function platform_jetson-nano() {
    platform_tegra-x1
}

function platform_tinker() {
    cpu_armv7 "cortex-a17"
    cpu_arm_state
    platform_conf_glext
    __platform_flags+=(kms gles)
}

function platform_x86() {
    __default_cpu_flags="-march=native"
    __platform_flags+=(gl)
    if [[ "$__has_kms" -eq 1 ]]; then
        __platform_flags+=(kms)
    else
        __platform_flags+=(x11)
    fi
}

function platform_generic-x11() {
    __platform_flags+=(x11 gl)
}

function platform_armv7-mali() {
    cpu_armv7
    __platform_flags+=(mali gles)
}

function platform_imx6() {
    cpu_armv7 "cortex-a9"
}

function platform_vero4k() {
    cpu_armv7 "cortex-a7"
    __default_cflags="-I/opt/vero3/include -L/opt/vero3/lib"
    __platform_flags+=(mali gles)
}
