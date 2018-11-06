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
rp_module_licence="MIT https://raw.githubusercontent.com/sselph/scraper/master/LICENSE"
rp_module_section="opt"
rp_module_flags="nobin"

function depends_scraper() {
    rp_callModule golang install_bin
}

function sources_scraper() {
    local goroot="$(_get_goroot_golang)"
    GOPATH="$md_build" GOROOT="$goroot" "$goroot/bin/go" get -u github.com/sselph/scraper
}

function build_scraper() {
    local goroot="$(_get_goroot_golang)"
    GOPATH="$md_build" GOROOT="$goroot" "$goroot/bin/go" build github.com/sselph/scraper
}

function install_scraper() {
    md_ret_files=(
        'scraper'
        'src/github.com/sselph/scraper/LICENSE'
        'src/github.com/sselph/scraper/README.md'
        'src/github.com/sselph/scraper/hash.csv'
    )
}

function remove_scraper() {
    rp_callModule golang remove
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
    [[ -z "$system" ]] && return

    iniConfig " = " '"' "$configdir/all/scraper.cfg"
    eval $(_load_config_scraper)

    local gamelist
    local img_dir
    local img_path
    if [[ "$use_rom_folder" -eq 1 ]]; then
        gamelist="$romdir/$system/gamelist.xml"
        img_dir="$romdir/$system/images"
        img_path="./images"
    else
        gamelist="$home/.emulationstation/gamelists/$system/gamelist.xml"
        img_dir="$home/.emulationstation/downloaded_images/$system"
        img_path="~/.emulationstation/downloaded_images/$system"
    fi

    local params=()
    params+=(-image_dir "$img_dir")
    params+=(-image_path "$img_path")
    params+=(-video_dir "$img_dir")
    params+=(-video_path "$img_path")
    params+=(-marquee_dir "$img_dir")
    params+=(-marquee_path "$img_path")
    params+=(-output_file "$gamelist")
    params+=(-rom_dir "$romdir/$system")
    params+=(-workers "4")
    params+=(-skip_check)
    if [[ "$use_thumbs" -eq 1 ]]; then
        params+=(-thumb_only)
    fi
    if [[ "$screenshots" -eq 1 ]]; then
        if [[ "$system" =~ ^mame-|arcade|fba|neogeo ]]; then
            params+=(-mame -mame_img s,m,t)
        else
            params+=(-console_img "s,b,3b,l,f")
        fi
    fi
    if [[ "$download_videos" -eq 1 ]]; then
        params+=(-download_videos)
    fi
    if [[ "$download_marquees" -eq 1 ]]; then
        params+=(-download_marquees)
    fi
    if [[ -n "$max_width" ]]; then
        params+=(-max_width "$max_width")
    fi
    if [[ -n "$max_height" ]]; then
        params+=(-max_height "$max_height")
    fi
    if [[ "$console_src" -eq 0 ]]; then
        params+=(-console_src="ovgdb")
    elif [[ "$console_src" -eq 1 ]]; then
        params+=(-console_src="gdb")
    else
        params+=(-console_src="ss")
    fi
    if [[ "$mame_src" -eq 0 ]]; then
        params+=(-mame_src="mamedb")
    elif [[ "$mame_src" -eq 1 ]]; then
        params+=(-mame_src="ss")
    else
        params+=(-mame_src="adb")
    fi
    if [[ "$rom_name" -eq 1 ]]; then
        params+=(-use_nointro_name=false)
    elif [[ "$rom_name" -eq 2 ]]; then
        params+=(-use_filename=true)
    fi
    if [[ "$append_only" -eq 1 ]]; then
        params+=(-append)
    fi

    [[ "$system" =~ ^mame-|arcade|fba|neogeo ]] && params+=(-mame -mame_img t,m,s)

    # trap ctrl+c and return if pressed (rather than exiting retropie-setup etc)
    trap 'trap 2; return 1' INT
    sudo -u $user "$md_inst/scraper" ${params[@]}
    trap 2
}

function scrape_all_scraper() {
    local system
    while read system; do
        system=${system/$romdir\//}
        scrape_scraper "$system" "$@" || return 1
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

    local cmd=(dialog --backtitle "$__backtitle" --checklist "Select ROM Folders" 22 76 16)
    local choice=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    [[ ${#choice[@]} -eq 0 ]] && return

    local choice
    for choice in "${choice[@]}"; do
        choice=${options[choice*3-2]}
        scrape_scraper "$choice" "$@"
    done
}

function _load_config_scraper() {
    echo "$(loadModuleConfig \
        'use_thumbs=1' \
        'screenshots=0' \
        'max_width=400' \
        'max_height=400' \
        'console_src=1' \
        'mame_src=2' \
        'rom_name=0' \
        'append_only=0' \
        'use_rom_folder=0' \
        'download_videos=0' \
        'download_marquees=0' \
    )"
}

function gui_scraper() {
    if pgrep "emulationstatio" >/dev/null; then
        printMsgs "dialog" "This scraper must not be run while Emulation Station is running or the scraped data will be overwritten. \n\nPlease quit from Emulation Station, and run RetroPie-Setup from the terminal"
        return
    fi

    iniConfig " = " '"' "$configdir/all/scraper.cfg"
    eval $(_load_config_scraper)
    chown $user:$user "$configdir/all/scraper.cfg"

    local default
    while true; do
        local ver=$(get_ver_scraper)
        [[ -z "$ver" ]] && ver="v(Git)"
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Scraper $ver by Steven Selph" 22 76 16)
        local options=(
            1 "Scrape all systems"
            2 "Scrape chosen systems"
        )

        if [[ "$use_thumbs" -eq 1 ]]; then
            options+=(3 "Thumbnails only (Enabled)")
        else
            options+=(3 "Thumbnails only (Disabled)")
        fi

        if [[ "$screenshots" -eq 1 ]]; then
            options+=(4 "Prefer screenshots (Enabled)")
        else
            options+=(4 "Prefer screenshots (Disabled)")
        fi

        if [[ "$mame_src" -eq 0 ]]; then
            options+=(5 "Arcade Source (MameDB)")
        elif [[ "$mame_src" -eq 1 ]]; then
            options+=(5 "Arcade Source (ScreenScraper)")
        else
            options+=(5 "Arcade Source (ArcadeItalia)")
        fi

        if [[ "$console_src" -eq 0 ]]; then
            options+=(6 "Console Source (OpenVGDB)")
        elif [[ "$console_src" -eq 1 ]]; then
            options+=(6 "Console Source (thegamesdb)")
        else
            options+=(6 "Console Source (ScreenScraper)")
        fi

        if [[ "$rom_name" -eq 0 ]]; then
            options+=(7 "ROM Names (No-Intro)")
        elif [[ "$rom_name" -eq 1 ]]; then
            options+=(7 "ROM Names (theGamesDB)")
        else
            options+=(7 "ROM Names (Filename)")
        fi

        if [[ "$append_only" -eq 1 ]]; then
            options+=(8 "Gamelist (Append)")
        else
            options+=(8 "Gamelist (Overwrite)")
        fi

        if [[ "$use_rom_folder" -eq 1 ]]; then
            options+=(9 "Use rom folder for gamelist & images (Enabled)")
        else
            options+=(9 "Use rom folder for gamelist & images (Disabled)")
        fi

        if [[ "$download_videos" -eq 1 ]]; then
            options+=(V "Download Videos (Enabled)")
        else
            options+=(V "Download Videos (Disabled)")
        fi

        if [[ "$download_marquees" -eq 1 ]]; then
            options+=(M "Download Marquees (Enabled)")
        else
            options+=(M "Download Marquees (Disabled)")
        fi

        options+=(W "Max image width ($max_width)")
        options+=(H "Max image height ($max_height)")

        options+=(U "Update scraper to the latest version")
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    if scrape_all_scraper; then
                        printMsgs "dialog" "ROMS have been scraped."
                    else
                        printMsgs "dialog" "Scraping was aborted"
                    fi
                    ;;
                2)
                    if scrape_chosen_scraper; then
                        printMsgs "dialog" "ROMS have been scraped."
                    else
                        printMsgs "dialog" "Scraping was aborted"
                    fi
                    ;;
                3)
                    use_thumbs="$((use_thumbs ^ 1))"
                    iniSet "use_thumbs" "$use_thumbs"
                    ;;
                4)
                    screenshots="$((screenshots ^ 1))"
                    iniSet "screenshots" "$screenshots"
                    ;;
                5)
                    mame_src="$((( mame_src + 1) % 3))"
                    iniSet "mame_src" "$mame_src"
                    ;;
                6)
                    console_src="$((( console_src + 1) % 3))"
                    iniSet "console_src" "$console_src"
                    ;;
                7)
                    rom_name="$((( rom_name + 1 ) % 3))"
                    iniSet "rom_name" "$rom_name"
                    ;;
                8)
                    append_only="$((append_only ^ 1))"
                    iniSet "append_only" "$append_only"
                    ;;
                9)
                    use_rom_folder="$((use_rom_folder ^ 1))"
                    iniSet "use_rom_folder" "$use_rom_folder"
                    ;;
                V)
                    download_videos="$((download_videos ^ 1))"
                    iniSet "download_videos" "$download_videos"
                    ;;
                M)
                    download_marquees="$((download_marquees ^ 1))"
                    iniSet "download_marquees" "$download_marquees"
                    ;;
                H)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the max image height in pixels" 10 60 "$max_height")
                    max_height=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "max_height" "$max_height"
                    ;;
                W)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the max image width in pixels" 10 60 "$max_width")
                    max_width=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "max_width" "$max_width"
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
