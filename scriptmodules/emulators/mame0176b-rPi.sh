#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mame0176b-rPi"
rp_module_desc="MAME v0.176b-rPi"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME v0.176b-rPi roms to either $romdir/mame-mame0176b-rPi or\n$romdir/arcade"
rp_module_section="exp"
rp_module_flags="!x11 !mali"

function depends_mame0176b-rPi() {
    getDepends libasound2-dev libsdl1.2-dev libraspberrypi-dev qt5-default libsdl2-ttf-2.0-0
}

function install_bin_mame0176b-rPi() {
    local mame="mame0176b-rPi"

    # Download and unzip the binary file 
    wget "http://choccyhobnob.com/?d=1150" -O "$md_inst/$mame.zip"
    unzip -n "$md_inst/$mame.zip" -d "$md_inst"
    rm "$md_inst/$mame.zip"
    
    # The zip file gets unzipped into a subdirectory, so we need to move that back out
    mv "$md_inst/$mame"/* "$md_inst" 
    rmdir "$md_inst/$mame" 
    
    # This will give everyone permission to read the directories where MAME is
    find "$md_inst" -type d -exec chmod a+rx {} \;
}

function remove_mame0176b-rPi() {
    # Optionally you can remove configureation directories here
    #local system="mame-mame0176b-rPi"
    #rm -rf "$md_conf_root/$system/"
    #rm /home/pi/.mame
}

function configure_mame0176b-rPi() {
    local system="mame-mame0176b-rPi"
    mkRomDir "arcade"
    mkRomDir "$system"
    mkRomDir "$system/artwork"
    mkRomDir "$system/samples"

    if [[ "$md_mode" == "install" ]]; then
        #mkdir -p "$md_conf_root/$system/"{hi,memcard}
        mkdir -p "$md_conf_root/$system/"{cfg,nvram,inp,sta,snap,diff,comments}
        
        # Make a symbolic link for the MAME ini directory
        ln -s $md_conf_root/$system/ /home/pi/.mame

        # Create a new INI file
        local config="$(mktemp)"
        "$md_inst/mame" -showconfig >"$config"

        iniConfig " " "" "$config"
        iniSet "cfg_directory" "$md_conf_root/$system/cfg"
        iniSet "nvram_directory" "$md_conf_root/$system/nvram"
        iniSet "input_directory" "$md_conf_root/$system/inp"
        iniSet "state_directory" "$md_conf_root/$system/sta"
        iniSet "snapshot_directory" "$md_conf_root/$system/snap"
        iniSet "diff_directory" "$md_conf_root/$system/diff"
        iniSet "comment_directory" "$md_conf_root/$system/comments"

        #iniSet "hi_directory" "$md_conf_root/$system/hi"
        #iniSet "memcard_directory" "$md_conf_root/$system/memcard"

        iniSet "artpath" "$romdir/$system/artwork"
        iniSet "samplepath" "$romdir/$system/samples;$romdir/arcade/samples"
        iniSet "rompath" "$romdir/$system;$romdir/arcade"

        iniSet "samplerate" "44100"

        copyDefaultConfig "$config" "$md_conf_root/$system/mame.ini"
        rm "$config"

        chown -R $user:$user "$md_conf_root/$system"
        chmod a+r "$md_conf_root/$system/mame.ini"
    fi

    addSystem 0 "$md_id" "arcade" "$md_inst/mame %BASENAME%" "Multiple Arcade Machine Emulator" ".zip .ZIP"
    addSystem 1 "$md_id" "$system arcade mame" "$md_inst/mame %BASENAME%" "Multiple Arcade Machine Emulator" ".zip .ZIP"
}
