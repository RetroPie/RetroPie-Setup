#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="frotz"
rp_module_desc="Z-Machine Interpreter for Infocom games"
rp_module_help="ROM Extensions: .dat .zip .z1 .z2 .z3 .z4 .z5 .z6 .z7 .z8\n\nCopy your Infocom roms to $romdir/zmachine"
rp_module_section="opt"
rp_module_flags="!mali"

function install_bin_frotz() {
    aptInstall frotz
}

function remove_frotz() {
    aptRemove frotz
}

function configure_frotz() {
    mkRomDir "zmachine"

    rm -rf "$romdir/zmachine/zork"[1-3]
    local file
    for file in zork1 zork2 zork3; do
        wget $__archive_url/$file.zip
        unzip -L -n "$file.zip" "data/$file.dat"
        mv "data/$file.dat" "$romdir/zmachine/"
        rm $file.zip
    done
    rmdir data

    chown -R $user:$user "$romdir/zmachine/"*

    # CON: to stop runcommand from redirecting stdout to log
    addSystem 1 "$md_id" "zmachine" "CON:pushd $romdir/zmachine; frotz %ROM%; popd" "Z-machine" ".dat .zip .z1 .z2 .z3 .z4 .z5 .z6 .z7 .z8"
}
