#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uqm"
rp_module_desc="The Ur-Quan Masters (Port of DOS game Star Control 2)"
rp_module_licence="NONCOM https://raw.githubusercontent.com/davidben/uqm/nacl/COPYING"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_ver_uqm() {
    echo "0.6.2.dfsg-9.5"
}

function _update_hook_uqm() {
    # to show as installed in retropie-setup 4.x
    hasPackage uqm && mkdir -p "$md_inst"
}

function depends_uqm() {
    [[ "$__os_id" != "Raspbian" ]] && return 0
    local depends=(debhelper devscripts libmikmod-dev libsdl1.2-dev libopenal-dev libsdl-image1.2-dev libogg-dev libvorbis-dev xz-utils)
    isPlatform "gl" || isPlatform "mesa" && depends+=(libgl1-mesa-dev)
    isPlatform "kms" && depends+=(xorg)

    getDepends "${depends[@]}"
}

function sources_uqm() {
    [[ "$__os_id" != "Raspbian" ]] && return 0
    local ver="$(_get_ver_uqm)"
    local url="http://http.debian.net/debian/pool/contrib/u/uqm"
    for file in uqm_$ver.dsc uqm_0.6.2.dfsg.orig.tar.gz uqm_$ver.debian.tar.xz; do
        wget -nv -O"$file" "$url/$file"
    done
}

function build_uqm() {
    [[ "$__os_id" != "Raspbian" ]] && return 0
    dpkg-source -x uqm_$(_get_ver_uqm).dsc
    cd uqm-0.6.2.dfsg
    dpkg-buildpackage -us -uc
}

function install_uqm() {
    # uqm is missing on raspbian
    if [[ "$__os_id" == "Raspbian" ]]; then
        cp -v *.deb "$md_inst"
        dpkg -i *.deb
        aptInstall uqm-content uqm-music uqm-voice
    else
        aptInstall uqm uqm-content uqm-music uqm-voice
    fi
}

function install_bin_uqm() {
    rp_installBin
    # uqm is missing on raspbian
    if hasPackage raspberrypi-bootloader; then
        cd "$md_inst"
        dpkg -i *.deb
        aptInstall uqm-content uqm-music uqm-voice
    else
        aptInstall uqm uqm-content uqm-music uqm-voice
    fi
}

function remove_uqm() {
    aptRemove uqm uqm-content uqm-music uqm-voice
}

function configure_uqm() {
    local binary="uqm"
    local params=("-f")
    if isPlatform "kms"; then
        # SDL1 needs xinit, and does not have /usr/games in $PATH
        binary="XINIT:/usr/games/$binary"
        # OpenGL mode must be also be enabled for high resolution support
        params+=("-o" "-r %XRES%x%YRES%")
    fi
    moveConfigDir "$home/.uqm" "$md_conf_root/uqm"
    addPort "$md_id" "uqm" "Ur-quan Masters" "$binary ${params[*]}"
}
