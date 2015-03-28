#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
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

}

function platform_rpi1() {
    # values to be used for configure/make
    __default_cflags="-O2 -mfpu=vfp -march=armv6j -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags=""
    __default_gcc_version="4.7"
    # if building in a chroot, what cpu should be set by qemu
    # make chroot identify as arm6l
    __qemu_cpu=arm1176
    # do we have prebuild binaries for this platform
    __has_binaries=1
    # binary archive location (without trailing slash)
    __binary_url="http://downloads.petrockblock.com/retropiebinaries/rpi1"
}

function platform_rpi2() {
    __default_cflags="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags="-j2"
    __default_gcc_version="4.7"
    # there is no support in qemu for cortex-a7 it seems, but it does have cortex-a15 which is architecturally
    # aligned with the a7, and allows the a7 targetted code to be run in a chroot/emulated environment
    __qemu_cpu=cortex-a15
    __has_binaries=1
    __binary_url="http://downloads.petrockblock.com/retropiebinaries/rpi2"
}

function platform_odroid() {
    __default_cflags="-O2 -mfpu=neon -march=armv7-a -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags=""
    __default_gcc_version="4.7"
    __has_binaries=0
}
