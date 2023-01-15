#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cgenius"
rp_module_desc="Commander Genius - Modern Interpreter for the Commander Keen Games (Vorticon and Galaxy Games)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gerstrong/Commander-Genius/master/COPYRIGHT"
rp_module_repo="git https://gitlab.com/Dringgstein/Commander-Genius.git v3.2.0"
rp_module_section="exp"

function depends_cgenius() {
    getDepends cmake libcurl4-openssl-dev libvorbis-dev libogg-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev
}

function sources_cgenius() {
    gitPullOrClone
}

function build_cgenius() {
    rmdir -fr build
    mkdir -p build && cd build
    cmake -DBUILD_COSMOS=1 -DNOTYPESAVE=on ..
    make
    md_ret_require="$md_build/build/src/CGeniusExe"
}

function install_cgenius() {
    md_ret_files=(
        'vfsroot'
        'build/src/CGeniusExe'
    )
}

function configure_cgenius() {
    addPort "$md_id" "cgenius" "Commander Genius" "pushd $md_inst; ./CGeniusExe; popd"

    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.CommanderGenius"  "$md_conf_root/$md_id"

    [[ $md_mode == "remove" ]] && return

    # Create a minimal config file so the Commander can find the games
    local config="$(mktemp)"
    cat > "$config" << _INI_
[FileHandling]
EnableLogfile = false
SearchPath1 = \${HOME}/.CommanderGenius
SearchPath2 = .
SearchPath3 = $romdir/ports/$md_id
_INI_
    copyDefaultConfig "$config" "$md_conf_root/$md_id/cgenius.cfg"

}
