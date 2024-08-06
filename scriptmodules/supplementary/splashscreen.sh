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
rp_module_section="main"
rp_module_repo="git https://github.com/RetroPie/retropie-splashscreens.git master"
rp_module_flags="noinstclean !all rpi !osmc !xbian !aarch64"

function _update_hook_splashscreen() {
    # make sure splashscreen is always up to date if updating just RetroPie-Setup
    if rp_isInstalled "$md_id"; then
        install_bin_splashscreen
        configure_splashscreen
    fi
}

function _image_exts_splashscreen() {
    echo '\.bmp\|\.jpg\|\.jpeg\|\.gif\|\.png\|\.ppm\|\.tiff\|\.webp'
}

function _video_exts_splashscreen() {
    echo '\.avi\|\.mov\|\.mp4\|\.mkv\|\.3gp\|\.mpg\|\.mp3\|\.wav\|\.m4a\|\.aac\|\.ogg\|\.flac'
}

function depends_splashscreen() {
    local params=(insserv)
    isPlatform "32bit" && params+=(omxplayer)
    getDepends "${params[@]}"
}

function install_bin_splashscreen() {
    cat > "/etc/systemd/system/asplashscreen.service" << _EOF_
[Unit]
Description=Show custom splashscreen
DefaultDependencies=no
After=console-setup.service
Wants=console-setup.service
ConditionPathExists=$md_inst/asplashscreen.sh

[Service]
Type=oneshot
ExecStart=$md_inst/asplashscreen.sh
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
_EOF_

    rp_installModule "omxiv" "_autoupdate_"

    gitPullOrClone "$md_inst"

    cp "$md_data/asplashscreen.sh" "$md_inst"

    iniConfig "=" '"' "$md_inst/asplashscreen.sh"
    iniSet "ROOTDIR" "$rootdir"
    iniSet "DATADIR" "$datadir"
    iniSet "REGEX_IMAGE" "$(_image_exts_splashscreen)"
    iniSet "REGEX_VIDEO" "$(_video_exts_splashscreen)"

    if [[ ! -f "$configdir/all/$md_id.cfg" ]]; then
        iniConfig "=" '"' "$configdir/all/$md_id.cfg"
        iniSet "RANDOMIZE" "disabled"
    fi
    chown "$__user":"$__group" "$configdir/all/$md_id.cfg"

    mkUserDir "$datadir/splashscreens"
    echo "Place your own splashscreens in here." >"$datadir/splashscreens/README.txt"
    chown "$__user":"$__group" "$datadir/splashscreens/README.txt"
}

function enable_plymouth_splashscreen() {
    local config="/boot/cmdline.txt"
    if [[ -f "$config" ]]; then
        sed -i "s/ *plymouth.enable=0//" "$config"
    fi
}

function disable_plymouth_splashscreen() {
    local config="/boot/cmdline.txt"
    if [[ -f "$config" ]] && ! grep -q "plymouth.enable" "$config"; then
        sed -i '1 s/ *$/ plymouth.enable=0/' "$config"
    fi
}

function default_splashscreen() {
    echo "$md_inst/retropie-default.png" >/etc/splashscreen.list
}

function enable_splashscreen() {
    systemctl enable asplashscreen
}

function disable_splashscreen() {
    systemctl disable asplashscreen
}

function configure_splashscreen() {
    [[ "$md_mode" == "remove" ]] && return

    # remove legacy service
    [[ -f "/etc/init.d/asplashscreen" ]] && insserv -r asplashscreen && rm -f /etc/init.d/asplashscreen

    disable_plymouth_splashscreen
    enable_splashscreen
    [[ ! -f /etc/splashscreen.list ]] && default_splashscreen
}

function remove_splashscreen() {
    enable_plymouth_splashscreen
    disable_splashscreen
    rp_callModule "omxiv" remove
    rm -f /etc/splashscreen.list /etc/systemd/system/asplashscreen.service
    systemctl daemon-reload
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
    done < <(find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" ! -regex ".*\.sh"  ! -regex ".*\.pkg" | sort)
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
        0 "Disable splashscreen randomizer"
        1 "Randomize RetroPie splashscreens"
        2 "Randomize own splashscreens (from $datadir/splashscreens)"
        3 "Randomize all splashscreens"
        4 "Randomize /etc/splashscreen.list"
    )
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    iniConfig "=" '"' "$configdir/all/$md_id.cfg"
    chown "$__user":"$__group" "$configdir/all/$md_id.cfg"

    case "$choice" in
        0)
            iniSet "RANDOMIZE" "disabled"
            printMsgs "dialog" "Splashscreen randomizer disabled."
            ;;
        1)
            iniSet "RANDOMIZE" "retropie"
            printMsgs "dialog" "Splashscreen randomizer enabled in directory $rootdir/supplementary/$md_id"
            ;;
        2)
            iniSet "RANDOMIZE" "custom"
            printMsgs "dialog" "Splashscreen randomizer enabled in directory $datadir/splashscreens"
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
    local omxiv="/opt/retropie/supplementary/omxiv/omxiv"
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
                    $omxiv -b "$file"
                    ;;
                2)
                    file=$(mktemp)
                    find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" ! -regex ".*\.sh" | sort > "$file"
                    if [[ -s "$file" ]]; then
                        $omxiv -t 6 -T blend -b --once -f "$file"
                    else
                        printMsgs "dialog" "There are no splashscreens installed in $path"
                    fi
                    rm -f "$file"
                    break
                    ;;
                3)
                    file=$(choose_splashscreen "$path" "video")
                    [[ -z "$file" ]] && break
                    omxplayer --no-osd -b --layer 10000 "$file"
                    ;;
            esac
        done
    done
}

function download_extra_splashscreen() {
    gitPullOrClone "$datadir/splashscreens/retropie-extra" https://github.com/HerbFargus/retropie-splashscreens-extra
    chown -R "$__user":"$__group" "$datadir/splashscreens/retropie-extra"
}

function gui_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen depends
        rp_callModule splashscreen install
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do
        local enabled=0
        [[ -n "$(find "/etc/systemd/system/"*".wants" -type l -name "asplashscreen.service")" ]] && enabled=1
        local options=(1 "Choose splashscreen")
        if [[ "$enabled" -eq 1 ]]; then
            options+=(2 "Show splashscreen on boot (currently: Enabled)")
            iniConfig "=" '"' "$configdir/all/$md_id.cfg"
            iniGet "RANDOMIZE"
            options+=(3 "Randomizer options (currently: ${ini_value^})")
        else
            options+=(2 "Show splashscreen on boot (currently: Disabled)")
        fi
        options+=(
            4 "Use default splashscreen"
            5 "Manually edit splashscreen list"
            6 "Append splashscreen to list (for multiple entries)"
            7 "Preview splashscreens"
            8 "Update RetroPie splashscreens"
            9 "Download RetroPie-Extra splashscreens"
        )

        iniConfig "=" '"' "$configdir/all/$md_id.cfg"
        iniGet "DURATION"
        # default splashscreen duration is 12 seconds
        local duration=${ini_value:-12}

        options+=(
            A "Configure image splashscreen duration ($duration sec)"
            )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    set_append_splashscreen set
                    ;;
                2)
                    if [[ "$enabled" -eq 1 ]]; then
                        disable_splashscreen
                        printMsgs "dialog" "Disabled splashscreen on boot."
                    else
                        [[ ! -f /etc/splashscreen.list ]] && rp_callModule splashscreen default
                        enable_splashscreen
                        printMsgs "dialog" "Enabled splashscreen on boot."
                    fi
                    ;;
                3)
                    randomize_splashscreen
                    ;;
                4)
                    iniSet "RANDOMIZE" "disabled"
                    default_splashscreen
                    enable_splashscreen
                    printMsgs "dialog" "Splashscreen set to RetroPie default."
                    ;;
                5)
                    editFile /etc/splashscreen.list
                    ;;
                6)
                    set_append_splashscreen append
                    ;;
                7)
                    preview_splashscreen
                    ;;
                8)
                    rp_callModule splashscreen install
                    ;;
                9)
                    rp_callModule splashscreen download_extra
                    printMsgs "dialog" "The RetroPie-Extra splashscreens have been downloaded to $datadir/splashscreens/retropie-extra"
                    ;;
                A)  
                    duration=$(dialog --title "Splashscreen duration" --clear --rangebox "Configure how many seconds the splashscreen is active" 0 60 5 100 $duration 2>&1 >/dev/tty)
                    if [[ -n "$duration" ]]; then
                        iniSet "DURATION" "${duration//[^[:digit:]]/}"
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}
