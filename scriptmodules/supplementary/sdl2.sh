#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdl2"
rp_module_desc="SDL (Simple DirectMedia Layer) v2.x"
rp_module_licence="ZLIB https://hg.libsdl.org/SDL/raw-file/f426dbef4aa0/COPYING.txt"
rp_module_section=""
rp_module_flags=""

function get_ver_sdl2() {
    echo "2.0.8"
}

function get_pkg_ver_sdl2() {
    local ver="$(get_ver_sdl2)+1"
    isPlatform "rpi" && ver+="rpi"
    isPlatform "mali" && ver+="mali"
    echo "$ver"
}

function get_arch_sdl2() {
    echo "$(dpkg --print-architecture)"
}

function depends_sdl2() {
    # Dependencies from the debian package control + additional dependencies for the pi (some are excluded like dpkg-dev as they are
    # already covered by the build-essential package retropie relies on.
    local depends=(devscripts debhelper dh-autoreconf libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev libxrandr-dev libxss-dev libxt-dev libxxf86vm-dev libgl1-mesa-dev fcitx-libs-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "mali" && depends+=(mali-fbdev)
    isPlatform "kms" && depends+=(libdrm-dev libgbm-dev)
    isPlatform "x11" && depends+=(libpulse-dev libegl1-mesa-dev libgles2-mesa-dev libglu1-mesa-dev)
    getDepends "${depends[@]}"
}

function sources_sdl2() {
    local ver="$(get_ver_sdl2)"
    local pkg_ver="$(get_pkg_ver_sdl2)"

    local branch="release-$ver"
    isPlatform "rpi" && branch="rpi-$ver"
    isPlatform "mali" && branch="mali-$ver"
    isPlatform "kms" && branch="kms-$ver"

    gitPullOrClone "$md_build/$pkg_ver" https://github.com/RetroPie/SDL-mirror.git "$branch"
    cd "$pkg_ver"
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v "$pkg_ver" "SDL $ver configured for the $__platform"
}

function build_sdl2() {
    cd "$(get_pkg_ver_sdl2)"
    dpkg-buildpackage
    md_ret_require="$md_build/libsdl2-dev_$(get_pkg_ver_sdl2)_$(get_arch_sdl2).deb"
    local dest="$__tmpdir/archives/$__os_codename/$__platform"
    mkdir -p "$dest"
    cp ../*.deb "$dest/"
}

function remove_old_sdl2() {
    # remove our old libsdl2 packages
    hasPackage libsdl2 && dpkg --remove libsdl2 libsdl2-dev
}

function install_sdl2() {
    remove_old_sdl2
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl2-2.0-0_$(get_pkg_ver_sdl2)_$(get_arch_sdl2).deb libsdl2-dev_$(get_pkg_ver_sdl2)_$(get_arch_sdl2).deb; then
        apt-get -y -f install
    fi
    echo "libsdl2-dev hold" | dpkg --set-selections
}

function install_bin_sdl2() {
    if ! isPlatform "rpi"; then
        md_ret_errors+=("$md_id is only available as a binary package for platform rpi")
        return 1
    fi
    wget -c "$__binary_url/libsdl2-dev_$(get_pkg_ver_sdl2)_armhf.deb"
    wget -c "$__binary_url/libsdl2-2.0-0_$(get_pkg_ver_sdl2)_armhf.deb"
    install_sdl2
    rm ./*.deb
}

function revert_sdl2() {
    aptUpdate
    local packaged="$(apt-cache madison libsdl2-dev | cut -d" " -f3)"
    aptInstall --force-yes libsdl2-2.0-0="$packaged" libsdl2-dev="$packaged"
}

function remove_sdl2() {
    apt-get remove -y --force-yes libsdl2-dev
    apt-get autoremove -y
}
