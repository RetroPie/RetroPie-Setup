#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="splashscreen"
rp_module_desc="Configure Splashscreen"
rp_module_menus="3+configure"
rp_module_flags="nobin !x86"

function depends_splashscreen() {
    getDepends fbi omxplayer
}

function install_splashscreen() {
    cp "$scriptdir/scriptmodules/$md_type/$md_id/asplashscreen" "/etc/init.d/"
    chmod +x /etc/init.d/asplashscreen
    gitPullOrClone "$md_inst" https://github.com/RetroPie/retropie-splashscreens.git

    mkUserDir "$datadir/splashscreens"
    echo "Place your own splashscreens in here." >"$datadir/splashscreens/README.txt"
    chown $user:$user "$datadir/splashscreens/README.txt"
}

function default_splashscreen() {
    find "$md_inst/retropie2015-blue" -type f >/etc/splashscreen.list
}

function enable_splashscreen() {
    insserv asplashscreen
}

function remove_splashscreen() {
    insserv -r asplashscreen
}

function submenu_splashscreen() {
    local action="$1"
    local options=(
        1 "Choose RetroPie splashscreen"
        2 "Choose own splashscreen (from $datadir/splashscreens)"
    )
    if [[ "$action" == "preview" ]]; then
        options+=(
            3 "View slideshow of all RetroPie splashscreens"
            4 "View slideshow of all splashscreens in $datadir/splashscreens"
            5 "Choose RetroPie video splashscreen"
            6 "Choose own video splashscreen (from $datadir/splashscreens/videos)"
        )
    elif [[ "$action" == "randomize" ]]; then
        options=(
            1 "Randomize RetroPie splashscreens"
            2 "Randomize own splashscreens (from $datadir/splashscreens)"
            3 "Randomize all splashscreens"
            4 "Randomize /etc/splashscreen.list"
        )
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do
        local splashscreen="-"
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            if [[ $((choice % 2)) == 1 ]]; then local path="$md_inst"; else local path="$datadir/splashscreens"; fi
            if [[ "$action" == "preview" ]]; then
                case $choice in
                    [1-2])
                        while [[ -n "$splashscreen" ]]; do
                            splashscreen=$(choose_splashscreen "$path" "$action" "image")
                            if [[ -n "$splashscreen" ]]; then fbi --noverbose --autozoom "$splashscreen"; fi
                        done
                        ;;
                    [3-4])
                        find "$path" -type f ! -regex ".*/.git/.*" ! -regex ".*LICENSE" ! -regex ".*README.*" | grep -v "$videoextens" | sort > /etc/slideshow.list
                        if [[ -s /etc/slideshow.list ]]; then
                            fbi --timeout 6 --once --autozoom --list /etc/slideshow.list
                        else
                            printMsgs "dialog" "There are no splashscreens installed in $path"
                        fi
                        rm /etc/slideshow.list
                        ;;
                    [5-6])
                        while [[ -n "$splashscreen" ]]; do
                            splashscreen=$(choose_splashscreen "$path" "$action" "video")
                            if [[ -n "$splashscreen" ]]; then omxplayer -b --layer 10000 "$splashscreen"; fi
                        done
                        ;;
                esac
            elif [[ "$action" == "randomize" ]]; then
                case $choice in
                    1)
                        iniSet "RANDOMIZE" "retropie"
                        printMsgs "dialog" "Splashscreen randomizer enabled in directory $path"
                        ;;
                    2)
                        iniSet "RANDOMIZE" "custom"
                        printMsgs "dialog" "Splashscreen randomizer enabled in directory $path"
                        ;;
                    3)
                        iniSet "RANDOMIZE" "all"
                        printMsgs "dialog" "Splashscreen randomizer enabled for both splashscreen directories."
                        ;;
                    4)
                        iniSet "RANDOMIZE" "list"
                        printMsgs "dialog" "Splashscreen randomizer enabled for entries in /etc/splashscreen.list"
                        ;;
                esac
                break
            else #set and append
                case $choice in
                    [1-2])
                        while [[ -n "$splashscreen" ]]; do
                            splashscreen=$(choose_splashscreen "$path" "$action")
                            if [[ "$action" == "set" ]]; then break 2; fi
                        done
                        ;;
                esac
            fi
        else
            break
        fi
    done
}

function choose_splashscreen() {
    local path="$1"
    local mode="$2"
    local type="$3"
    local options=()
    local i=0
    local splashdir
    while read splashdir; do
        splashdir=${splashdir/$path\//}
        if [[ "$type" == "video" && "$mode" == "preview" ]] && ( echo "$splashdir" | grep -q "$videoextens" ); then
            options+=("$i" "$splashdir")
            ((i++))
        elif [[ "$type" == "image" && "$mode" == "preview" ]] && ! ( echo "$splashdir" | grep -q "$videoextens" ); then
            options+=("$i" "$splashdir")
            ((i++))
        elif [[ "$mode" != "preview" ]]; then
            options+=("$i" "$splashdir")
            ((i++))
        fi
    done < <(find "$path" -type f ! -regex ".*/.git/.*" ! -regex ".*LICENSE" ! -regex ".*README.*" | sort)
    if [[ ${#options[@]} -eq 0 ]]; then
        printMsgs "dialog" "There are no splashscreens installed in $path"
        return
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        choice=$((choice*2+1))
        splashdir=${options[choice]}
        if [[ "$mode" == "set" ]]; then
            find "$path/$splashdir" -type f | tee /etc/splashscreen.list
            printMsgs "dialog" "Splashscreen set to '$splashdir'."
        elif [[ "$mode" == "preview" ]]; then
            find "$path/$splashdir" -type f
        elif [[ "$mode" == "append" ]]; then
            find "$path/$splashdir" -type f | tee -a /etc/splashscreen.list
            printMsgs "dialog" "Splashscreen '$splashdir' appended to splashscreen.list"
        fi
    fi
}

function configure_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen depends
        rp_callModule splashscreen install
    fi
    videoextens=".avi\|.mov\|.mp4\|.mkv\|.3gp\|.mpg\|.mp3\|.wav\|.m4a\|.aac\|.ogg\|.flac"
    iniConfig "=" '"' /etc/init.d/asplashscreen
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do
        local options=( 1 "Choose splashscreen" )
        if [[ -n $( find "/etc/rcS.d" -type l -regex ".*asplashscreen" ) ]]; then
            options+=( 2 "Disable splashscreen on boot (Enabled)" )
            iniGet "RANDOMIZE"
            if [[ "$ini_value" = "disabled" ]]; then
                options+=( 3 "Enable splashscreen randomizer (Disabled)" )
            elif [[ -n "$ini_value" ]]; then
                options+=( 3 "Disable splashscreen randomizer (Enabled)" )
            fi
        else
            options+=( 2 "Enable splashscreen on boot (Disabled)" )
        fi
        options+=(
            4 "Use default splashscreen"
            5 "Manually edit splashscreen list"
            6 "Append splashscreen to list (for multiple entries)"
            7 "Preview splashscreens"
            8 "Update RetroPie splashscreens"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    rp_callModule splashscreen submenu "set"
                    ;;
                2)
                    if [[ -n $( find "/etc/rcS.d" -type l -regex ".*asplashscreen" ) ]]; then
                        remove_splashscreen
                        printMsgs "dialog" "Disabled splashscreen on boot."
                    else
                        [[ ! -f /etc/splashscreen.list ]] && rp_CallModule splashscreen default
                        enable_splashscreen
                        printMsgs "dialog" "Enabled splashscreen on boot."
                    fi
                    ;;
                3)
                    if [[ "$ini_value" = "disabled" ]]; then
                        rp_callModule splashscreen submenu "randomize"
                    else
                        iniSet "RANDOMIZE" "disabled"
                        printMsgs "dialog" "Splashscreen randomizer disabled."
                    fi
                    ;;
                4)
                    default_splashscreen
                    printMsgs "dialog" "Splashscreen set to RetroPie default."
                    ;;
                5)
                    editFile /etc/splashscreen.list
                    ;;
                6)
                    rp_callModule splashscreen submenu "append"
                    ;;
                7)
                    rp_callModule splashscreen submenu "preview"
                    ;;
                8)
                    rp_callModule splashscreen install
                    ;;
            esac
        else
            break
        fi
    done
}
