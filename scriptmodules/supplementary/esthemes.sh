#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="esthemes"
rp_module_desc="Install themes for Emulation Station"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function install_theme_esthemes() {
    local theme="$1"
    local repo="$2"
    if [[ -z "$repo" ]]; then
        repo="RetroPie"
    fi
    if [[ -z "$theme" ]]; then
        theme="carbon"
        repo="HerbFargus"
    fi
    mkdir -p "/etc/emulationstation/themes"
    gitPullOrClone "/etc/emulationstation/themes/$theme" "https://github.com/$repo/es-theme-$theme.git"
}

function uninstall_theme_esthemes() {
    local theme="$1"
    if [[ -d "/etc/emulationstation/themes/$theme" ]]; then
        rm -rf "/etc/emulationstation/themes/$theme"
    fi
}

function configure_esthemes() {
    local themes=(
        'HerbFargus carbon'
        'HerbFargus carbon-centered'
        'HerbFargus carbon-nometa'
        'RetroPie simple'
        'RetroPie simple-dark'
        'RetroPie color-pi'
        'RetroPie simplified-static-canela'
        'RetroPie zoid'
        'RetroPie nbba'
        'robertybob space'
        'robertybob simplebigart'
        'HerbFargus clean-look'
        'HerbFargus turtle-pi'
        'InsecureSpike clean-simple-canela'
        'InsecureSpike clean-detail-canela'
        'HerbFargus tronkyfran'
        'AmadhiX eudora'
        'AmadhiX eudora-bigshot'
        'AmadhiX eudora-concise'
    )
    while true; do
        local theme
        local repo
        local options=()
        local status=()
        local i=1
        for theme in "${themes[@]}"; do
            theme=($theme)
            theme="${theme[1]}"
            if [[ -d "/etc/emulationstation/themes/$theme" ]]; then
                status+=("i")
                options+=("$i" "Update or Uninstall $theme (installed)")
            else
                status+=("n")
                options+=("$i" "Install $theme (not installed)")
            fi
            ((i++))
        done
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            theme=(${themes[choice-1]})
            repo="${theme[0]}"
            theme="${theme[1]}"
            if [[ "${status[choice-1]}" == "i" ]]; then
                options=(1 "Update $theme" 2 "Uninstall $theme")
                cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option for theme" 12 40 06)
                local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                case "$choice" in
                    1)
                        rp_callModule esthemes install_theme "$theme" "$repo"
                        ;;
                    2)
                        rp_callModule esthemes uninstall_theme "$theme"
                        ;;
                esac
            else
                rp_callModule esthemes install_theme "$theme" "$repo"
            fi
        else
            break
        fi
    done
}

