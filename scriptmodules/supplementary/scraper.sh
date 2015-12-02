#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="scraper"
rp_module_desc="Scraper for EmulationStation by Steven Selph" 
rp_module_menus="4+configure"
rp_module_flags="nobin"

function install_scraper() {
    local ver=$(latest_ver_scraper)  
    mkdir -p "$md_build"
    local name="scraper_rpi.zip"
    isPlatform "rpi2" && name="scraper_rpi2.zip"
    wget -O "$md_build/scraper.zip" "https://github.com/sselph/scraper/releases/download/$ver/$name"
    unzip -o "$md_build/scraper.zip" -d "$md_inst"
    rm -f "$md_build/scraper.zip"
}

function get_ver_scraper() {
    [[ -f "$md_inst/scraper" ]] && "$md_inst/scraper" -version 2>/dev/null
}

function latest_ver_scraper() {
    wget -qO- https://api.github.com/repos/sselph/scraper/releases/latest | grep -m 1 tag_name | cut -d\" -f4
}

function list_systems_scraper() {
    find "$romdir" -mindepth 1 -maxdepth 1 -not -empty -type d
}

function scrape_scraper() {
    local system="$1"
    [[ -z "$system" ]] && return
    local gamelist="$home/.emulationstation/gamelists/$system/gamelist.xml"
    local img_path="$home/.emulationstation/downloaded_images/$system"
    local params=()
    params+=(-image_dir "$img_path")
    params+=(-image_path "$img_path")
    params+=(-output_file "$gamelist")
    params+=(-rom_dir "$romdir/$system")
    params+=(-workers "4")
    [[ "$system" =~ ^mame- ]] && params+=(-mame -mame_img t,m,s)
    sudo -u $user "$md_inst/scraper" ${params[@]} -thumb_only -skip_check
}

function scrape_all_scraper() {
    local system
    while read system; do
        system=${system/$romdir\//}
        scrape_scraper "$system"
    done < <(list_systems_scraper)
}

function scrape_chosen_scraper() {
    local options=()
    local system
    local i=1
    while read system; do
        system=${system/$romdir\//}
        options+=($i "$system" OFF)
        ((i++))
    done < <(list_systems_scraper)

    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No populated rom folders were found in $romdir."
        return
    fi

    local cmd=(dialog --separate-output --backtitle "$__backtitle" --checklist "Select ROM Folders" 22 76 16)
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    [[ ${#choices[@]} -eq 0 ]] && return

    local choice
    for choice in ${choices[@]}; do
        local index=$((choice*3-2))
        choice=${options[index]}
        scrape_scraper "$choice"
    done
}

function configure_scraper() {
    printMsgs "dialog" "Before running this scraper, make sure all EmulationStation processes are killed  with \"sudo killall emulationstation\" so that the gamelist.xml is written properly, otherwise the scraper changes may not be saved."
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule "$md_id" install
    fi

    while true; do
        local ver=$(get_ver_scraper)
        local cmd=(dialog --backtitle "$__backtitle" --menu "Scraper $ver by Steven Selph" 22 76 16) 
        local options=( 
            1 "Scrape all systems" 
            2 "Scrape chosen systems"
            3 "Update scraper to the latest version"
        ) 
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) 
        if [[ -n "$choice" ]]; then 
            case $choice in 
                1) 
                    rp_callModule "$md_id" scrape_all
                    printMsgs "dialog" "ROMS have been scraped."
                    ;;
                2) 
                    rp_callModule "$md_id" scrape_chosen
                    printMsgs "dialog" "ROMS have been scraped."
                    ;;
                3)
                    rp_callModule "$md_id" install
                    ;;
            esac 
        else 
            break 
        fi 
    done 
}
