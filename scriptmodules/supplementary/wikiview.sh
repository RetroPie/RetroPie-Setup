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
rp_module_menus="3+"
rp_module_flags="nobin"

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

function configure_wikiview() {
    local wikidir="$rootdir/RetroPie-Setup.wiki"
    __joy2key_pid=$(pgrep -f joy2key.py)
    __joy2key_dev=$(ls -1 /dev/input/js* 2>/dev/null | head -n1)
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
            case $choice in
                1)
                    gitPullOrClone "$wikidir" "https://github.com/RetroPie/RetroPie-Setup.wiki.git"
                    ;;
                2)
                    while [[ -n  "$file" ]]; do
                        file=""
                        file=$(choose_wikipage_wikiview "$wikidir" ".*.md" ".*_.*")
                        if [[ -n "$file" ]]; then
                            if [[ -n $__joy2key_pid ]]; then
                                kill -INT $__joy2key_pid 2>/dev/null
                                sleep 1
                            fi
                            if [[ -f "$rootdir/supplementary/runcommand/joy2key.py" && -n "$__joy2key_dev" ]] && ! pgrep -f joy2key.py >/dev/null; then
                                "$rootdir/supplementary/runcommand/joy2key.py" "$__joy2key_dev" 00 00 1b5b327e 1b5b337e 20 71 & 2>/dev/null
                                __joy2key_pid=$!
                            fi
                            pandoc "$wikidir/$file" | lynx -localhost -restrictions=all -stdin >/dev/tty
                            if [[ -n $__joy2key_pid ]]; then
                                kill -INT $__joy2key_pid 2>/dev/null
                                sleep 1
                            fi
                            if [[ -f "$rootdir/supplementary/runcommand/joy2key.py" && -n "$__joy2key_dev" ]] && ! pgrep -f joy2key.py >/dev/null; then
                                "$rootdir/supplementary/runcommand/joy2key.py" "$__joy2key_dev" 1b5b44 1b5b43 1b5b41 1b5b42 0a 20 & 2>/dev/null
                                __joy2key_pid=$!
                            fi
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
