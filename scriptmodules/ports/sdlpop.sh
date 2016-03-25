#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
 
rp_module_id="sdlpop"
rp_module_desc="SDLPoP - Port of Prince of Persia"
rp_module_menus="4+"
rp_module_flags=""

function depends_sdlpop() {
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev
}
 
function sources_sdlpop() {
    gitPullOrClone "$md_build" https://github.com/NagyD/SDLPoP.git
}
 
function build_sdlpop() {
    make
    md_ret_require="$md_build/prince"
}
 
function install_sdlpop() {
    md_ret_files=(
        'prince'
        'data'
        'doc/Readme.txt'
        'doc/gpl-3.0.txt'
    )
    cp -v "SDLPoP.ini" "$md_inst/SDLPoP.ini.def"
    sed -i "s/use_correct_aspect_ratio = false/use_correct_aspect_ratio = true/" "$md_inst/SDLPoP.ini.def"
    cp -v *.DAT "$md_inst"
}
 
function configure_sdlpop() {
    addPort "$md_id" "sdlpop" "Prince of Persia" "pushd $md_inst; $md_inst/prince full; popd"

    moveConfigFile "$md_inst/SDLPoP.ini" "$md_conf_root/$md_id/SDLPoP.ini"

    if [[ ! -f "$md_conf_root/$md_id/SDLPoP.ini" ]]; then
        cp -v "$md_inst/SDLPoP.ini.def" "$md_conf_root/$md_id/SDLPoP.ini"
    fi
    chown -R $user:$user "$md_conf_root/$md_id"
}
