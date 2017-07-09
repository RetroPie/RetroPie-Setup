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
    get_default_gcc

    # set default gcc version
    if [[ -n "$__default_gcc_version" ]]; then
        set_default_gcc "$__default_gcc_version"
    fi

    # set location of binary downloads
    __binary_host="files.retropie.org.uk"
    [[ "$__has_binaries" -eq 1 ]] && __binary_url="http://$__binary_host/binaries/$__os_codename/$__platform"

    __archive_url="http://files.retropie.org.uk/archives"

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
        Debian)
            if compareVersions "$__os_release" lt 8; then
                error="You need Debian Jessie or newer"
            fi

            # set a platform flag for osmc
            if grep -q "ID=osmc" /etc/os-release; then
                __platform_flags+=" osmc"
            fi

            # and for xbian
            if grep -q "NAME=XBian" /etc/os-release; then
                __platform_flags+=" xbian"
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
            if compareVersions "$__os_release" lt 17; then
                error="You need Linux Mint 17 or newer"
            elif compareVersions "$__os_release" lt 18; then
                __os_ubuntu_ver="14.04"
            else
                __os_ubuntu_ver="16.04"
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

    # add 64bit to platform flags
    __platform_flags+=" $(getconf LONG_BIT)bit"
}

function get_default_gcc() {
    if [[ -z "$__default_gcc_version" ]]; then
        case "$__os_id" in
            Debian)
                case "$__os_debian_ver" in
                    8)
                        __default_gcc_version="4.9"
                esac
                ;;
            *)
                ;;
        esac
    fi
}

# gcc version helper
function set_default() {
    if [[ -e "$1-$2" ]] ; then
        # echo $1-$2 is now the default
        ln -sf "$1-$2" "$1"
    else
        echo "$1-$2 is not installed"
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

function get_platform() {
    local architecture="$(uname --machine)"
    if [[ -z "$__platform" ]]; then
        case "$(/proc/device-tree/model)" in
            "Qualcomm Technologies, Inc. APQ 8016 SBC")
					__platform="db410c"
                ;;
			"HiKey Development Board")
					__platform="hikey620"
				;;
        esac
    fi

    if ! fnExists "platform_${__platform}"; then
        fatalError "Unknown platform - please manually set the __platform variable to one of the following: $(compgen -A function platform_ | cut -b10- | paste -s -d' ')"
    fi

	platform_${__platform}
}

function platform_db410c() {
    __default_cflags="-O2 -march=armv8-a -mtune=cortex-a53 -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv8"
}

function platform_hikey620() {
    __default_cflags="-O2 -march=armv8-a -mtune=cortex-a53 -ftree-vectorize -funsafe-math-optimizations"
    __default_asflags=""
    __default_makeflags="-j2"
    __platform_flags="arm armv8"
}

