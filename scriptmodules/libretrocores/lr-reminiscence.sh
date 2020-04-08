#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-reminiscence"
rp_module_desc="Flashback engine - Gregory Montoir’s Flashback emulator port for libretro"
rp_module_help="ROM Extensions: .map .aba .seq .lev\nAudio Extensions: .mod\nGame dialog: VOICE.VCE\n\nCopy your Flashback game files to $romdir/reminiscence"
rp_module_licence="GPL3"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-reminiscence() {
    local depends=(modplug-tools zlib1g-dev libsdl2-dev)
    getDepends "${depends[@]}"    
}

function sources_lr-reminiscence() {
    gitPullOrClone "$md_build" https://github.com/libretro/REminiscence.git
}

function build_lr-reminiscence() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/reminiscence_libretro.so"
}

function install_lr-reminiscence() {
    md_ret_files=(
	'README.md'
	'reminiscence_libretro.so'
    )
}

function configure_lr-reminiscence() {
    local script
    setConfigRoot "ports"

    addPort "$md_id" "reminiscence" "REminiscence" "$md_inst/reminiscence_libretro.so" 
    local file="$romdir/ports/REminiscence.sh"

    cat >"$file" << _EOF_
#!/bin/bash
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ reminiscence "$romdir/ports/reminiscence/"
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    mkRomDir "ports/reminiscence"
    ensureSystemretroconfig "ports/reminiscence"
}
