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

    __memory_phys=$(free -m | awk '/^Mem:/{print $2}')
    __memory_total=$(free -m -t | awk '/^Total:/{print $2}')

    __has_binaries=0

    get_platform
    get_os_version
    get_retropie_depends

    __gcc_version=$(gcc -dumpversion)

    # workaround for GCC ABI incompatibility with threaded armv7+ C++ apps built
    # on Raspbian's armv6 userland https://github.com/raspberrypi/firmware/issues/491
    if [[ "$__os_id" == "Raspbian" ]] && compareVersions $__gcc_version lt 5.0.0; then
        __default_cxxflags+=" -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2"
    fi

    # set location of binary downloads
    __binary_host="files.retropie.org.uk"
    [[ "$__has_binaries" -eq 1 ]] && __binary_url="https://$__binary_host/binaries/$__os_codename/$__platform"

    __archive_url="https://files.retropie.org.uk/archives"

    # -pipe is faster but will use more memory - so let's only add it if we have more thans 256M free ram.
    [[ $__memory_phys -ge 512 ]] && __default_cflags+=" -pipe"

    [[ -z "${CFLAGS}" ]] && export CFLAGS="${__default_cflags}"
    [[ -z "${CXXFLAGS}" ]] && export CXXFLAGS="${__default_cxxflags}"
    [[ -z "${ASFLAGS}" ]] && export ASFLAGS="${__default_asflags}"
    [[ -z "${MAKEFLAGS}" ]] && export MAKEFLAGS="${__default_makeflags}"

    # test if we are in a chroot
    if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
        [[ -z "$QEMU_CPU" && -n "$__qemu_cpu" ]] && export QEMU_CPU=$__qemu_cpu
        __chroot=1
    else
        __chroot=0
    fi

    if [[ -z "$__nodialog" ]]; then
        __nodialog=0
    fi
}

function get_os_version() {
    # make sure lsb_release is installed
    getDepends lsb-release

    # get os distributor id, description, release number and codename
    local os
    mapfile -t os < <(lsb_release -sidrc)
    __os_id="${os[0]}"
    __os_desc="${os[1]}"
    __os_release="${os[2]}"
    __os_codename="${os[3]}"
    
    local error=""
    case "$__os_id" in
        Raspbian|Debian)
            if compareVersions "$__os_release" lt 8; then
                error="You need Raspbian/Debian Jessie or newer"
            fi

            # set a platform flag for osmc
            if grep -q "ID=osmc" /etc/os-release; then
                __platform_flags+=" osmc"
            fi

            # and for xbian
            if grep -q "NAME=XBian" /etc/os-release; then
                __platform_flags+=" xbian"
            fi

            # we provide binaries for RPI on Raspbian < 10 only
            if isPlatform "rpi" && compareVersions "$__os_release" lt 10; then
                __has_binaries=1
            fi

            # get major version (8 instead of 8.0 etc)
            __os_debian_ver="${__os_release%%.*}"
            ;;
        Devuan)
            # devuan lsb-release version numbers don't match jessie
            case "$__os_codename" in
                jessie)
                    __os_debian_ver="8"
                    ;;
            esac
            ;;
        LinuxMint)
            if [[ "$__os_desc" != LMDE* ]]; then
                if compareVersions "$__os_release" lt 17; then
                    error="You need Linux Mint 17 or newer"
                elif compareVersions "$__os_release" lt 18; then
                    __os_ubuntu_ver="14.04"
                else
                    __os_ubuntu_ver="16.04"
                fi
            fi
            __os_debian_ver="8"
            ;;
        Ubuntu)
            if compareVersions "$__os_release" lt 14.04; then
                error="You need Ubuntu 14.04 or newer"
            elif compareVersions "$__os_release" lt 16.10; then
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
            if compareVersions "$__os_release" lt 0.3; then
                error="You need Elementary OS 0.3 or newer"
            elif compareVersions "$__os_release" lt 0.4; then
                __os_ubuntu_ver="14.04"
            else
                __os_ubuntu_ver="16.04"
            fi
            __os_debian_ver="8"
            ;;
        neon)
             __os_ubuntu_ver="$__os_release"
            ;;
        *)
            error="Unsupported OS"
            ;;
    esac
    
    [[ -n "$error" ]] && fatalError "$error\n\n$(lsb_release -idrc)"

    # add 32bit/64bit to platform flags
    __platform_flags+=" $(getconf LONG_BIT)bit"

    # configure Raspberry Pi graphics stack
    isPlatform "rpi" && get_rpi_video
}

function get_retropie_depends() {
    local depends=(git dialog wget gcc g++ build-essential unzip xmlstarlet python-pyudev)

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

    # detect driver via inserted module / platform driver setup
    if [[ -d "/sys/module/vc4" ]]; then
        __platform_flags+=" mesa kms"
        [[ "$(ls -A /sys/bus/platform/drivers/vc4_firmware_kms/*.firmwarekms 2>/dev/null)" ]] && __platform_flags+=" dispmanx"
    else
        __platform_flags+=" videocore dispmanx"
    fi

    # use our supplied fallback pkgconfig if necessary
    [[ ! -d "$pkgconfig" ]] && pkgconfig="$scriptdir/pkgconfig"

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
            *)
                case $architecture in
                    i686|x86_64|amd64)
                        __platform="x86"
                        ;;
                esac
                ;;
        esac
    fi

    if ! fnExists "platform_${__platform}"; then
        fatalError "Unknown platform - please manually set the __platform variable to one of the following: $(compgen -A function platform_ | cut -b10- | paste -s -d' ')"
    fi

    platform_${__platform}
    [[ -z "$__default_cxxflags" ]] && __default_cxxflags="$__default_cflags"
}

function platform_rpi1() {
    # values to be used for configure/make
    __default_cflags="-O2 -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags=""
    __platform_flags="arm armv6 rpi gles"
    # if building in a chroot, what cpu should be set by qemu
    # make chroot identify as arm6l
    __qemu_cpu=arm1176
}

function platform_rpi2() {
    __default_cflags="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv7 neon rpi gles"
    __qemu_cpu=cortex-a7
}

# note the rpi3 currently uses the rpi2 binaries - for ease of maintenance - rebuilding from source
# could improve performance with the compiler options below but needs further testing
function platform_rpi3() {
    __default_cflags="-O2 -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv8 neon rpi gles"
}

function platform_odroid-c1() {
    __default_cflags="-O2 -mcpu=cortex-a5 -mfpu=neon-vfpv4 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv7 neon mali gles"
    __qemu_cpu=cortex-a9
}

function platform_odroid-c2() {
    if [[ "$(getconf LONG_BIT)" -eq 32 ]]; then
        __default_cflags="-O2 -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8"
        __platform_flags="arm armv8 neon mali gles"
    else
        __default_cflags="-O2 -march=native"
        __platform_flags="aarch64 mali"
    fi
    __default_cflags+=" -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
}

function platform_odroid-xu() {
    __default_cflags="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    # required for mali-fbdev headers to define GL functions
    __default_cflags+=" -DGL_GLEXT_PROTOTYPES"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv7 neon mali gles"
}

function platform_tinker() {
    __default_cflags="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    # required for mali headers to define GL functions
    __default_cflags+=" -DGL_GLEXT_PROTOTYPES"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv7 neon kms gles"
}

function platform_x86() {
    __default_cflags="-O2 -march=native"
    __default_asflags=""
    __default_makeflags="-j$(nproc)"
    __platform_flags="x11 gl"
}

function platform_generic-x11() {
    __default_cflags="-O2"
    __default_asflags=""
    __default_makeflags="-j$(nproc)"
    __platform_flags="x11 gl"
}

function platform_armv7-mali() {
    __default_cflags="-O2 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j$(nproc)"
    __platform_flags="arm armv7 neon mali gles"
}

function platform_imx6() {
    __default_cflags="-O2 -march=armv7-a -mfpu=neon -mtune=cortex-a9 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv7 neon"
}
