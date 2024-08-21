#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="jfsw"
rp_module_desc="Shadow Warrior source port by JonoF"
rp_module_help="Place your registered version game files in $romdir/ports/shadowwarrior"
rp_module_licence="GPL2 https://raw.githubusercontent.com/jonof/jfsw/master/GPL.TXT"
rp_module_repo="git https://github.com/jonof/jfsw.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_jfsw() {
    depends_jfduke3d
}

function sources_jfsw() {
    gitPullOrClone
}

function build_jfsw() {
    build_jfduke3d "shadowwarrior" "sw"
}

function install_jfsw() {
    install_jfduke3d 'sw'
}

function gamedata_jfsw() {
    local dest="$romdir/ports/shadowwarrior"
    if [[ ! -n $(find $dest -maxdepth 1 -iname sw.grp) ]]; then
        mkUserDir "$dest"
        local temp="$(mktemp -d)"
        download "ftp://ftp.3drealms.com/share/3dsw12.zip" "$temp"
        unzip -L -o "$temp/3dsw12.zip" -d "$temp" swsw12.shr
        unzip -L -o "$temp/swsw12.shr" -d "$dest" sw.grp sw.rts
        rm -rf "$temp"
    fi
    chown -R $user:$user "$dest"
}

function configure_jfsw() {
    local gamedir="$romdir/ports/shadowwarrior"

    mkRomDir "ports/shadowwarrior"
    moveConfigDir "$home/.jfsw" "$md_conf_root/sw/jfsw"

    addPort "$md_id" "sw" "Shadow Warrior" "$md_inst/sw %ROM%" ""
    [[ -n $(find $gamedir -maxdepth 1 -iname dragon.zip) ]] && addPort "$md_id" "sw" "Shadow Warrior Twin Dragon" "$md_inst/sw %ROM%" "-gdragon.zip"
    [[ -n $(find $gamedir -maxdepth 1 -iname wt.grp) ]] && addPort "$md_id" "sw" "Shadow Warrior Wanton Destruction" "$md_inst/sw %ROM%" "-gwt.grp"

    if [[ "$md_mode" != "install" ]]; then
        return
    fi
    gamedata_jfsw
    config_file_jfduke3d "$md_conf_root/sw/jfsw/sw.cfg"
}
