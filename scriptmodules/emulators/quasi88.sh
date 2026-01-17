#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="quasi88"
rp_module_desc="NEC PC-8801 emulator"
rp_module_help="ROM Extensions: .d88 .88d .cmt .t88\n\nCopy your pc88 games to to $romdir/pc88\n\nCopy bios files FONT.ROM, N88.ROM, N88KNJ1.ROM, N88KNJ2.ROM, and N88SUB.ROM to $biosdir/pc88"
rp_module_repo="git https://github.com/winterheart/quasi88.git master"
rp_module_licence="BSD https://raw.githubusercontent.com/winterheart/quasi88/master/LICENSE.txt"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_quasi88() {
    getDepends cmake libsdl2-dev libfmt-dev libspdlog-dev
}

function sources_quasi88() {
    gitPullOrClone
    applyPatch "$md_data/01_cmake.diff"
}

function build_quasi88() {
    rm -fr build
    mkdir -p build && pushd build
    cmake -DROMDIR="$biosdir/pc88" -DDISKDIR="$romdir/pc88" -DTAPEDIR="$romdir/pc88" ..
    make
    popd
}

function install_quasi88() {
    md_ret_files=(
        "build/quasi88.sdl"
        "document"
        "LICENSE.txt"
        "README.md"
        "ChangeLog.md"
    )
}

function configure_quasi88() {
    mkRomDir "pc88"
    moveConfigDir "$home/.quasi88" "$md_conf_root/pc88"
    mkUserDir "$biosdir/pc88"

    addEmulator 1 "$md_id" "pc88" "$md_inst/quasi88.sdl -f6 IMAGE-NEXT1 -f7 IMAGE-NEXT2 -f8 NOWAIT -f9 ROMAJI -f10 NUMLOCK -fullscreen %ROM%"
    addSystem "pc88"

    [[ "$mode" == "remove" ]] && return

    # add a minimal configuration file
    local conf="$md_conf_root/pc88/quasi88.ini"
    if [[ ! -f "$conf" ]]; then
cat > "$conf" << EOF
-auto_mouse
-nostatus
-double
-english
-use_joy
-verbose 1
-romdir "$biosdir/pc88"
-diskdir "$romdir/pc88"
-tapedir "$romdir/pc88"
EOF
    chown "$__user":"$__group" "$conf"
    fi
}
