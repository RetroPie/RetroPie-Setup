#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdltrs"
rp_module_desc="Radio Shack TRS-80 Model I/III/4/4P emulator"
rp_module_help="ROM Extension: .dsk\n\nCopy your TRS-80 games to $romdir/trs-80\n\nCopy the required BIOS file level2.rom, level3.rom, level4.rom or level4p.rom to $biosdir"
rp_module_section="exp"
rp_module_licence="BSD https://gitlab.com/jengun/sdltrs/-/raw/master/LICENSE"
rp_module_repo="git https://gitlab.com/jengun/sdltrs.git sdl2"
rp_module_flags=""

function depends_sdltrs() {
    getDepends libsdl2-dev libreadline-dev
}

function sources_sdltrs() {
    gitPullOrClone
}

function build_sdltrs() {
    make clean
    ./autogen.sh
    ./configure --prefix="$md_inst"
    make
    md_ret_require="$md_build/sdl2trs"
}

function install_sdltrs() {
    md_ret_files=(
        'sdl2trs'
        'README.md'
        'LICENSE'
    )
}

function configure_sdltrs() {
    local common_args
    mkRomDir "trs-80"

    common_args="-fullscreen -nomousepointer -showled"
    addEmulator 1 "$md_id-model1" "trs-80" "$md_inst/sdl2trs $common_args -m1 -romfile $biosdir/level2.rom -disk0 %ROM%"
    addEmulator 0 "$md_id-model3" "trs-80" "$md_inst/sdl2trs $common_args -m3 -romfile3 $biosdir/level3.rom -disk0 %ROM%"
    addEmulator 0 "$md_id-model4" "trs-80" "$md_inst/sdl2trs $common_args -m4 -romfile3 $biosdir/level4.rom -disk0 %ROM%"
    addEmulator 0 "$md_id-model4p" "trs-80" "$md_inst/sdl2trs $common_args -m4p -romfile4p $biosdir/level4p.rom -disk0 %ROM%"
    addSystem "trs-80"

    [[ "$md_mode" == "remove" ]] && return

    # Migrate settings from the previous version
    if [[ -h "$home/sdltrs.t8c" || -f "$home/sdltrs.t8c" ]]; then
       mv "$(readlink -f "$home/sdltrs.t8c")" "$home/.sdltrs.t8c"
    fi

    local config
    config="$(mktemp)"
    iniConfig "=" "" "$config"
    iniSet "statedir"   "$romdir/trs-80"
    iniSet "diskdir"    "$romdir/trs-80"
    iniSet "cassdir"    "$romdir/trs-80"
    iniSet "disksetdir" "$romdir/trs-80"
    iniSet "harddir"    "$romdir/trs-80"
    copyDefaultConfig "$config" "$md_conf_root/trs-80/sdltrs.t8c"

    moveConfigFile "$home/.sdltrs.t8c" "$md_conf_root/trs-80/sdltrs.t8c"
}
