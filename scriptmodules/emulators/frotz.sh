#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="frotz"
rp_module_desc="Z-Machine Interpreter for Infocom games"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_frotz() {
    aptInstall frotz
}

function configure_frotz() {
    mkRomDir "zmachine"

    rm -rf "$romdir/zmachine/zork"[1-3]
    local file
    for file in zork1 zork2 zork3; do
        wget http://downloads.petrockblock.com/retropiearchives/$file.zip
        unzip -L -n "$file.zip" "data/$file.dat"
        mv "data/$file.dat" "$romdir/zmachine/"
        rm $file.zip
    done
    rmdir data

    chown -R $user:$user "$romdir/zmachine/"*

    addSystem 1 "$md_id" "zmachine" "frotz %ROM%" "Z-machine" ".dat"
}