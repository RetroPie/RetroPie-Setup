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
rp_module_menus="3+gui"
rp_module_flags="nobin"

function depends_scraper() {
    if [[ "$__raspbian_ver" -gt "7" ]]; then
        getDepends golang
    fi
}

function sources_scraper() {
    if [[ "$__raspbian_ver" -gt "7" ]]; then
        GOPATH="$md_build" go get github.com/sselph/scraper
    fi
}

function build_scraper() {
    if [[ "$__raspbian_ver" -gt "7" ]]; then
        GOPATH="$md_build" go build github.com/sselph/scraper
    fi
}

function install_scraper() {
    if [[ "$__raspbian_ver" -gt "7" ]]; then
        md_ret_files=(scraper)
    elif isPlatform "arm"; then
        local ver="$(latest_ver_scraper)"
        mkdir -p "$md_build"
        local name="scraper_rpi.zip"
        isPlatform "neon" && name="scraper_rpi2.zip"
        wget -O "$md_build/scraper.zip" "https://github.com/sselph/scraper/releases/download/$ver/$name"
        unzip -o "$md_build/scraper.zip" -d "$md_inst"
        rm -f "$md_build/scraper.zip"
    fi
}

function get_ver_scraper() {
    [[ -f "$md_inst/scraper" ]] && "$md_inst/scraper" -version 2>/dev/null
}

function latest_ver_scraper() {
    wget -qO- https://api.github.com/repos/sselph/scraper/releases/latest | grep -m 1 tag_name | cut -d\" -f4
}

function list_systems_scraper() {
    find -L "$romdir" -mindepth 1 -maxdepth 1 -not -empty -type d | sort
}

function scrape_scraper() {
    local system="$1"
    local use_thumbs="$2"
    local max_width="$3"
    [[ -z "$system" ]] && return
    local gamelist="$home/.emulationstation/gamelists/$system/gamelist.xml"
    local img_path="$home/.emulationstation/downloaded_images/$system"
    local params=()
    params+=(-image_dir "$img_path")
    params+=(-image_path "$img_path")
    params+=(-output_file "$gamelist")
    params+=(-rom_dir "$romdir/$system")
    params+=(-workers "4")
    params+=(-skip_check)
    if [[ "$use_thumbs" -eq 1 ]]; then
        params+=(-thumb_only)
    fi
    if [[ -n "$max_width" ]]; then
        params+=(-max_width "$max_width")
    fi
    if [[ "$use_gdb_scraper" -eq 1 ]]; then
        params+=(-use_gdb)
    else
        params+=(-use_ovgdb)
    fi
    
    [[ "$system" =~ ^mame-|arcade|fba|neogeo ]] && params+=(-mame -mame_img t,m,s)
    sudo -u $user "$md_inst/scraper" ${params[@]}
}

function scrape_all_scraper() {
    local system
    while read system; do
        system=${system/$romdir\//}
        scrape_scraper "$system" "$@"
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
        scrape_scraper "$choice" "$@"
    done
}

function gui_scraper() {
    if pgrep "emulationstatio" >/dev/null; then
        printMsgs "dialog" "This scraper must not be run while Emulation Station is running or the scraped data will be overwritten. \n\nPlease quit from Emulation Station, and run RetroPie-Setup from the terminal"
        return
    fi

    if [[ ! -d "$md_inst" ]]; then
        rp_callModule "$md_id"
    fi

    local use_thumbs=1
    local max_width=400
    local use_gdb_scraper=1

    while true; do
        local ver=$(get_ver_scraper)
        [[ -z "$ver" ]] && ver="v(Git)"
        local cmd=(dialog --backtitle "$__backtitle" --menu "Scraper $ver by Steven Selph" 22 76 16) 
        local options=( 
            1 "Scrape all systems" 
            2 "Scrape chosen systems"
        )

        if [[ "$use_thumbs" -eq 1 ]]; then
            options+=(3 "Thumbnails only (Enabled)")
        else
            options+=(3 "Thumbnails only (Disabled)")
        fi

        options+=(4 "Max image width ($max_width)")
        
        if [[ "$use_gdb_scraper" -eq 1 ]]; then
            options+=(5 "Scraper (thegamesdb)")
        else
            options+=(5 "Scraper (OpenVGDB)")
        fi
        
        options+=(U "Update scraper to the latest version")
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) 
        if [[ -n "$choice" ]]; then 
            case $choice in 
                1) 
                    rp_callModule "$md_id" scrape_all $use_thumbs $max_width
                    printMsgs "dialog" "ROMS have been scraped."
                    ;;
                2) 
                    rp_callModule "$md_id" scrape_chosen $use_thumbs $max_width
                    printMsgs "dialog" "ROMS have been scraped."
                    ;;
                3)
                    use_thumbs="$((use_thumbs ^ 1))"
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the max image width in pixels" 10 60 "$max_width")
                    max_width=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                5)
                    use_gdb_scraper="$((use_gdb_scraper ^ 1))"
                    ;;
                U)
                    rp_callModule "$md_id"
                    ;;
            esac 
        else 
            break 
        fi 
    done 
}
