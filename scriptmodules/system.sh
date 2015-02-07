#!/usr/bin/env bash

#
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
#
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
#
#  Permission to use, copy, modify and distribute this work in both binary and
#  source form, for non-commercial purposes, is hereby granted without fee,
#  providing that this license information and copyright notice appear with
#  all copies and any derived work.
#
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event shall the authors be held liable for any damages
#  arising from the use of this software.
#
#  RetroPie-Setup is freeware for PERSONAL USE only. Commercial users should
#  seek permission of the copyright holders first. Commercial use includes
#  charging money for RetroPie-Setup or software derived from RetroPie-Setup.
#
#  The copyright holders request that bug fixes and improvements to the code
#  should be forwarded to them so everyone can benefit from the modifications
#  in future versions.
#
#  Many, many thanks go to all people that provide the individual packages!!!
#

function setup_env() {

    __ERRMSGS=""
    __INFMSGS=""

    __memory_phys=$(free -m | awk '/^Mem:/{print $2}')
    __memory_total=$(free -m -t | awk '/^Total:/{print $2}')

    if [[ -z "$__platform" ]]; then
        case `sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo` in
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
    __binary_url="http://downloads.petrockblock.com/retropiebinaries"
}

function platform_rpi2() {
    __default_cflags="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard"
    __default_asflags=""
    __default_makeflags=""
    __default_gcc_version="4.7"
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
