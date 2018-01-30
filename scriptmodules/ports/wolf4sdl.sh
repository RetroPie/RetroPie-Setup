#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wolf4sdl"
rp_module_desc="Wolf4SDL - port of Wolfenstein 3D / Spear of Destiny engine"
rp_module_licence="NONCOM https://raw.githubusercontent.com/mozzwald/wolf4sdl/master/license-mame.txt"
rp_module_section="opt"
rp_module_flags="dispmanx  "

function depends_wolf4sdl() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev
}

function sources_wolf4sdl() {
    gitPullOrClone "$md_build" https://github.com/mozzwald/wolf4sdl.git
}

function get_opts_wolf4sdl() {
    echo 'wolf4sdl-sw-v14 -DCARMACIZED -DUPLOAD' # shareware v1.4
    echo 'wolf4sdl-3dr-v14 -DCARMACIZED' # 3d realms / apogee v1.4 full
    echo 'wolf4sdl-gt-v14 -DCARMACIZED -DGOODTIMES' # gt / id / activision v1.4 full
    echo 'wolf4sdl-spear -DCARMACIZED -DGOODTIMES -DSPEAR' # spear of destiny
}

function get_bins_wolf4sdl() {
    local opt
    while read -r opt; do
        echo "${opt%% *}"
    done < <(get_opts_wolf4sdl)
}

function build_wolf4sdl() {
    mkdir "bin"
    local opt
    while read -r opt; do
        local bin="${opt%% *}"
        local defs="${opt#* }"
        make clean
        CFLAGS+=" -DVERSIONALREADYCHOSEN $defs" make DATADIR="$romdir/ports/wolf3d/"
        mv wolf3d "bin/$bin"
        md_ret_require+=("bin/$bin")
    done < <(get_opts_wolf4sdl)
}

function install_wolf4sdl() {
    mkdir -p "$md_inst/share/man"
    cp -Rv "$md_build/man6" "$md_inst/share/man/"
    md_ret_files=('bin')
}

function game_data_wolf4sdl() {
    if [[ ! -f "$romdir/ports/wolf3d/gamemaps.wl1" ]]; then
        cd "$__tmpdir"
        # Get shareware game data
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d" "-j -LL"
        chown -R $user:$user "$romdir/ports/wolf3d"
    fi
}

function configure_wolf4sdl() {
    local bin
    local bins
    local mission=0
    while read -r bin; do
        bins+=("$bin")
    done < <(get_bins_wolf4sdl)
    # called outside of above loop to avoid problems with addPort and stdin
    for bin in "${bins[@]}"; do
        [[ "$bin" != "wolf4sdl-spear" ]] && addPort "$bin" "wolf3d" "Wolfenstein 3D" "$md_inst/bin/$bin"
    done
    for bin in "wolf4sdl-spear" "wolf4sdl-spear2" "wolf4sdl-spear3"; do
        ((mission++))
        addPort "$bin" "wolf3d" "Wolfenstein 3D" "$md_inst/bin/wolf4sdl-spear --mission $mission"
    done

    mkRomDir "ports/wolf3d"

    moveConfigDir "$home/.wolf4sdl" "$md_conf_root/wolf3d"

    setDispmanx "$md_id" 1
    configure_dispmanx_on_wolf4sdl

    [[ "$md_mode" == "install" ]] && game_data_wolf4sdl
}

function configure_dispmanx_off_wolf4sdl() {
    local bin
    while read -r bin; do
        setDispmanx "$bin" 0
    done < <(get_bins_wolf4sdl)
}

function configure_dispmanx_on_wolf4sdl() {
    local bin
    while read -r bin; do
        setDispmanx "$bin" 1
    done < <(get_bins_wolf4sdl)
}
