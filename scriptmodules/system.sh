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

    __memory_phys=$(free -m | awk '/^Mem:/{print $2}')
    __memory_total=$(free -m -t | awk '/^Total:/{print $2}')

    if [[ -z "$__platform" ]]; then
        case $(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo) in
            BCM2708)
                __platform="rpi1"
                ;;
            BCM2709)
                __platform="rpi2"
                ;;
        esac
    fi

    if fn_exists "platform_${__platform}"; then
        platform_${__platform}
    else
        fatalError "Unknown platform - please manually set the __platform variable to rpi1 or rpi2"
    fi

    get_os_version
    get_default_gcc
    get_retropie_depends

    # set default gcc version
    set_default_gcc "$__default_gcc_version"

    # set location of binary downloads
    [[ "$__has_binaries" -eq 1 ]] && __binary_url="http://downloads.petrockblock.com/retropiebinaries/$__raspbian_name/$__platform"

    __archive_url="http://downloads.petrockblock.com/retropiearchives"

    # -pipe is faster but will use more memory - so let's only add it if we have more thans 256M free ram.
    [[ $__memory_phys -ge 256 ]] && __default_cflags+=" -pipe"

    [[ -z "${CFLAGS}" ]] && export CFLAGS="${__default_cflags}"
    [[ -z "${CXXFLAGS}" ]] && export CXXFLAGS="${__default_cflags}"
    [[ -z "${ASFLAGS}" ]] && export ASFLAGS="${__default_asflags}"
    [[ -z "${MAKEFLAGS}" ]] && export MAKEFLAGS="${__default_makeflags}"

    # test if we are in a chroot
    if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
        [[ -n "$__qemu_cpu" ]] && export QEMU_CPU=$__qemu_cpu
        __chroot=1
    else
        __chroot=0
    fi

    if [[ -z "$__nodialog" ]]; then
        __nodialog=0
    fi
}

function get_os_version() {
    if [[ -f /etc/debian_version ]]; then
        local ver=$(</etc/debian_version)
        # check for debian major.minor version
        if [[ "$ver" =~ [0-9]+\.[0-9]+ ]]; then
            ver=(${ver/./ })
            local ver_maj=${ver[0]}
            local ver_min=${ver[1]}
            case $ver_maj in
                7)
                    __raspbian_ver=7
                    __raspbian_name="wheezy"
                    return
                    ;;
                8)
                    __raspbian_ver=8
                    __raspbian_name="jessie"
                    return
                    ;;
                *)
                    fatalError "Unsupported OS - /etc/debian_version $(cat /etc/debian_version)"
                    ;;
            esac
        fi
    else
        fatalError "Unsupported OS (no /etc/debian_version)"
    fi
}

function get_default_gcc() {
    case $__raspbian_ver in
        7)
            __default_gcc_version="4.7"
            ;;
        8)
            __default_gcc_version="4.9"
            ;;
        *)
            __default_gcc_version="4.7"
            ;;
    esac
}

# gcc version helper
function set_default() {
    if [[ -e "$1-$2" ]] ; then
        # echo $1-$2 is now the default
        ln -sf $1-$2 $1
    else
        echo $1-$2 is not installed
    fi
}

# sets default gcc version
function set_default_gcc() {
    pushd /usr/bin > /dev/null
    for i in gcc cpp g++ gcov; do
        set_default $i $1
    done
    popd > /dev/null
}

function get_retropie_depends() {
    # add rasberrypi repository if it's missing (needed for libraspberrypi-dev etc) - not used on osmc
    local config="/etc/apt/sources.list.d/raspi.list"
    if [[ ! -f "$config" ]] && ! hasPackage rbp-bootloader-osmc; then
        # add key
        wget -q http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O- | apt-key add - >/dev/null
        echo "deb http://archive.raspberrypi.org/debian/ $__raspbian_name main" >>$config
    fi

    if ! getDepends git dialog wget gcc gcc-$__default_gcc_version g++-$__default_gcc_version build-essential xmlstarlet; then
        fatalError "Unable to install packages required by $0 - ${md_ret_errors[@]}"
    fi
}

function platform_rpi1() {
    # values to be used for configure/make
    __default_cflags="-O2 -mfpu=vfp -march=armv6j -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags=""
    # if building in a chroot, what cpu should be set by qemu
    # make chroot identify as arm6l
    __qemu_cpu=arm1176
    # do we have prebuild binaries for this platform
    __has_binaries=1
}

function platform_rpi2() {
    __default_cflags="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags="-j2"
    # there is no support in qemu for cortex-a7 it seems, but it does have cortex-a15 which is architecturally
    # aligned with the a7, and allows the a7 targetted code to be run in a chroot/emulated environment
    __qemu_cpu=cortex-a15
    __has_binaries=1
}

function platform_odroid() {
    __default_cflags="-O2 -mfpu=neon -march=armv7-a -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags=""
    __has_binaries=0
}
