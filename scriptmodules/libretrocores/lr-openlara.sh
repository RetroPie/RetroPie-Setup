#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-openlara"
rp_module_desc="Tomb Raider engine - OpenLara port for libretro"
rp_module_help="ROM Extensions: .PHD .PNG .PSX .SAT .TR2\nAudio Extensions: .ogg .SFX\nVideo Extension: .RPL .FMV\n\nFor more information:\nhttps://docs.libretro.com/library/openlara/#directories"
rp_module_licence="BSD 2-Clause https://raw.githubusercontent.com/libretro/OpenLara/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-openlara() {
    gitPullOrClone "$md_build" https://github.com/libretro/OpenLara.git
}

function build_lr-openlara() {
    make clean
    make -C src/platform/libretro
    md_ret_require="$md_build/src/platform/libretro/openlara_libretro.so"
}

function install_lr-openlara() {
    md_ret_files=(
        'src/platform/libretro/openlara_libretro.so'
    )
}

function configure_lr-openlara() {
    local script
    setConfigRoot "ports"

    for i in audio level video; do
        for j in {1..3}; do
    	    mkRomDir "ports/tombraider/$i/$j"
        done
    done

    text="$romdir/ports/tombraider/README.txt"
    cat >"$text" << _EOF_
			Support from Tomb Raider 1 to 3

Folder		File Type(s)			Description
-----------     -----------------------------   -------------------------------------
audio/1/	track_XX.ogg or XXX.ogg		X represents a number
audio/2/	track_XX.ogg and MAIN.SFX	Both tracks and MAIN.SFX are required
audio/3/	cdaudio.wad and MAIN.SFX	Both tracks and MAIN.SFX are required
level/1/	.PNG and .PHD or .PSX or .SAT	Load-screens and levels
level/2/	.PNG and .TR2 or *.PSX		Load-screens and levels
level/3/	.PNG and .TR2 or *.PSX		Load-screens and levels
video/1/	.RPL or .FMV			Video cut-scenes
video/2/	.RPL or .FMV			Video cut-scenes
video/3/	.RPL or .FMV			Video cut-scenes
_EOF_
    chown $user:$user "$text"

    game_data_lr-openlara

    chown $user:$user -R "$romdir/ports/tombraider"

    declare -A games=(
        ['1']="Tomb Raider"
        ['2']="Tomb Raider II"
        ['3']="Tomb Raider III - Adventures of Lara Croft"
    )

    local dir
    local trpack
    for dir in "${!games[@]}"; do
        trpack="$romdir/ports/tombraider/level/$dir"
        if [[ -n $(find $trpack -name "*.*[^gG]") ]]; then
            addPort "$md_id" "tombraider" "${games[$dir]}" "$md_inst/openlara_libretro.so"
            local file="$romdir/ports/${games[$dir]}.sh"
            cat >"$file" << _EOF_
#!/bin/bash

scriptdir="\$HOME/RetroPie-Setup"
source "\$scriptdir/scriptmodules/helpers.sh"

joy2keyStart
let i=0 
W=() 
while read -r line; do
    let i=\$i+1
    W+=(\$i "\$line")
done < <( cd $romdir/ports/tombraider/level/$dir && ls -1 *.*[^gG] )
ROMS=\$(dialog --title "List of levels of game ${games[$dir]}" --menu "Chose one ROM" 24 80 17 "\${W[@]%.*}" 3>&2 2>&1 1>&3)
if [ "\$ROMS" == "" ]; then
    clear
    joy2keyStop
else
    joy2keyStop
    item=\$((\$ROMS*2-1)) 
    "/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "tombraider" "$romdir/ports/tombraider/level/$dir/\${W[\$item]}"
fi
_EOF_
            chown $user:$user "$file"
            chmod +x "$file"
        fi
    done

    ensureSystemretroconfig "ports/tombraider"
}
