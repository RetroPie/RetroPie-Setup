#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="vice"
rp_module_desc="C64 emulator VICE"
rp_module_help="ROM Extensions: .crt .d64 .g64 .prg .t64 .tap .x64 .zip .vsf\n\nCopy your Commodore 64 roms to $romdir/c64"
rp_module_section="opt"
rp_module_flags=""

function depends_vice() {
    local depends=(libsdl2-dev libpng12-dev zlib1g-dev libasound2-dev libpcap-dev automake checkinstall bison flex subversion)

    if compareVersions "$__os_release" lt 8; then
        depends+=(libjpeg8-dev )
    else
        depends+=(libjpeg-dev)
    fi

    getDepends "${depends[@]}"
}

function sources_vice() {
    svn checkout svn://svn.code.sf.net/p/vice-emu/code/trunk/vice/ "$md_build"
}

function build_vice() {
    local params=(--enable-sdlui2 --without-arts --without-oss --enable-ethernet)
    ! isPlatform "x11" && params+=(--disable-catweasel --without-pulse)
    ./autogen.sh
    ./configure --prefix="$md_inst" "${params[@]}"
    make
    md_ret_require="$md_build/src/x64"
}

function install_vice() {
    make install
}

function configure_vice() {
    mkRomDir "c64"

    addSystem 1 "$md_id-x64" "c64" "$md_inst/bin/x64 %ROM%"
    addSystem 0 "$md_id-x64sc" "c64" "$md_inst/bin/x64sc %ROM%"
    addSystem 0 "$md_id-x128" "c64" "$md_inst/bin/x128 %ROM%"
    addSystem 0 "$md_id-xpet" "c64" "$md_inst/bin/xpet %ROM%"
    addSystem 0 "$md_id-xplus4" "c64" "$md_inst/bin/xplus4 %ROM%"
    addSystem 0 "$md_id-xvic" "c64" "$md_inst/bin/xvic %ROM%"
    addSystem 0 "$md_id-xvic-cart" "c64" "$md_inst/bin/xvic -cartgeneric %ROM%"

    [[ "$md_mode" == "remove" ]] && return

    # copy any existing configs from ~/.vice and symlink the config folder to $md_conf_root/c64/
    moveConfigDir "$home/.vice" "$md_conf_root/c64"

    local config="$(mktemp)"
    echo "[C64]" > "$config"
    iniConfig "=" "" "$config"
    if ! isPlatform "x11"; then
        iniSet "Mouse" "1"
        iniSet "VICIIDoubleSize" "0"
        iniSet "VICIIDoubleScan" "0"
        iniSet "VICIIFilter" "0"
        iniSet "VICIIVideoCache" "0"
        iniSet "SDLWindowWidth" "384"
        iniSet "SDLWindowHeight" "272"
        isPlatform "rpi1" && iniSet "SoundSampleRate" "22050"
        iniSet "SidEngine" "0"
    else
        iniSet "VICIIFullscreen" "1"
    fi

    copyDefaultConfig "$config" "$md_conf_root/c64/sdl-vicerc"
    rm "$config"
}
