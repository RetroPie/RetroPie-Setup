#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="skyscraper"
rp_module_desc="Scraper for EmulationStation by Lars Muldjord"
rp_module_licence="GPLv3.0 https://raw.githubusercontent.com/muldjord/skyscraper/master/LICENSE"
rp_module_section="exp"

function depends_skyscraper() {
    getDepends qt5-default p7zip-full
}

function sources_skyscraper() {
    gitPullOrClone "$md_build" "https://github.com/muldjord/skyscraper" "$(_latest_ver_skyscraper)"
}

function build_skyscraper() {
    qmake
    make
    md_ret_require="$md_build/Skyscraper"
}

function install_skyscraper() {
    md_ret_files=(
        'Skyscraper'
        'LICENSE'
        'README.md'
        'config.ini.example'
        'artwork.xml'
        'artwork.xml.example1'
        'artwork.xml.example2'
        'artwork.xml.example3'
        'artwork.xml.example4'
        'ARTWORK.md'
        'tgdb_developers.json'
        'tgdb_publishers.json'
        'mameMap.csv'
        'hints.txt'
        'dbs'
        'import'
        'resources'
    )
}

# Purge all Skyscraper caches
function _purge_skyscraper() {
    local platform

    while read platform; do
        # Find any folders underneath the Local DB cache and clear them
        _clear_platform_skyscraper "$platform"
    done < <(find "$configdir/all/skyscraper/dbs" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
}

function _clear_platform_skyscraper() {
    local platform="$1"

    [[ ! -d "$configdir/all/skyscraper/dbs/$platform" ]] && return

    # Remove any folder underneath the platform, try to keep any customized files
    pushd "$configdir/all/skyscraper/dbs/$platform"
    find . -maxdepth 1 -mindepth 1 -type d -print0 -exec rm -fr {} \;
    rm -f db.xml
    popd
}

# Purge by cached platform
function _purge_platform_skyscraper() {
    local options=()
    local system

    while read system; do
        # If there is no 'db.xml' file underneath the folder, skip it, it means folder is empty
        [[ ! -f "$configdir/all/skyscraper/dbs/$system/db.xml" ]] && continue

        # Get the size on disk of the system and show it in the select list
        local size=$(du -sh  "$configdir/all/skyscraper/dbs/$system" | cut -f1)
        options+=("$system" "$size" OFF)
    done < <(find "$configdir/all/skyscraper/dbs" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

    # If not folders are found, show an info message instead of the selection list
    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "Nothing to delete ! No cached systems found in \n$configdir/all/skyscraper/dbs "
        return
    fi

    local cmd=(dialog --backtitle "$__backtitle" --radiolist "Select platform to purge" 20 60 12)
    local platform=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    # Exit if no platform chosen
    [[ -z "$platform" ]] && return

    _clear_platform_skyscraper "$platform"
}

function _get_ver_skyscraper() {
    if [[ -f "$md_inst/Skyscraper" ]]; then
        echo $("$md_inst/Skyscraper" -h | grep 'Running Skyscraper'  | cut -d' '  -f 3 2>/dev/null)
    fi
}

function _latest_ver_skyscraper() {
    wget -qO- https://api.github.com/repos/muldjord/skyscraper/releases/latest | grep -m 1 tag_name | cut -d\" -f4
}

# List any non-empty system found in the ROM parent folder
function _list_systems_skyscraper() {
    find "$romdir"  -mindepth 2 -maxdepth 2 -type f -not -name '+*' | sed 's%/[^/]*$%%' | sort -u
}

function remove_skyscraper() {
    # On removal of package, purge the Local DB
    _purge_skyscraper
}

function configure_skyscraper() {
    if [[ "$md_mode" == "remove" ]]; then
        return
    fi

    # Check if this a first time install
    local local_config
    local_config=$(readlink -qn "$home/.skyscraper")

    # Handle the cases where the user has an existing Skyscraper installation.
    if [[ -d "$home/.skyscraper" && "$local_config" != "$configdir/all/skyscraper" ]]; then
        # We have an existing Skyscraper installation, but not handled by this scriptmodule.
        # Since the $HOME/.skyscraper folder will be moved, make sure the Local DB and Import folders are moved separately
        local f_size
        f_size=$(du --total -sm "$home/.skyscraper/dbs" "$home/.skyscraper/import" 2>/dev/null | grep total | cut -f 1 )
        printMsgs "console" "INFO: Moving the Local DB and Import folders to new configuration folder (total: $f_size Mb)"

        local folder
        for folder in dbs import; do
            mv "$home/.skyscraper/$folder" "$home/.skyscraper-$folder" && \
                printMsgs "console" "INFO: Moved "$home/.skyscraper/$folder" to "$home/.skyscraper-$folder""
        done

        # When having an existing installation, changes are the gamelist is in the ROMs folder
        # Create a GUI config file with this setting pre-set.
        iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
        iniSet "use_rom_folder" 1
    fi

    moveConfigDir "$home/.skyscraper" "$configdir/all/skyscraper"

    # When migrating an existing installation, make sure we move the Local DB and Import folder back the new conf folder
    for folder in dbs import; do
        if [[ -d "$home/.skyscraper-$folder" ]]; then
            printMsgs "console" "INFO: Moving "$home/.skyscraper-$folder" back to configuration folder"
            mv  "$home/.skyscraper-$folder" "$configdir/all/skyscraper/$folder"
        fi
    done

    _init_config_skyscraper
    chown -R $user:$user "$configdir/all/skyscraper"
}

function _init_config_skyscraper() {
    local md_conf_dir="$configdir/all/skyscraper"

    # Make sure the `artwork.xml` and other conf file(s) are present, but don't overwrite them on upgrades.
    # For now we just have one file, but more might come up in the future.
    local f_conf
    for f_conf in artwork.xml; do
        if [[ -f "$md_conf_dir/$f_conf" ]]; then
            cp "$md_inst/$f_conf" "$md_conf_dir/$f_conf.default"
        else
            cp "$md_inst/$f_conf" "$md_conf_dir"
        fi
    done

    # If we don't have a previous config.ini file, copy the example one
    [[ ! -f "$md_conf_dir/config.ini" ]] && cp "$md_inst/config.ini.example" "$md_conf_dir/config.ini"

    # Try to find the rest of the necesary files from the qmake build file
    # They should be listed in the `unix:examples.file` configuration line
    if [[ $(grep unix:examples.files "$md_build/skyscraper.pro" 2>/dev/null | cut -d= -f2-) ]]; then
        local files=$(grep unix:examples.files "$md_build/skyscraper.pro" | cut -d= -f2-)
        local file

        for file in $files; do
            # Copy the files to the configuration folder. Skip config.ini and artwork.xml, they're already handled
            if [[ $file != "artwork.xml" && $file != "config.ini" ]]; then
                cp -f "$md_build/$file" "$md_conf_dir"
            fi
        done
    else
        # Fallback to the known resource files list
        cp -f "$md_inst/artwork.xml.example"* "$md_conf_dir"

        # Copy resources
        local resource_file
        for resource_file in ARTWORK.md README.md mameMap.csv tgdb_developers.json tgdb_publishers.json hints.txt; do
            cp -f "$md_inst/$resource_file" "$md_conf_dir"
        done
    fi

    # Copy the rest of the folders
    cp -rf "$md_inst/resources" "$md_conf_dir"

    # Create the import folders and add the sample files.
    local folder
    for folder in covers marquees screenshots textual videos wheels; do
        mkUserDir "$md_conf_dir/import/$folder"
    done
    cp -rf "$md_inst/import" "$md_conf_dir"

    # Create the LocalDB cache folder and add the sample files
    mkUserDir "$md_conf_dir/dbs"
    cp -fr "$md_inst/dbs" "$md_conf_dir"
}

# Scrape one system, passed as parameter
function _scrape_skyscraper() {
    local system="$1"

    [[ -z "$system" ]] && return

    iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
    eval $(_load_config_skyscraper)

    local -a params=("--unattend" "--skipped")

    if [[ "$use_rom_folder" -eq 1 ]]; then
        params+=(-g "$romdir/$system")
        params+=(-o "$romdir/$system/media")
        # If we're saving to the ROM folder, then use relative paths in the gamelist
        params+=(--relative)
    else
        params+=(-g "$home/.emulationstation/gamelists/$system")
        params+=(-o "$home/.emulationstation/downloaded_media/$system")
    fi


    params+=(-p "$system")
    params+=(-s "$scrape_source")

    [[ "$download_videos" -eq 1 ]] && params+=(--videos)

    [[ "$cache_marquees" -eq 0 ]] && params+=(--nomarquees)

    [[ "$cache_covers" -eq 0 ]] && params+=(--nocovers)

    [[ "$cache_screenshots" -eq 0 ]] && params+=(--noscreenshots)

    [[ "$cache_wheels" -eq 0 ]] && params+=(--nowheels)

    [[ "$rom_name" -eq 1 ]] && params+=(--forcefilename)

    [[ "$remove_brackets" -eq 1 ]] && params+=(--nobrackets)

    [[ "$force_refresh" -eq 1 ]] && params+=(--refresh)

    # trap ctrl+c and return if pressed (rather than exiting retropie-setup etc)
    trap 'trap 2; return 1' INT
        sudo -u "$user" stdbuf -o0  "$md_inst/Skyscraper" "${params[@]}"
        echo -e "\nCOMMAND LINE USED:\n $md_inst/Skyscraper" "${params[@]}"
        sleep 2
    trap 2
}

# Scrape all systems
function _scrape_all_skyscraper() {
    local system

    while read system; do
        system=${system/$romdir\//}
        _scrape_skyscraper "$system" "$@" || return 1
    done < <(_list_systems_skyscraper)
}

# Scrape a list of systems, chosen by the user
function _scrape_chosen_skyscraper() {
    local options=()
    local system
    local i=1

    while read system; do
        system=${system/$romdir\//}
        options+=($i "$system" OFF)
        ((i++))
    done < <(_list_systems_skyscraper)

    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No populated ROM folders were found in $romdir."
        return
    fi

    local choices
    local cmd=(dialog --backtitle "$__backtitle" --checklist "Select ROM Folders" 22 76 16)

    choices=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    # Exit if nothing was chosen or Cancel was used
    [[ ${#choices[@]} -eq 0 || $? -eq 1 ]] && return 1

    local choice

    for choice in "${choices[@]}"; do
        choice="${options[choice*3-2]}"
        _scrape_skyscraper "$choice" "$@"
    done
}

function _load_config_skyscraper() {
    echo "$(loadModuleConfig \
        'rom_name=0' \
        'use_rom_folder=0' \
        'download_videos=0' \
        'cache_marquees=1' \
        'cache_covers=1' \
        'cache_wheels=1' \
        'cache_screenshots=1' \
        'scrape_source=screenscraper' \
        'remove_brackets=0' \
        'force_refresh=0'
    )"
}

# Try to guess the most appropriate editor. On Debian derivatives, we have `sensible-editor` for that.
function _open_editor_skyscraper() {
    local editor

    if [[ -n $(command -v sensible-editor) ]]; then
        sudo -u "$user" sensible-editor "$1" > /dev/tty < /dev/tty
    else
        editor="${EDITOR:-nano}"
        sudo -u "$user" $editor "$1" > /dev/tty < /dev/tty
    fi
}

function _gui_advanced_skyscraper() {
    local db_size
    local -A help_strings_adv

    iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
    eval $(_load_config_skyscraper)

    help_strings_adv=(
        [1]="Toggle whether screenshots are cached locally when scraping.\n\nSkyscraper option: \Zb--noscreenshots\Zn"
        [2]="Toggle whether covers are cached locally when scraping.\n\nSkyscraper option: \Zb--nocovers\Zn"
        [3]="Toggle whether wheels are cached locally when scraping.\n\nSkyscraper option: \Zb--nowheels\Zn"
        [4]="Toggle whether marquees are cached locally when scraping.\n\nSkyscraper option: \Zb--nomarquees\Zn"
        [E]="Opens the configuration file \Zbconfig.ini\Zn in an editor."
        [F]="Opens the artwork definition file \Zbartwork.xml\Zn in an editor."
        [P]="Purge \ZbALL\Zn all cached resources from the LocalDB."
        [S]="Purge all cached resources from the LocalDB for a chosen system."
    )

    while true; do
        db_size=$(du -sh "$configdir/all/skyscraper/dbs" 2>/dev/null | cut -f 1 || echo 0m)
        [[ -z "$db_size" ]] && db_size="0Mb"

        local cmd=(dialog --backtitle "$__backtitle" --help-button --colors --no-collapse --default-item "$default" --ok-label "Ok" --cancel-label "Back" --title "Advanced options and commands" --menu "\n  Local cache is currently at $db_size\n\n" 21 65 12)

        local options=("-" "LOCAL Cache")

        if [[ "$cache_screenshots" -eq 1 ]]; then
            options+=(1 "Cache screenshots (Enabled)")
        else
            options+=(1 "Cache screenshots (Disabled)")
        fi

        if [[ "$cache_covers" -eq 1 ]]; then
            options+=(2 "Cache covers (Enabled)")
        else
            options+=(2 "Cache covers (Disabled)")
        fi

        if [[ "$cache_wheels" -eq 1 ]]; then
            options+=(3 "Cache wheels (Enabled)")
        else
            options+=(3 "Cache wheels (Disabled)")
        fi

        if [[ "$cache_marquees" -eq 1 ]]; then
            options+=(4 "Cache marquees (Enabled)")
        else
            options+=(4 "Cache marquees (Disabled)")
        fi

        options+=("-" "PURGE commands")
        options+=(S "Purge system")
        options+=(P "Purge all (!)")

        options+=("-" "EXPERT - edit configurations")
        options+=(E "Edit 'config.ini'")
        options+=(F "Edit 'artwork.xml'")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty)

        if [[ -n "$choice" ]]; then
            local default=$choice

            case "$choice" in

                1)
                    cache_screenshots="$((cache_screenshots ^ 1))"
                    iniSet "cache_screenshots" "$cache_screenshots"
                    ;;

                2)
                    cache_covers="$((cache_covers ^ 1))"
                    iniSet "cache_covers" "$cache_covers"
                    ;;

                3)
                    cache_wheels="$((cache_wheels ^ 1))"
                    iniSet "cache_wheels" "$cache_wheels"
                    ;;

                4)
                    cache_marquees="$((cache_marquees ^ 1))"
                    iniSet "cache_marquees" "$cache_marquees"
                    ;;

                S)
                    _purge_platform_skyscraper
                    ;;

                P)
                    local confirm=$(dialog --clear --defaultno --colors --yesno  "\Z1\ZbAre you sure ?\Zn\nThis will \Zb\ZuERASE\Zn all locally cached scraped resources" 8 60 2>&1 >/dev/tty)
                    if [[ ! -n "$confirm" ]]; then
                        _purge_skyscraper
                    fi
                    ;;

                E)
                    _open_editor_skyscraper "$configdir/all/skyscraper/config.ini"
                    ;;

                F)
                    _open_editor_skyscraper "$configdir/all/skyscraper/artwork.xml"
                    ;;

                HELP*)
                    # Retain choice
                    default="${choice/HELP /}"
                    if [[ ! -z "${help_strings_adv[${default}]}" ]]; then
                    dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_adv[${default}]}" 22 65 >&1
                    fi
            esac
        else
            break
        fi
    done
}

function gui_skyscraper() {
    if pgrep "emulationstatio" >/dev/null; then
        printMsgs "dialog" "This scraper must not be run while Emulation Station is running or the scraped data will be overwritten. \n\nPlease quit from Emulation Station, and run RetroPie-Setup from the terminal"
        return
    fi

    iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
    eval $(_load_config_skyscraper)
    chown "$user":"$user" "$configdir/all/skyscraper.cfg"

    local -a s_source
    local -a s_source_names
    local -A help_strings

    s_source=([1]=screenscraper [2]=arcadedb [3]=thegamesdb [4]=igdb [5]=mobygames [6]=openretro [7]=worldofspectrum)
    s_source+=([10]=localdb [11]=import)

    s_source_names=([1]=ScreenScraper [2]=Arcade Database [3]=TheGamesDB [4]=IGDB [5]="Moby Games" [6]="OpenRetro" [7]="World of Spectrum")
    s_source_names+=([10]="LocalDB Cache" [11]="Import Folder")

    local default
    local ver

    # Help strings for this GUI
    help_strings=(
        [1]="Scrape all systems found in \Zb$romdir\Zn."
        [2]="Choose which systems to scrape from the ones found in \Zb$romdir\Zn."
        [3]="Select the source for ROM scraping. Supported sources:\n\ZbONLINE\Zn\n * ScreenScraper (screenscraper.fr)\n * TheGamesDB (thegamesdb.net)\n * OpenRetro (openretro.org)\n * ArcadeDB (adb.arcadeitalia.net)\n * Moby Games (mobygames.com)\n * IGDB (igdb.com)\n * World of Spectrum (worldofspectrum.org)\n\ZbLOCAL\Zn\n * LocalDB Cache (scrapes exclusively from cached resources)\n * Import (imports resources in the local cache)\n\n\Zb\ZrNOTE\Zn: Some sources require a username and password for access. These can be set per source in the \Zbconfig.ini\Zn configuration file.\n\n Skyscraper parameter: \Zb-s <source_name>\Zn"
        [4]="Game name format used in the Emulationstation gamelist. Available options:\n\n\ZbSource name\Zn: use the name returned by the scraper\n\ZbFilename\Zn: use the filename of the ROM as game name\n\nSkyscraper option: \Zb--forcefilename\Z0"
        [5]="Game name option to remove/keep the text found between '()' and '[]' in the ROMs filename.\n\nSkyscraper option: \Zb--nobrackets\Zn"
        [6]="Force the refresh of resources in the local cache when scraping.\n\nSkyscraper option: \Zb--refresh\Zn"
        [7]="Toggle the download and caching of videos.\nThis also toggles whether the videos will be included in the resulting gamelist.\n\nSkyscraper option: \Zb--videos\Zn"
        [8]="Choose to save the generated 'gamelist.xml' and media in the ROMs folder. Supported options:\n\n\ZbEnabled\Zn saves the 'gamelist.xml' in the ROMs folder and the media in the 'media' sub-folder.\n\n\ZbDisabled\Zn saves the 'gamelist.xml' in \Zu\$HOME/.emulationstation/gamelists/<system>\Zn and the media in \Zu\$HOME/.emulationstation/downloaded_media\Zn.\n\n\Zb\ZrNOTE\Zn: changing this option will not automatically copy the 'gamelist.xml' file and the media to the new location or remove the ones in the old location. You must do this manually.\n\nSkyscraper parameters: \Zb-g <gamelist>\Zn / \Zb-o <path>\Zn"
        [A]="Advanced options sub-menu."
    )

    ver=$(_get_ver_skyscraper)

    while true; do
        [[ -z "$ver" ]] && ver="v(Git)"

        local cmd=(dialog --backtitle "$__backtitle"  --colors --cancel-label "Exit" --help-button --no-collapse --cr-wrap --default-item "$default" --menu "   Skyscraper: game scraper by Lars Muldjord ($ver)\\n \\n" 21 65 10)

        local -a options=(
            1 "Scrape all systems"
            2 "Scrape chosen systems"
        )

        local source_found=0
        local online="Online"
        local i

        for i in "${!s_source[@]}"; do
            if [[ "$scrape_source" == "${s_source[$i]}" ]]; then
                [[ $i -ge 10 ]] && online="Local"
                options+=(3 "Scrape from ${s_source_names[$i]} ($online)")
                source_found=1
            fi
        done

        if [[ ! $source_found ]]; then
            options+=(3 "Scrape from Screenscraper (Default)")
            scrape_source="screenscraper" # default scraping source if none found
        fi

        if [[ "$rom_name" -eq 0 ]]; then
            options+=(4 "ROM Names (Source name)")
        else
            options+=(4 "ROM Names (Filename)")
        fi

        if [[ "$remove_brackets" -eq 1 ]]; then
            options+=(5 "Remove bracket info (Enabled)")
        else
            options+=(5 "Remove bracket info (Disabled)")
        fi

        if [[ "$force_refresh" -eq 0 ]]; then
            options+=(6 "Force cache refresh (Disabled)")
        else
            options+=(6 "Force cache refresh (Enabled)")
        fi

        if [[ "$download_videos" -eq 1 ]]; then
            options+=(7 "Download videos (Enabled)")
        else
            options+=(7 "Download videos (Disabled)")
        fi

        if [[ "$use_rom_folder" -eq 1 ]]; then
            options+=(8 "Use ROM folders for gamelist & media (Enabled)")
        else
            options+=(8 "Use ROM folders for gamelist & media (Disabled)")
        fi

        options+=(A "Advanced options -->")

        # Run the GUI
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        if [[ -n "$choice" ]]; then
            default="$choice"

            case "$choice" in

                1)
                    if _scrape_all_skyscraper; then
                        printMsgs "dialog" "ROMS have been scraped."
                    else
                        printMsgs "dialog" "Scraping was aborted"
                    fi
                    ;;

                2)
                    if _scrape_chosen_skyscraper; then
                        printMsgs "dialog" "ROMS have been scraped."
                    elif [[ $? -eq 2 ]]; then
                        printMsgs "dialog" "Scraping was aborted"
                    fi
                    ;;

                3)
                    # Scrape options have a separate dialog
                    declare -a s_options=()
                    local i

                    for i in "${!s_source[@]}"; do
                        online="Online:"
                        [[ i -ge 10 ]] && online="Local:"

                        if [[ "$scrape_source" == "${s_source[$i]}" ]]; then
                            s_default="$online ${s_source_names[$i]}"
                        fi

                        s_options+=("$online ${s_source_names[$i]}" "")
                    done

                    if [[ -z "$s_default" ]]; then
                        s_default="Online: ${s_source_names[1]}"
                    fi

                    
                    local s_cmd=(dialog --title "Select Scraping source" --default-item "$s_default" \
                        --menu "Choose one of the available scraping sources" 18 50 9)

                    # Run the Scraper source selection dialog
                    local scrape_source_name=$("${s_cmd[@]}" "${s_options[@]}" 2>&1 >/dev/tty)

                    # If Cancel was chosen, don't do anything
                    [[ -z "$scrape_source_name" ]] && continue

                    # Strip the "XYZ:" prefix from the chosen scraper source, then compare to our list
                    local src=$(echo "$scrape_source_name" | cut -d' ' -f2-)

                    for i in "${!s_source_names[@]}"; do
                        [[ "${s_source_names[$i]}" == "$src" ]] && scrape_source=${s_source[$i]}
                    done

                    iniSet "scrape_source" "$scrape_source"
                    ;;

                4)
                    rom_name="$((rom_name ^ 1))"
                    iniSet "rom_name" "$rom_name"
                    ;;

                5)
                    remove_brackets="$((remove_brackets ^ 1))"
                    iniSet "remove_brackets" "$remove_brackets"
                    ;;

                6)
                    force_refresh="$((force_refresh ^ 1))"
                    iniSet "force_refresh" "$force_refresh"
                    ;;

                7)
                    download_videos="$((download_videos ^ 1))"
                    iniSet "download_videos" "$download_videos"
                    ;;

                8)
                    use_rom_folder="$((use_rom_folder ^ 1))"
                    iniSet "use_rom_folder" "$use_rom_folder"
                    ;;

                A)
                    _gui_advanced_skyscraper
                    ;;

                HELP*)
                    # Retain choice when the Help button is selected
                    default="${choice/HELP /}"
                    if [[ ! -z "${help_strings[$default]}" ]]; then
                        dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings[$default]}" 22 65 >&1
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}
