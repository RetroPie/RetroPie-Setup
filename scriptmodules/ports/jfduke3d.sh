#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="jfduke3d"
rp_module_desc="lightweight Duke3D source port by JonoF"
rp_module_licence="GPL2 https://raw.githubusercontent.com/jonof/jfduke3d/master/GPL.TXT"
rp_module_repo="git https://github.com/jonof/jfduke3d.git master 41cd46bc"
rp_module_section="exp"
rp_module_flags=""

function depends_jfduke3d() {
    local depends=(
        libsdl2-dev libvorbis-dev libfluidsynth-dev
    )

    isPlatform "x86" && depends+=(nasm)
    isPlatform "gl" || isPlatform "mesa" && depends+=(libgl1-mesa-dev libglu1-mesa-dev)
    isPlatform "x11" && depends+=(libgtk3.0-dev)
    getDepends "${depends[@]}"
}

function sources_jfduke3d() {
    gitPullOrClone
}

function build_jfduke3d() {
    local params=(DATADIR=$romdir/ports/duke3d RELEASE=1)

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

    md_ret_require="$md_build/duke3d"
}

function install_jfduke3d() {
    md_ret_files=(
        'duke3d'
        'build'
        'README.md'
        'GPL.TXT'
    )
}

function game_data_jfduke3d() {
    local dest="$romdir/ports/duke3d"
    if [[ ! -n $(find $dest -maxdepth 1 -iname duke3d.grp) ]]; then
        mkUserDir "$dest"
        local temp="$(mktemp -d)"
        download "$__archive_url/3dduke13.zip" "$temp"
        unzip -L -o "$temp/3dduke13.zip" -d "$temp" dn3dsw13.shr
        unzip -L -o "$temp/dn3dsw13.shr" -d "$dest" duke3d.grp duke.rts
        rm -rf "$temp"
        chown -R $user:$user "$dest"
    fi
}

function configure_jfduke3d() {
    local config="$md_conf_root/jfduke3d/duke3d.cfg"

    mkRomDir "ports/duke3d"
    moveConfigDir "$home/.jfduke3d" "$md_conf_root/jfduke3d"

    # params are just for parity with eduke32, last one is not supported
    addPort "$md_id" "duke3d" "Duke Nukem 3D" "$md_inst/duke3d" "-j$romdir/ports/duke3d -addon 0"

    if [[ "$md_mode" != "install" ]]; then
        return
    fi
    game_data_jfduke3d

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
