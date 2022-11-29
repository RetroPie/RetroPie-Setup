#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retroscraper"
rp_module_desc="Scraper for EmulationStation by kiro"
rp_module_licence="GNU https://github.com/zayamatias/retroscraper-rpie/blob/main/LICENSE"
rp_module_repo="git https://github.com/zayamatias/retroscraper-rpie.git main"
rp_module_section="opt"

function depends_retroscraper() {
    local depends=(python3)
    getDepends "${depends[@]}"
}

function sources_retroscraper() {
    gitPullOrClone
}

function build_retroscraper() {
pip=$( su $user -c "python3 -c 'import pip'" 2>&1 )
succ="ModuleNotFoundError"
echo "----------------------------------"
echo "$pip"
if [[ $pip == *"$succ"* ]]; then
   su $user -c "wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py"
   su $user -c "python3 /tmp/get-pip.py"
fi
   su $user -c "python3 -m pip install --user --upgrade pip wheel setuptools"
   su $user -c "python3 -m pip install --user -r $md_inst/dependencies.txt"
}

function install_retroscraper() {
    md_ret_files=(
    'apicalls.py'
	'checksums.py'
	'LICENSE'
	'README.md'
	'dependencies.txt'
	'retroscraper.py'
	'scrapfunctions.py'
    'setup.sh'
    )
}

function get_ver_retroscraper() {
    [[ -f "$md_inst/retroscraper.py" ]] && su $user -c 'python3 $md_inst/retroscraper.py --appver' 2>/dev/null
}

function latest_ver_retroscraper() {
    download https://api.github.com/repos/zayamatias/retroscraper-rpie/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function list_systems_retroscraper() {
    su $user -c "python3 $md_inst/retroscraper.py --listsystems"
}

function list_langs_retroscraper(){
    su $user -c "python3 $md_inst/retroscraper.py --listlangs"
}



function scrape_retroscraper() {
    local system="$1"
    local params

       if [[ ! -z "$system" ]]; then
        params="--systems $system"
    fi
   
    if [[ ! -z "$lang" ]]; then
        params+=" --language $lang"
    fi

    if [[ "$googletrans" -eq 1 ]]; then
        params+=" --google"
    fi

    if [[ "$nobackup" -eq 1 ]]; then
        params+=" --nobackup"
    fi

    if [[ "$relativepaths" -eq 1 ]]; then
        params+=" --relativepaths"
    fi

    if [[ ! -z "$mediadir" ]]; then
        params+=" --mediadir $mediadir"
    fi

    if [[ "$keepdata" -eq 1 ]]; then
        params+=" --keepdata"
    fi

    if [[ "$preferbox" -eq 1 ]]; then
        params+=" --preferbox"
    fi

    if [[ "$novideodown" -eq 1 ]]; then
        params+=" --novideodown"
    fi

    if [[ "$country" -eq 1 ]]; then
        params+=" --country"
    fi

    if [[ "$disk" -eq 1 ]]; then
        params+=" --disk"
    fi

    if [[ "$version" -eq 1 ]]; then
        params+=" --version"
    fi

    if [[ "$hack" -eq 1 ]]; then
        params+=" --hack"
    fi

    if [[ "$brackets" -eq 1 ]]; then
        params+=" --brackets"
    fi

    if [[ "$bezels" -eq 1 ]]; then
        params+=" --bezels"
    fi

    if [[ "$sysbezels" -eq 1 ]]; then
        params+=" --sysbezels"
    fi

    if [[ "$cleanmedia" -eq 1 ]]; then
        params+=" --cleanmedia"
    fi

    echo "$params"

    # trap ctrl+c and return if pressed (rather than exiting retropie-setup etc)
    trap 'trap 2; return 1' INT
    #echo "su -c  python3 -u $md_inst/retroscraper.py ${params[@]} $user 2>&1 | dialog --backtitle "$__backtitle" --progressbox Scraping 22 76" > /tmp/test.txt
    local cmd=(dialog --backtitle "$__backtitle" --prgbox "Scraping roms with RetroScraper" "su $user -c  'python3 $md_inst/retroscraper.py ${params[@]}'" 22 76)
    local choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    trap 2
}

function scrape_chosen_retroscraper() {
    local options=()
    local system
    local i=1
    while read system; do
        system=${system/$romdir\//}
        options+=($i "$system" OFF)
        ((i++))
    done < <(list_systems_retroscraper)

    local cmd=(dialog --backtitle "$__backtitle" --checklist "Select Systems" 22 76 16)
    local choice=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    [[ ${#choice[@]} -eq 0 ]] && return

    local choices
    for choice in "${choice[@]}"; do
        choices+="${options[choice*3-2]},"
    done
    scrape_retroscraper "$choices" "$@"
}

function select_lang_retroscraper(){
    local options=()
    local language
    local i=1
    local lan
    while IFS=',' read -r short desc
    do
        options+=("$short" "$desc" OFF)
    done < <(list_langs_retroscraper)

    local cmd=(dialog --backtitle "$__backtitle" --radiolist "Select Language" 22 76 16)
    local choice=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    [[ ${#choice[@]} -eq 0 ]] && return

    #local choices
    #for choice in "${choice[@]}"; do
    #    choices="${options[choice*3-2]},"
    #done
    echo "$choice"
}

function _load_config_retroscraper() {
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

function gui_retroscraper() {
    if pgrep "emulationstatio" >/dev/null; then
        printMsgs "dialog" "This scraper must not be run while Emulation Station is running or the scraped data will be overwritten. \n\nPlease quit from Emulation Station, and run RetroPie-Setup from the terminal"
        return
    fi

    iniConfig " = " '"' "$configdir/all/retroscraper.cfg"
    eval $(_load_config_retroscraper)
    chown $user:$user "$configdir/all/retroscraper.cfg"

    local default
    while true; do
        local ver=$(get_ver_retroscraper)
        [[ -z "$ver" ]] && ver="v(Git)"
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "RetroScraper $ver by kiro" 22 76 16)
        local options=(
            1 "Scrape all systems"
            2 "Scrape chosen systems"
        )

        if [[ -z "$lang" ]]; then
            options+=(L "Selected Language: en")
        else
            options+=(L "Selected Language: $lang")
        fi
        if [[ "$googletrans" -eq 0 ]]; then
            options+=(G "Do not use google translate")
        else
            options+=(G "Use google translate for not found synopsis in selected language")
        fi

        if [[ "$nobackup" -eq 1 ]]; then
            options+=(3 "Do not backup gamelists")
        else
            options+=(3 "Backup gamelists")
        fi

        if [[ "$relativepaths" -eq 0 ]]; then
            options+=(4 "Use absolute paths in gamelists")
        else
            options+=(4 "Use relative paths in gamelists")
        fi

        if [[ -z "$mediadir" ]]; then
            options+=(M "Use default media directories (images,videos,marquees)")
        else
            options+=(M "Use custom single folder for images $mediadir")
        fi

        if [[ "$keepdata" -eq 0 ]]; then
            options+=(5 "Discard last played/favorite data")
        else
            options+=(5 "Keep last played/favorite data")
        fi

        if [[ "$preferbox" -eq 0 ]]; then
            options+=(6 "Prefer screenshot as images")
        else
            options+=(6 "Prefer boxes as images")
        fi

        if [[ "$novideodown" -eq 0 ]]; then
            options+=(7 "Download videos")
        else
            options+=(7 "Do not download videos")
        fi

        if [[ "$country" -eq 0 ]]; then
            options+=(8 "Do not add country decorator from filename")
        else
            options+=(8 "Add country decorator from filename")
        fi

        if [[ "$disk" -eq 0 ]]; then
            options+=(9  "Do not add disk decorator from filename")
        else
            options+=(9 "Add disk decorator from filename")
        fi

        if [[ "$version" -eq 0 ]]; then
            options+=(A "Do not add version decorator from filename")
        else
            options+=(A "Add version decorator from filename")
        fi

        if [[ "$hack" -eq 0 ]]; then
            options+=(B  "Do not add hack decorator from filename")
        else
            options+=(B "Add hack decorator from filename")
        fi

        if [[ "$brackets" -eq 0 ]]; then
            options+=(C  "Do not add info between brackets [] decorator from filename")
        else
            options+=(C  "Add info between brackets [] decorator from filename")
        fi
        if [[ "$bezels" -eq 0 ]]; then
            options+=(D  "Do not download Bezels for games")
        else
            options+=(D  "Download Bezels for games")
        fi
        if [[ "$sysbezels" -eq 0 ]]; then
            options+=(E  "Do not download system bezel if no game bezel found")
        else
            options+=(E  "Download system bezel if no game bezel found")
        fi
        if [[ "$cleanmedia" -eq 0 ]]; then
            options+=(F  "Do not delete existing media")
        else
            options+=(F  "Delete existing media")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    scrape_retroscraper
                    ;;
                2)
                    scrape_chosen_retroscraper
                    ;;
                L)
                    lang=$(select_lang_retroscraper)
                    iniSet "lang" "$lang"
                    ;;
                G)
                    googletrans="$((googletrans ^ 1))"
                    iniSet "googletrans" "$googletrans"
                    ;;
 
		        3)
                    nobackup="$((nobackup ^ 1))"
                    iniSet "nobackup" "$nobackup"
                    ;;
                4)
                    relativepaths="$((relativepaths ^ 1))"
                    iniSet "relativepaths" "$relativepaths"
                    ;;
                M)
                    local cmd=(dialog --backtitle "$__backtitle" --inputbox "Enter custom media directory" 22 76 $mediadir)
                    mediadir=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "mediadir" "$mediadir"
                    ;;
                5)
                    keepdata="$((keepdata ^1))"
                    iniSet "keepdata" "$keepdata"
                    ;;
                6)
                    preferbox="$((preferbox ^ 1))"
                    iniSet "preferbox" "$preferbox"
                    ;;
                7)
                    novideodown="$((novideodown ^ 1))"
                    iniSet "novideodown" "$novideodown"
                    ;;
                8)
                    country="$((country ^ 1))"
                    iniSet "country" "$country"
                    ;;
                9)
                    disk="$((disk ^ 1))"
                    iniSet "disk" "$disk"
                    ;;
                A)
                    version="$((version ^ 1))"
                    iniSet "version" "$version"
                    ;;
                B)
                    hack="$((hack ^ 1))"
                    iniSet "hack" "$hack"
                    ;;
                C)
                    brackets="$((brackets ^ 1))"
                    iniSet "brackets" "$brackets"
                    ;;
                D)
                    bezels="$((bezels ^ 1))"
                    iniSet "bezels" "$bezels"
                    ;;
                E)
                    sysbezels="$((sysbezels ^ 1))"
                    iniSet "sysbezels" "$sysbezels"
                    ;;
                F)
                    cleanmedia="$((cleanmedia ^ 1))"
                    iniSet "cleanmedia" "$cleanmedia"
                    ;;

            esac
        else
            break
        fi
    done
}
