#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="sdl1"
rp_module_desc="SDL 1.2.15 with rpi fixes and dispmanx"
rp_module_menus=""
rp_module_flags="!odroid nobin"

function depends_sdl1() {
    getDepends devscripts libx11-dev libxext-dev libxt-dev libxv-dev x11proto-core-dev libts-dev libaudiofile-dev libpulse-dev libgl1-mesa-dev libasound2-dev libcaca-dev libdirectfb-dev libglu1-mesa-dev
}

function sources_sdl1() {
    local src="deb-src http://mirrordirector.raspbian.org/raspbian/ wheezy main contrib non-free rpi"
    if ! grep -q "$src" /etc/apt/sources.list; then
        addLineToFile "$src" /etc/apt/sources.list
    fi
    apt-get update
    apt-get source libsdl1.2-dev
    cd libsdl1.2-1.2.15
    
    # add fixes from https://github.com/joolswills/sdl1/compare/master...rpi
    wget https://github.com/joolswills/sdl1/compare/master...rpi.diff -O debian/patches/rpi.diff
    echo "rpi.diff" >>debian/patches/series
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v 1.2.15-8rpi "Added rpi fixes and dispmanx support from https://github.com/joolswills/sdl1/compare/master...rpi"
}

function build_sdl1() {
    cd libsdl1.2-1.2.15
    dpkg-buildpackage
}

function install_sdl1() {
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl1.2debian_1.2.15-8rpi_armhf.deb libsdl1.2-dev_1.2.15-8rpi_armhf.deb; then
        apt-get -y -f install
    fi
    # remove unused sdl1dispmanx library
    rm -rf "$rootdir/supplementary/sdl1dispmanx"
}

function install_bin_sdl1() {
    isPlatform "rpi" || fatalError "$mod_id is only available as a binary package for platform rpi"
    wget "$__binary_url/libsdl1.2debian_1.2.15-8rpi_armhf.deb"
    wget "$__binary_url/libsdl1.2-dev_1.2.15-8rpi_armhf.deb"
    install_sdl1
    rm ./*.deb
}
