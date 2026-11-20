#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ja2-stracciatella"
rp_module_desc="Jagged Alliance 2 - Stracciatella. The continuation of the venerable JA2-Stracciatella project."
rp_module_help="Start the game the first time. It will create the configuration ~/.ja2/ja2.json. Edit the configuration file and set parameter game_dir to point to the directory where the original game was installed.\n\nIf you installed not the English version of the original game, but one of the localized varieties (e.g. French or Russian), you need to start ja2 with parameter telling which version of the game you are using. For example: ja2.exe -resversion FRENCH. Supported localizations are DUTCH, ENGLISH, FRENCH, GERMAN, ITALIAN, POLISH, RUSSIAN, RUSSIAN_GOLD. Use RUSSIAN for the “BUKA Agonia Vlasty” release and RUSSIAN_GOLD for the “Gold” release.\n\nParameters can be set in: ${configdir}/ports/${rp_module_id}/emulators.cfg"
rp_module_licence="SFI-SCLA https://raw.githubusercontent.com/ja2-stracciatella/ja2-stracciatella/master/SFI%20Source%20Code%20license%20agreement.txt"
rp_module_repo="git https://github.com/ja2-stracciatella/ja2-stracciatella.git v0.21.0"
rp_module_flags="sdl2"
rp_module_section="exp"

function install_bin_ja2-stracciatella() {
    local appimage="ja2-stracciatella_0.21.0-git+61938e1_"
    isPlatform "x86" && isPlatform "64bit" && appimage+="x86_64"
    if isPlatform "rpi"; then
        isPlatform "32bit" && appimage+="armhf"
        isPlatform "64bit" && appimage+="aarch64"
	fi
    appimage+=".AppImage"
    download "https://github.com/ja2-stracciatella/ja2-stracciatella/releases/download/v0.21.0/$appimage" "$md_inst/ja2"
    chmod +x "$md_inst/ja2"
}

function depends_ja2-stracciatella() {
    local depends=(cmake libsdl2-dev)
    [[ "$__os_debian_ver" -gt 11 ]] && depends+=(rustc cargo)
    [[ "$__os_debian_ver" -le 11 ]] && depends+=(rustc-mozilla cargo-mozilla)
    getDepends "${depends[@]}"
}

function sources_ja2-stracciatella() {
    gitPullOrClone
}

function build_ja2-stracciatella() {
    rpSwap on 3072
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    rpSwap off
    md_ret_require="$md_build/ja2"
    strip "$md_build/ja2"
}

function install_ja2-stracciatella() {
    md_ret_files=(
        'ja2'
        'externalized'
        'mods'
        'unittests'
    )
}

function configure_ja2-stracciatella() {
    addPort "$md_id" "ja2-stracciatella" "Jagged Alliance 2" "$md_inst/ja2 -fullscreen"
}
