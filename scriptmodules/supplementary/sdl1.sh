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
rp_module_section=""
rp_module_flags="!mali !x86"

function get_ver_sdl1() {
    echo "12"
}

function depends_sdl1() {
    getDepends debhelper dh-autoreconf devscripts libx11-dev libxext-dev libxt-dev libxv-dev x11proto-core-dev libaudiofile-dev libpulse-dev libgl1-mesa-dev libasound2-dev libcaca-dev libdirectfb-dev libglu1-mesa-dev libraspberrypi-dev
    compareVersions "$__os_release" lt 8 && getDepends libts-dev
}

function sources_sdl1() {
    local file
    for file in libsdl1.2_1.2.15.orig.tar.gz libsdl1.2_1.2.15-10.dsc libsdl1.2_1.2.15-10.debian.tar.xz; do
        wget -q -O "$file" "http://ftp.debian.org/debian/pool/main/libs/libsdl1.2/$file"
    done
    dpkg-source -x libsdl1.2_1.2.15-10.dsc

    cd libsdl1.2-1.2.15
    # add fixes from https://github.com/RetroPie/sdl1/compare/master...rpi
    wget https://github.com/RetroPie/sdl1/compare/master...rpi.diff -O debian/patches/rpi.diff
    echo "rpi.diff" >>debian/patches/series
    # force building without tslib on Jessie (as Raspbian Jessie has tslib, but Debian Jessie doesn't and we want cross compatibility
    if compareVersions "$__os_release" ge 8; then
        sed -i "s/--enable-video-caca/--enable-video-caca --disable-input-tslib/" debian/rules
    fi
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v 1.2.15-$(get_ver_sdl1)rpi "Added rpi fixes and dispmanx support from https://github.com/RetroPie/sdl1/compare/master...rpi"
}

function build_sdl1() {
    cd libsdl1.2-1.2.15
    dpkg-buildpackage
    local dest="$__tmpdir/archives/$__os_codename/$__platform"
    mkdir -p "$dest"
    cp ../*.deb "$dest/"
}

function install_sdl1() {
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl1.2debian_1.2.15-$(get_ver_sdl1)rpi_armhf.deb libsdl1.2-dev_1.2.15-$(get_ver_sdl1)rpi_armhf.deb; then
        apt-get -y -f install
    fi
    echo "libsdl1.2-dev hold" | dpkg --set-selections
}

function install_bin_sdl1() {
    if ! isPlatform "rpi"; then
        md_ret_errors+=("$md_id is only available as a binary package for platform rpi")
        return 1
    fi
    wget "$__binary_url/libsdl1.2debian_1.2.15-$(get_ver_sdl1)rpi_armhf.deb"
    wget "$__binary_url/libsdl1.2-dev_1.2.15-$(get_ver_sdl1)rpi_armhf.deb"
    install_sdl1
    rm ./*.deb
}

function remove_sdl1() {
    apt-get remove -y --force-yes libsdl1.2-dev
    apt-get autoremove -y
}
