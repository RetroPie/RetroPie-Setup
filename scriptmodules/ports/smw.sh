#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed wit this distribution.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="smw"
rp_module_desc="Super Mario War"
rp_module_menus="2+"

function depends_smw() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev
}

function sources_smw() {
    gitPullOrClone "$md_build" https://github.com/HerbFargus/Super-Mario-War.git
}

function build_smw() {
    ./configure --prefix="$md_inst"
    make clean
    make
}

function install_smw() {
    make install
}

function configure_smw() {
    mkRomDir "ports"

    cat > "$romdir/ports/Super Mario War.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 0 "$md_inst/smw" "$md_id"
_EOF_

    chmod +x "$romdir/ports/Super Mario War.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
