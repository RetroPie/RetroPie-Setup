#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="beebem"
rp_module_desc="BBC Micro Emulator"
rp_module_help="ROM Extensions: .ssd\n\nCopy your BBC Micro games to $romdir/bbcmicro\n\n"
rp_module_section="exp"
rp_module_flags=""

function depends_beebem() {
    getDepends autoconf automake
}

function sources_beebem() {
    gitPullOrClone "$md_build" https://github.com/sjnewbury/beebem-1
}

function build_beebem() {
    	aclocal
	autoconf
	autoheader
	automake --add-missing
    	./configure --enable-econet
	make
    	md_ret_require="$md_build/src/beebem"
}

function install_beebem() {
    md_ret_files=(
        'src/beebem'
    )
}

function configure_beebem() {
    mkRomDir "bbcmicro"
    addEmulator 1 "$md_id" "bbcmicro" "$md_inst/beebem %ROM%"
    addSystem "bbcmicro" "BBC Micro" ".ssd"

    [[ "$md_mode" == "remove" ]] && return
    cp -r "$md_build/data" "$md_inst"
    ln -sf "$md_inst/data" /usr/local/share/beebem
}
