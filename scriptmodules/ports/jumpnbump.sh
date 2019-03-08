#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="jumpnbump"
rp_module_desc="Jump 'n Bump, play cute bunnies jumping on each other's heads - Modernization fork"
rp_module_help="Copy custom game levels (.dat) to $romdir/ports/jumpnbump"
rp_module_licence="GPL2 https://gitlab.com/LibreGames/jumpnbump/raw/master/COPYING"
rp_module_section="exp"
rp_module_flags=""

function depends_jumpnbump() {
    getDepends libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libbz2-dev zlib1g-dev
}

function sources_jumpnbump() {
    gitPullOrClone "$md_build" https://gitlab.com/LibreGames/jumpnbump.git
}

function build_jumpnbump() {
    make clean
    CFLAGS="$CFLAGS -fsigned-char" make PREFIX="$md_inst"
}

function install_jumpnbump() {
    make PREFIX="$md_inst" install
    strip "$md_inst"/bin/{gobpack,jnbpack,jnbunpack,jumpnbump}
}

function game_data_jumpnbump() {
    local tmpdir="$(mktemp -d)"
    local compressed
    local uncompressed

    # install extra levels from Debian's jumpnbump-levels package
    downloadAndExtract "https://salsa.debian.org/games-team/jumpnbump-levels/-/archive/master/jumpnbump-levels-master.tar.bz2" "$tmpdir" --strip-components 1 --wildcards "*.bz2"
    for compressed in "$tmpdir"/*.bz2; do
        uncompressed="${compressed##*/}"
        uncompressed="${uncompressed%.bz2}"
        if [[ ! -f "$romdir/ports/jumpnbump/$uncompressed" ]]; then
            bzcat "$compressed" > "$romdir/ports/jumpnbump/$uncompressed"
            chown -R $user:$user "$romdir/ports/jumpnbump/$uncompressed"
        fi
    done
    rm -rf "$tmpdir"
}

function configure_jumpnbump() {
    addPort "$md_id" "jumpnbump" "Jump 'n Bump" "$md_inst/jumpnbump.sh"
    mkRomDir "ports/jumpnbump"
    [[ "$md_mode" == "remove" ]] && return

    # install game data
    game_data_jumpnbump

    # install launch script
    cp "$md_data/jumpnbump.sh" "$md_inst"
    iniConfig "=" '"' "$md_inst/jumpnbump.sh"
    iniSet "ROOTDIR" "$rootdir"
    iniSet "MD_CONF_ROOT" "$md_conf_root"
    iniSet "ROMDIR" "$romdir"
    iniSet "MD_INST" "$md_inst"

    # set default game options on first install
    if [[ ! -f "$md_conf_root/jumpnbump/options.cfg" ]];  then
        iniConfig " = " "" "$md_conf_root/jumpnbump/options.cfg"
        iniSet "nogore" "1"
    fi
}
