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
rp_module_section=""
rp_module_flags="!all rpi"

function get_pkg_ver_sdl1() {
    local basever
    local revision

    if compareVersions "$__os_debian_ver" eq 9; then
        basever="1.2.15+dfsg1"
        revision="4"
    elif compareVersions "$__os_debian_ver" eq 10; then
        basever="1.2.15+dfsg2"
        revision="4"
    else
        basever="1.2.15"
        revision="10"
    fi

    if [[ "$1" == "source" ]]; then
        echo "$basever-$revision"
    elif [[ "$1" == "base" ]]; then
        echo "$basever"
    else
        echo "$basever-$(($revision + 2))rpi"
    fi
}

function depends_sdl1() {
    getDepends debhelper dh-autoreconf devscripts libx11-dev libxext-dev libxt-dev libxv-dev x11proto-core-dev libaudiofile-dev libpulse-dev libgl1-mesa-dev libasound2-dev libcaca-dev libdirectfb-dev libglu1-mesa-dev libraspberrypi-dev
}

function sources_sdl1() {
    local file
    for file in libsdl1.2_$(get_pkg_ver_sdl1 base).orig.tar.xz libsdl1.2_$(get_pkg_ver_sdl1 base).orig.tar.gz libsdl1.2_$(get_pkg_ver_sdl1 source).dsc libsdl1.2_$(get_pkg_ver_sdl1 source).debian.tar.xz; do
        wget -q -O "$file" "http://mirrordirector.raspbian.org/raspbian/pool/main/libs/libsdl1.2/$file" || rm -f "$file"
    done
    dpkg-source -x libsdl1.2_$(get_pkg_ver_sdl1 source).dsc

    cd libsdl1.2-$(get_pkg_ver_sdl1 base)
    # add fixes from https://github.com/RetroPie/sdl1/compare/master...rpi
    wget https://github.com/RetroPie/sdl1/compare/master...rpi.diff -O debian/patches/rpi.diff
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
    cp ../*.deb "$dest/"
}

function install_sdl1() {
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl1.2debian_$(get_pkg_ver_sdl1)_armhf.deb libsdl1.2-dev_$(get_pkg_ver_sdl1)_armhf.deb; then
        apt-get -y -f --no-install-recommends install
    fi
    echo "libsdl1.2-dev hold" | dpkg --set-selections
}


function __binary_url_sdl1() {
    rp_hasBinaries && echo "$__binary_url/libsdl1.2debian_$(get_pkg_ver_sdl1)_armhf.deb"
}

function install_bin_sdl1() {
    wget "$__binary_url/libsdl1.2debian_$(get_pkg_ver_sdl1)_armhf.deb"
    wget "$__binary_url/libsdl1.2-dev_$(get_pkg_ver_sdl1)_armhf.deb"
    install_sdl1
    rm ./*.deb
}

function remove_sdl1() {
    apt-get remove -y --allow-change-held-packages libsdl1.2-dev libsdl1.2debian
    apt-get autoremove -y
}
