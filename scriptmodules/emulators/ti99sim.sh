#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ti99sim"
rp_module_desc="TI-99/SIM - Texas Instruments Home Computer Emulator"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_ti99sim() {
    getDepends libsdl1.2-dev libssl-dev
}

function sources_ti99sim() {
    wget http://www.mrousseau.org/programs/ti99sim/archives/ti99sim-0.13.0.src.tar.gz
    tar -zxvf ./ti99sim-0.13.0.src.tar.gz
    rm ./ti99sim-0.13.0.src.tar.gz
}

function build_ti99sim() {
    cd ./ti99sim-0.13.0/
    make
}

function install_ti99sim() {
    md_ret_files=(
        'ti99sim-0.13.0/src/sdl/Release/ti99sim-sdl'
    )
}

function configure_ti99sim() {
    mkRomDir "ti99"
    moveConfigDir "$home/.ti99sim" "$md_conf_root/$md_id/"

    addSystem 1 "$md_id" "ti99" "pushd $romdir/ti99; $md_inst/ti99sim-sdl -f %ROM%; popd" "TI99" ".ctg .CTG"
    __INFMSGS+=("You will need to place your BIOS ROMs/carts into $romdir/ti99. Make sure that your TI-994A.ctg file is cased as shown here as the emulator is case-sensitive.")
}

