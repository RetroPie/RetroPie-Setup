#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation"
rp_module_desc="EmulationStation - Frontend used by RetroPie for launching emulators"
rp_module_licence="MIT https://raw.githubusercontent.com/RetroPie/EmulationStation/master/LICENSE.md"
rp_module_section="core"
rp_module_flags="frontend"

function _get_input_cfg_emulationstation() {
    echo "$configdir/all/emulationstation/es_input.cfg"
}

function _update_hook_emulationstation() {
    # make sure the input configuration scripts and launch script are always up to date
    if rp_isInstalled "$md_idx"; then
        copy_inputscripts_emulationstation
        install_launch_emulationstation
    fi
}

function _sort_systems_emulationstation() {
    local field="$1"
    cp "/etc/emulationstation/es_systems.cfg" "/etc/emulationstation/es_systems.cfg.bak"
    xmlstarlet sel -D -I \
        -t -m "/" -e "systemList" \
        -m "//system" -s A:T:U "$1" -c "." \
        "/etc/emulationstation/es_systems.cfg.bak" >"/etc/emulationstation/es_systems.cfg"
}

function _add_system_emulationstation() {
    local fullname="$1"
    local name="$2"
    local path="$3"
    local extension="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    local conf="/etc/emulationstation/es_systems.cfg"
    mkdir -p "/etc/emulationstation"
    if [[ ! -f "$conf" ]]; then
        echo "<systemList />" >"$conf"
    fi

    cp "$conf" "$conf.bak"
    if [[ $(xmlstarlet sel -t -v "count(/systemList/system[name='$name'])" "$conf") -eq 0 ]]; then
        xmlstarlet ed -L -s "/systemList" -t elem -n "system" -v "" \
            -s "/systemList/system[last()]" -t elem -n "name" -v "$name" \
            -s "/systemList/system[last()]" -t elem -n "fullname" -v "$fullname" \
            -s "/systemList/system[last()]" -t elem -n "path" -v "$path" \
            -s "/systemList/system[last()]" -t elem -n "extension" -v "$extension" \
            -s "/systemList/system[last()]" -t elem -n "command" -v "$command" \
            -s "/systemList/system[last()]" -t elem -n "platform" -v "$platform" \
            -s "/systemList/system[last()]" -t elem -n "theme" -v "$theme" \
            "$conf"
    else
        xmlstarlet ed -L \
            -u "/systemList/system[name='$name']/fullname" -v "$fullname" \
            -u "/systemList/system[name='$name']/path" -v "$path" \
            -u "/systemList/system[name='$name']/extension" -v "$extension" \
            -u "/systemList/system[name='$name']/command" -v "$command" \
            -u "/systemList/system[name='$name']/platform" -v "$platform" \
            -u "/systemList/system[name='$name']/theme" -v "$theme" \
            "$conf"
    fi

    _sort_systems_emulationstation "name"
}

function _del_system_emulationstation() {
    local fullname="$1"
    local name="$2"
    if [[ -f /etc/emulationstation/es_systems.cfg ]]; then
        xmlstarlet ed -L -P -d "/systemList/system[name='$name']" /etc/emulationstation/es_systems.cfg
    fi
}

function _add_rom_emulationstation() {
    local system_name="$1"
    local system_fullname="$2"
    local path="./$3"
    local name="$4"
    local desc="$5"
    local image="$6"

    local config_dir="$configdir/all/emulationstation"

    mkUserDir "$config_dir"
    mkUserDir "$config_dir/gamelists"
    mkUserDir "$config_dir/gamelists/$system_name"
    local config="$config_dir/gamelists/$system_name/gamelist.xml"

    if [[ ! -f "$config" ]]; then
        echo "<gameList />" >"$config"
    fi

    if [[ $(xmlstarlet sel -t -v "count(/gameList/game[path='$path'])" "$config") -eq 0 ]]; then
        xmlstarlet ed -L -s "/gameList" -t elem -n "game" -v "" \
            -s "/gameList/game[last()]" -t elem -n "path" -v "$path" \
            -s "/gameList/game[last()]" -t elem -n "name" -v "$name" \
            -s "/gameList/game[last()]" -t elem -n "desc" -v "$desc" \
            -s "/gameList/game[last()]" -t elem -n "image" -v "$image" \
            "$config"
    else
        xmlstarlet ed -L \
            -u "/gameList/game[name='$name']/path" -v "$path" \
            -u "/gameList/game[name='$name']/name" -v "$name" \
            -u "/gameList/game[name='$name']/desc" -v "$desc" \
            -u "/gameList/game[name='$name']/image" -v "$image" \
            "$config"
    fi
    chown $user:$user "$config"
}

function depends_emulationstation() {
    local depends=(
        libfreeimage-dev libfreetype6-dev
        libcurl4-openssl-dev libasound2-dev cmake libsdl2-dev libsm-dev
        libvlc-dev libvlccore-dev vlc
    )

    compareVersions "$__os_debian_ver" gt 8 && depends+=(rapidjson-dev)
    isPlatform "x11" && depends+=(gnome-terminal)
    getDepends "${depends[@]}"
}

function sources_emulationstation() {
    local repo="$1"
    local branch="$2"
    [[ -z "$repo" ]] && repo="https://github.com/RetroPie/EmulationStation"
    if [[ -z "$branch" ]]; then
        if compareVersions "$__os_debian_ver" gt 8; then
            branch="stable"
        else
            branch="v2.7.6"
        fi
    fi
    gitPullOrClone "$md_build" "$repo" "$branch"
}

function build_emulationstation() {
    rpSwap on 1000
    cmake . -DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/emulationstation"
}

function install_emulationstation() {
    md_ret_files=(
        'CREDITS.md'
        'emulationstation'
        'emulationstation.sh'
        'GAMELISTS.md'
        'README.md'
        'resources'
        'THEMES.md'
    )
}

function init_input_emulationstation() {
    local es_config="$(_get_input_cfg_emulationstation)"

    # if there is no ES config (or empty file) create it with initial inputList element
    if [[ ! -s "$es_config" ]]; then
        echo "<inputList />" >"$es_config"
    fi

    # add/update our inputconfiguration.sh inputAction
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputAction[@type='onfinish'])" "$es_config") -eq 0 ]]; then
        xmlstarlet ed -L -S \
            -s "/inputList" -t elem -n "inputActionTMP" -v "" \
            -s "//inputActionTMP" -t attr -n "type" -v "onfinish" \
            -s "//inputActionTMP" -t elem -n "command" -v "$md_inst/scripts/inputconfiguration.sh" \
            -r "//inputActionTMP" -v "inputAction" "$es_config"
    else
        xmlstarlet ed -L \
            -u "/inputList/inputAction[@type='onfinish']/command" -v "$md_inst/scripts/inputconfiguration.sh" \
            "$es_config"
    fi

    chown $user:$user "$es_config"
}

function copy_inputscripts_emulationstation() {
    mkdir -p "$md_inst/scripts"

    cp -r "$scriptdir/scriptmodules/$md_type/emulationstation/"* "$md_inst/scripts/"
    chmod +x "$md_inst/scripts/inputconfiguration.sh"
}

function install_launch_emulationstation() {
    cat > /usr/bin/emulationstation << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "emulationstation should not be run as root. If you used 'sudo emulationstation' please run without sudo."
    exit 1
fi

if [[ -d "/sys/module/vc4" ]]; then
    echo -e "ERROR: You have the experimental desktop GL driver enabled. This is NOT compatible with RetroPie, and Emulation Station as well as emulators will fail to launch.\\n\\nPlease disable the experimental desktop GL driver from the raspi-config 'Advanced Options' menu."
    exit 1
fi

if [[ "\$(uname --machine)" != *86* ]]; then
    if [[ -n "\$(pidof X)" ]]; then
        echo "X is running. Please shut down X in order to mitigate problems with losing keyboard input. For example, logout from LXDE."
        exit 1
    fi
fi

# save current tty/vt number for use with X so it can be launched on the correct tty
tty=\$(tty)
export TTY="\${tty:8:1}"

clear
tput civis
"$md_inst/emulationstation.sh" "\$@"
if [[ \$? -eq 139 ]]; then
    dialog --cr-wrap --no-collapse --msgbox "Emulation Station crashed!\n\nIf this is your first boot of RetroPie - make sure you are using the correct image for your system.\n\\nCheck your rom file/folder permissions and if running on a Raspberry Pi, make sure your gpu_split is set high enough and/or switch back to using carbon theme.\n\nFor more help please use the RetroPie forum." 20 60 >/dev/tty
fi
tput cnorm
_EOF_
    chmod +x /usr/bin/emulationstation

    if isPlatform "x11"; then
        mkdir -p /usr/local/share/{icons,applications}
        cp "$scriptdir/scriptmodules/$md_type/emulationstation/retropie.svg" "/usr/local/share/icons/"
        cat > /usr/local/share/applications/retropie.desktop << _EOF_
[Desktop Entry]
Type=Application
Exec=gnome-terminal --full-screen --hide-menubar -e emulationstation
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[de_DE]=RetroPie
Name=rpie
Comment[de_DE]=RetroPie
Comment=retropie
Icon=/usr/local/share/icons/retropie.svg
Categories=Game
_EOF_
    fi
}

function clear_input_emulationstation() {
    rm "$(_get_input_cfg_emulationstation)"
    init_input_emulationstation
}

function remove_emulationstation() {
    rm -f "/usr/bin/emulationstation"
    if isPlatform "x11"; then
        rm -rfv "/usr/local/share/icons/retropie.svg" "/usr/local/share/applications/retropie.desktop"
    fi
}

function configure_emulationstation() {
    # move the $home/emulationstation configuration dir and symlink it
    moveConfigDir "$home/.emulationstation" "$configdir/all/emulationstation"

    [[ "$mode" == "remove" ]] && return

    # remove other emulation station if it's installed, so we don't end up with
    # both packages interfering - but leave configs alone so switching is easy
    if [[ "$md_id" == "emulationstation-dev" ]]; then
        rmDirExists "$rootdir/$md_type/emulationstation"
    else
        rmDirExists "$rootdir/$md_type/emulationstation-dev"
    fi

    init_input_emulationstation

    copy_inputscripts_emulationstation

    install_launch_emulationstation

    mkdir -p "/etc/emulationstation"

    # ensure we have a default theme
    rp_callModule esthemes install_theme

    addAutoConf "es_swap_a_b" 0
    addAutoConf "disable" 0
}

function gui_emulationstation() {
    local es_swap=0
    getAutoConf "es_swap_a_b" && es_swap=1

    local disable=0
    getAutoConf "disable" && disable=1

    local default
    local options
    while true; do
        local options=(
            1 "Clear/Reset Emulation Station input configuration"
        )

        if [[ "$disable" -eq 0 ]]; then
            options+=(2 "Auto Configuration (Currently: Enabled)")
        else
            options+=(2 "Auto Configuration (Currently: Disabled)")
        fi

        if [[ "$es_swap" -eq 0 ]]; then
            options+=(3 "Swap A/B Buttons in ES (Currently: Default)")
        else
            options+=(3 "Swap A/B Buttons in ES (Currently: Swapped)")
        fi

        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        default="$choice"

        case "$choice" in
            1)
                if dialog --defaultno --yesno "Are you sure you want to reset the Emulation Station controller configuration ? This will wipe all controller configs for ES and it will prompt to reconfigure on next start" 22 76 2>&1 >/dev/tty; then
                    clear_input_emulationstation
                    printMsgs "dialog" "$(_get_input_cfg_emulationstation) has been reset to default values."
                fi
                ;;
            2)
                disable="$((disable ^ 1))"
                setAutoConf "disable" "$disable"
                ;;
            3)
                es_swap="$((es_swap ^ 1))"
                setAutoConf "es_swap_a_b" "$es_swap"
                local ra_swap="false"
                getAutoConf "es_swap_a_b" && ra_swap="true"
                iniSet "menu_swap_ok_cancel_buttons" "$ra_swap" "$configdir/all/retroarch.cfg"
                printMsgs "dialog" "You will need to reconfigure you controller in Emulation Station for the changes to take effect."
                ;;
        esac
    done
}
