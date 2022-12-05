#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdl1"
rp_module_desc="SDL 1.2.15 with rpi fixes and dispmanx"
rp_module_licence="GPL2 https://hg.libsdl.org/SDL/raw-file/7676476631ce/COPYING"
rp_module_section="depends"
rp_module_flags="!all rpi"

function get_pkg_ver_sdl1() {
    local basever
    local revision

    if [[ "$__os_debian_ver" -eq 9 ]]; then
        basever="1.2.15+dfsg1"
        revision="4"
    elif [[ "$__os_debian_ver" -eq 10 ]]; then
        basever="1.2.15+dfsg2"
        revision="6"
    else
        basever="1.2.15"
        revision="10"
    fi

    if [[ "$1" == "source" ]]; then
        echo "$basever-$revision"
    elif [[ "$1" == "base" ]]; then
        echo "$basever"
    else
        echo "$basever-$(($revision + 3))rpi"
    fi
}

function _get_arch_sdl1() {
    isPlatform "arm" && echo "armhf"
    isPlatform "aarch64" && echo "arm64"
}

function depends_sdl1() {
    getDepends debhelper dh-autoreconf devscripts libx11-dev libxext-dev libxt-dev libxv-dev x11proto-core-dev libaudiofile-dev libpulse-dev libgl1-mesa-dev libasound2-dev libcaca-dev libdirectfb-dev libglu1-mesa-dev libraspberrypi-dev
}

function sources_sdl1() {
    local files=()
    if [[ "$__os_debian_ver" -eq 9 ]]; then
        files+=(libsdl1.2_$(get_pkg_ver_sdl1 base).orig.tar.xz)
    else
        files+=(libsdl1.2_$(get_pkg_ver_sdl1 base).orig.tar.gz)
    fi
    files+=(
        libsdl1.2_$(get_pkg_ver_sdl1 source).dsc
        libsdl1.2_$(get_pkg_ver_sdl1 source).debian.tar.xz
    )
    local file
    for file in "${files[@]}"; do
        download "http://mirrordirector.raspbian.org/raspbian/pool/main/libs/libsdl1.2/$file" "$file"
    done
    dpkg-source -x libsdl1.2_$(get_pkg_ver_sdl1 source).dsc

    cd libsdl1.2-$(get_pkg_ver_sdl1 base)
    # add fixes from https://github.com/RetroPie/sdl1/compare/master...rpi
    download "https://github.com/RetroPie/sdl1/compare/master...rpi.diff" "debian/patches/rpi.diff"
    echo "rpi.diff" >>debian/patches/series
    # force building without tslib on Jessie (as Raspbian Jessie has tslib, but Debian Jessie doesn't and we want cross compatibility
    sed -i "s/--enable-video-caca/--enable-video-caca --disable-input-tslib/" debian/rules
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v $(get_pkg_ver_sdl1) "Added rpi fixes and dispmanx support from https://github.com/RetroPie/sdl1/compare/master...rpi"
}

function build_sdl1() {
    cd libsdl1.2-$(get_pkg_ver_sdl1 base)
    dpkg-buildpackage
    local dest="$__tmpdir/archives/$__binary_path"
    mkdir -p "$dest"

    local file
    for file in ../*.deb; do
        if gpg --list-secret-keys "$__gpg_signing_key" &>/dev/null; then
            signFile "$file" || return 1
            cp "${file}.asc" "$dest/"
        fi
        cp ../*.deb "$dest/"
    done
}

function install_sdl1() {
    local arch="$(_get_arch_sdl1)"
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl1.2debian_$(get_pkg_ver_sdl1)_${arch}.deb libsdl1.2-dev_$(get_pkg_ver_sdl1)_${arch}.deb; then
        apt-get -y -f --no-install-recommends install
    fi
    echo "libsdl1.2-dev hold" | dpkg --set-selections
}


function __binary_url_sdl1() {
    rp_hasBinaries && echo "$__binary_url/libsdl1.2debian_$(get_pkg_ver_sdl1)_$(_get_arch_sdl1).deb"
}

function install_bin_sdl1() {
    local arch="$(_get_arch_sdl1)"
    local tmp="$(mktemp -d)"
    pushd "$tmp" >/dev/null
    local ret=1
    if downloadAndVerify "$__binary_url/libsdl1.2debian_$(get_pkg_ver_sdl1)_${arch}.deb" && \
       downloadAndVerify "$__binary_url/libsdl1.2-dev_$(get_pkg_ver_sdl1)_${arch}.deb"; then
        install_sdl1
        ret=0
    fi
    popd >/dev/null
    rm -rf "$tmp"
    return "$ret"
}

function remove_sdl1() {
    apt-get remove -y --allow-change-held-packages libsdl1.2-dev libsdl1.2debian
    apt-get autoremove -y
}
