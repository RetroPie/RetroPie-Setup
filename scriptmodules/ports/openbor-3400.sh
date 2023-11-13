#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openbor-3400"
rp_module_desc="OpenBOR - Beat 'em Up Game Engine v3400 (unsupported!)"
rp_module_help="Place your pak files in $romdir/ports/openbor and run OpenBOR - Beats of Rage Engine script. You can also setup a own BOR-system into ES. This version is patched to call PAK files via CLI."
rp_module_licence="BSD https://raw.githubusercontent.com/crcerror/OpenBOR-3400/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!mali !x11 !kms"

function strip() {
    #$1 string name, $2 string length to cut
    # Set string length to -5 to remove last 5 characters
    # So openbor-3400 will be installed to openbor
    echo "${1:0:$2}"
}

function depends_openbor-3400() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev libogg-dev libvorbisidec-dev libvorbis-dev libpng-dev zlib1g-dev
}

function sources_openbor-3400() {
    gitPullOrClone "$md_build" https://github.com/crcerror/OpenBOR-3400.git
}

function build_openbor-3400() {
    make clean
    make
    md_ret_require="$md_build/OpenBOR"
}

function install_openbor-3400() {
    md_ret_files=(
       'OpenBOR'
    )
}

function configure_openbor-3400() {
    addPort "$md_id" "openbor" "OpenBOR - Beats of Rage Engine" "pushd $md_inst; $md_inst/OpenBOR %ROM%; popd"

    md_id="$(strip $md_id -5)"
    mkRomDir "ports/$md_id"

    local dir
    for dir in ScreenShots Saves; do
        mkUserDir "$md_conf_root/$md_id/$dir"
        ln -snf "$md_conf_root/$md_id/$dir" "$md_inst/$dir"
    done

    ln -snf "$romdir/ports/$md_id" "$md_inst/Paks"
    ln -snf "/dev/shm" "$md_inst/Logs"
}
