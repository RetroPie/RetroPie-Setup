#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wikiview"
rp_module_desc="RetroPie-Setup Wiki Viewer"
rp_module_section="config"

function depends_wikiview() {
    getDepends pandoc lynx-cur
}

function choose_wikipage_wikiview() {
    local path="$1"
    local include="$2"
    local exclude="$3"
    local cmd=(dialog --backtitle "$__backtitle" --menu "Which wiki page would you like to view?" 22 76 16)
    local wikipages=()
    local options=()
    local wikipage
    local i=0
    while read wikipage; do
        wikipage=${wikipage//$path\//}
        wikipages+=("$wikipage")
        options+=("$i" "$wikipage")
        ((i++))
    done < <(find "$path" -type f -regex "$include" ! -regex "$exclude" | sort)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        echo "${wikipages[choice]}"
    fi
}

function gui_wikiview() {
    local wikidir="$rootdir/RetroPie-Setup.wiki"
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "RetroPie-Setup Wiki Viewer" 22 76 16)
        local options=()
        if [[ -d "$wikidir" ]]; then
            options=(
                1 "Update RetroPie-Setup Wiki"
                2 "View Wiki Pages"
                3 "Remove RetroPie-Setup Wiki"
            )
        else
            options+=("1" "Download RetroPie-Setup Wiki")
        fi
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        local file="-"
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    gitPullOrClone "$wikidir" "https://github.com/RetroPie/RetroPie-Setup.wiki.git"
                    ;;
                2)
                    while [[ -n  "$file" ]]; do
                        file=""
                        file=$(choose_wikipage_wikiview "$wikidir" ".*.md" ".*_.*")
                        if [[ -n "$file" ]]; then
                            joy2keyStop
                            joy2keyStart 0x00 0x00 kich1 kdch1 0x20 0x71
                            pandoc "$wikidir/$file" | lynx -localhost -restrictions=all -stdin >/dev/tty
                            joy2keyStop
                            joy2keyStart
                        else
                            break
                        fi
                    done
                    ;;
                3)
                    if [[ -d "$wikidir" ]]; then
                        rm -rf "$wikidir"
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}
