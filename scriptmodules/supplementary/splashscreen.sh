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
rp_module_section="config"
rp_module_flags="!x86 !osmc"

#add function to choose music ext
function _music_exts(){
echo '\.ogg\|\.mp3\|\.wav\|\.aac\|\.flac'
}


function _update_hook_splashscreen() {
    rp_isInstalled "$md_idx" && configure_splashscreen
}

function _image_exts_splashscreen() {
    echo '\.bmp\|\.jpg\|\.jpeg\|\.gif\|\.png\|\.ppm\|\.tiff\|\.webp'
}

function _video_exts_splashscreen() {
    echo '\.avi\|\.mov\|\.mp4\|\.mkv\|\.3gp\|\.mpg\|\.mp3\|\.wav\|\.m4a\|\.aac\|\.ogg\|\.flac'
}

function depends_splashscreen() {
    getDepends fbi mpv libavdevice55 libavfilter5 libva-glx1
}

function install_bin_splashscreen() {
    cp "$md_data/asplashscreen" "/etc/init.d/"

    iniConfig "=" '"' /etc/init.d/asplashscreen
    iniSet "ROOTDIR" "$rootdir"
    iniSet "DATADIR" "$datadir"
    iniSet "REGEX_IMAGE" "$(_image_exts_splashscreen)"
    iniSet "REGEX_VIDEO" "$(_video_exts_splashscreen)"
#add REGEX_MUSIC
    iniSet "REGEX_MUSIC" "$(_music_exts)"

    chmod +x /etc/init.d/asplashscreen
#not used by now
    #gitPullOrClone "$md_inst" https://github.com/RetroPie/retropie-splashscreens.git

    #mkUserDir "$datadir/splashscreens"
    #echo "Place your own splashscreens in here." >"$datadir/splashscreens/README.txt"
    #chown $user:$user "$datadir/splashscreens/README.txt"
}

#not used by now

#function configure_splashscreen() {
 #   local config="/boot/cmdline.txt"
  #  if [[ -f "$config" ]] && ! grep -q "plymouth.enable" "$config"; then
   #     sed -i '1 s/ *$/ plymouth.enable=0/' "$config"
   # fi
#}

#create 3 functions to choose background music
function choose_path_music(){
local options=(
1 "RetrOrange Pi default"
2 "Own Music (from $datadir/splashscreens)"
)
local cmd=(dialog --backtitle "$_backtitle" --menu "Choose an option." 22 86 16)
local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
[[ "$choice" -eq 1 ]] && echo "/home/pi/RetroPie/splashscreens/bootsnd.ogg"
[[ "$choice" -eq 2 ]] && echo "$datadir/splashscreens"
}
function set_music(){
local path

path="$(choose_path_music)"
[[ -z "$path" ]] && break
local music=$(choose_music "$path")
echo "$music">/etc/music.list
printMsgs "dialog" "Music set to '$music'"
break
}
function choose_music(){
local path="$1"
#local type="$2"
local regex
regex=$(_music_exts)
local options=()
local i=0
while read splashdir; do
splashdir=${splashdir/$path\//}
if echo "$splashdir" | grep -q "$regex"; then
            options+=("$i" "$splashdir")
            ((i++))
        fi
done < <(find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" | sort)
if [[ "${#options[@]}" -eq 0 ]]; then
printMsgs "dialog" "There are no music installed in $path"
return
fi
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose music." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo "$path/${options[choice*2+1]}"
}



function default_splashscreen() {
    echo "$md_inst/splash.png" 
}

function enable_splashscreen() {
    insserv asplashscreen
}

function remove_splashscreen() {
    insserv -r asplashscreen
#not used
#	local config="/boot/cmdline.txt"
 #   if [[ -f "$config" ]]; then
  #      sed -i "s/ *plymouth.enable=0//" "$config"
   # fi
}

function choose_path_splashscreen() {
    local options=(
        1 "RetroPie splashscreens"
        2 "Own/Extra splashscreens (from $datadir/splashscreens)"
    )
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ "$choice" -eq 1 ]] && echo "$md_inst"
    [[ "$choice" -eq 2 ]] && echo "$datadir/splashscreens"
}

function set_append_splashscreen() {
    local mode="$1"
    [[ -z "$mode" ]] && mode="set"
    local path
    local file
    while true; do
        path="$(choose_path_splashscreen)"
        [[ -z "$path" ]] && break
        file=$(choose_splashscreen "$path")
        if [[ -n "$file" ]]; then
            if [[ "$mode" == "set" ]]; then
                echo "$file" >/etc/splashscreen.list
                printMsgs "dialog" "Splashscreen set to '$file'"
                break
            fi
            if [[ "$mode" == "append" ]]; then
                echo "$file" >>/etc/splashscreen.list
                printMsgs "dialog" "Splashscreen '$file' appended to /etc/splashscreen.list"
            fi
        fi
    done
}

function choose_splashscreen() {
    local path="$1"
    local type="$2"

    local regex
    [[ "$type" == "image" ]] && regex=$(_image_exts_splashscreen)
    [[ "$type" == "video" ]] && regex=$(_video_exts_splashscreen)

    local options=()
    local i=0
    while read splashdir; do
        splashdir=${splashdir/$path\//}
        if echo "$splashdir" | grep -q "$regex"; then
            options+=("$i" "$splashdir")
            ((i++))
        fi
    done < <(find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" | sort)
    if [[ "${#options[@]}" -eq 0 ]]; then
        printMsgs "dialog" "There are no splashscreens installed in $path"
        return
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && echo "$path/${options[choice*2+1]}"
}

function randomize_splashscreen() {
    options=(
        1 "Randomize RetroPie splashscreens"
        2 "Randomize own splashscreens (from $datadir/splashscreens)"
        3 "Randomize all splashscreens"
        4 "Randomize /etc/splashscreen.list"
    )
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    iniConfig "=" '"' /etc/init.d/asplashscreen
    case "$choice" in
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
}

function preview_splashscreen() {
    local options=(
        1 "View single splashscreen"
        2 "View slideshow of all splashscreens"
        3 "Play video splash"
    )

    local path
    local file
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        path="$(choose_path_splashscreen)"
        [[ -z "$path" ]] && break
        while true; do
            case "$choice" in
                1)
                    file=$(choose_splashscreen "$path" "image")
                    [[ -z "$file" ]] && break
                    fbi -T 2 -once -noverbose -a "$file"
                    ;;
                2)
                    file=$(mktemp)
                    find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" | sort > "$file"
                    if [[ -s "$file" ]]; then
                        fbi --timeout 6 --once --autozoom --list "$file"
                    else
                        printMsgs "dialog" "There are no splashscreens installed in $path"
                    fi
                    rm -f "$file"
                    break
                    ;;
                3)
                    file=$(choose_splashscreen "$path" "video")
                    [[ -z "$file" ]] && break
                    
		    #changed command
		    mpv -fs -vo sdl "$file"
                    ;;
            esac
        done
    done
}

function download_extra_splashscreen() {
    gitPullOrClone "$datadir/splashscreens/retropie-extra" https://github.com/HerbFargus/retropie-splashscreens-extra
    chown -R $user:$user "$datadir/splashscreens/retropie-extra"
}

function gui_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen depends
        rp_callModule splashscreen install
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do
        local enabled=0
        local random=0
        [[ -n "$(find "/etc/rcS.d" -type l -name "S*asplashscreen")" ]] && enabled=1
        local options=(1 "Choose splashscreen")
        if [[ "$enabled" -eq 1 ]]; then
            options+=(2 "Disable splashscreen on boot (Enabled)")
            iniConfig "=" '"' /etc/init.d/asplashscreen
            iniGet "RANDOMIZE"
            random=1
            [[ "$ini_value" == "disabled" ]] && random=0
            #if [[ "$random" -eq 1 ]]; then 	COMMENTED UNTESTED OPTIONS
                #options+=(3 "Disable splashscreen randomizer (Enabled)")
            #else
                #options+=(3 "Enable splashscreen randomizer (Disabled)")
            #fi
        else
            options+=(2 "Enable splashscreen on boot (Disabled)")
        fi
        options+=(
            3 "Use default splashscreen" #RENUMERATED DUE TO CUT OFF OF SPLASHSCREEN RANDOMIZE
            4 "Manually edit splashscreen list"
            #6 "Append splashscreen to list (for multiple entries)" REMOVED 
			5 "Choose background music" #ADDED 
            6 "Preview splashscreens"
            7 "Update RetrOrangePi splashscreens"
            8 "Download RetroPie-Extra splashscreens"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    set_append_splashscreen set
                    ;;
                2)
                    if [[ "$enabled" -eq 1 ]]; then
                        remove_splashscreen
                        printMsgs "dialog" "Disabled splashscreen on boot."
                    else
                        [[ ! -f /etc/splashscreen.list ]] && rp_CallModule splashscreen default
                        enable_splashscreen
                        printMsgs "dialog" "Enabled splashscreen on boot."
                    fi
                    ;;
                #3)                                                                    CUT OFF AND RENUMERATED AS ABOVE
                  #  if [[ "$random" -eq 1 ]]; then
                     #   iniSet "RANDOMIZE" "disabled"
                       # printMsgs "dialog" "Splashscreen randomizer disabled."
                  #  else
                 #       randomize_splashscreen
                  #  fi
                  #  ;;
                3)
                    default_splashscreen
                    printMsgs "dialog" "Splashscreen set to RetroPie default."
                    ;;
                4)
                    editFile /etc/splashscreen.list
                    ;;
                5)
                    #set_append_splashscreen append
                    set_music set
					;;
                6)
                    preview_splashscreen
                    ;;
                7)
                    rp_callModule splashscreen install
                    ;;
                8)
                    rp_callModule splashscreen download_extra
                    printMsgs "dialog" "The RetroPie-Extra splashscreens have been downloaded to $datadir/splashscreens/retropie-extra"
                    ;;
            esac
        else
            break
        fi
    done
}
