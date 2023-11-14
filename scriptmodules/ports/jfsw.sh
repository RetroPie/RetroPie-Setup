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
rp_module_repo="git https://github.com/jonof/jfsw.git master 12828783"
rp_module_section="exp"
rp_module_flags=""

function depends_jfsw() {
    local depends=(
        libsdl2-dev libvorbis-dev libfluidsynth-dev
    )

    isPlatform "x86" && depends+=(nasm)
    isPlatform "gl" || isPlatform "mesa" && depends+=(libgl1-mesa-dev libglu1-mesa-dev)
    isPlatform "x11" && depends+=(libgtk3.0-dev)
    getDepends "${depends[@]}"
}

function sources_jfsw() {
    gitPullOrClone
}

function build_jfsw() {
    local params=(DATADIR=$romdir/ports/shadowwarrior RELEASE=1)

    ! isPlatform "x86" && params+=(USE_ASM=0)
    ! isPlatform "x11" && params+=(WITHOUT_GTK=1)
    ! isPlatform "gl3" && params+=(USE_POLYMOST=0)

    if isPlatform "gl" || isPlatform "mesa"; then
        params+=(USE_OPENGL=USE_GL2)
    elif isPlatform "gles"; then
        params+=(USE_OPENGL=USE_GLES2)
    else
        params+=(USE_OPENGL=0)
    fi

    make clean veryclean
    make "${params[@]}"

    md_ret_require="$md_build/sw"
}

function install_jfsw() {
    md_ret_files=(
        'sw'
        'build'
        'README.md'
        'GPL.TXT'
    )
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
    local config="$md_conf_root/sw/jfsw/sw.cfg"
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

    if [[ -f "$config" ]]; then
        return
    fi

    # no config file exists, creating one
    # with alsa as the sound driver
    cat >"$config" << _EOF_
[Sound Setup]
MusicParams = "audio.driver=alsa"
_EOF_
    chown -R $user:$user "$config"
}
