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
rp_module_section="config"

function depends_esthemes() {
    if isPlatform "x11"; then
        getDepends feh
    else
        getDepends fbi
    fi
}

function install_theme_esthemes() {
    local theme="$1"
    local repo="$2"
    if [[ -z "$repo" ]]; then
        repo="RetroPie"
    fi
    if [[ -z "$theme" ]]; then
        theme="carbon"
        repo="RetroPie"
    fi
    mkdir -p "/etc/emulationstation/themes"
    # do a fresh checkout to avoid some line ending issues with the autocrlf mode used to create the images vs git default on Raspbian
    rm -rf "/etc/emulationstation/themes/$theme"
    gitPullOrClone "/etc/emulationstation/themes/$theme" "https://github.com/$repo/es-theme-$theme.git"
}

function uninstall_theme_esthemes() {
    local theme="$1"
    if [[ -d "/etc/emulationstation/themes/$theme" ]]; then
        rm -rf "/etc/emulationstation/themes/$theme"
    fi
}

function gui_esthemes() {
    local themes=(
        'RetroPie carbon'
        'RetroPie carbon-centered'
        'RetroPie carbon-nometa'
        'ehettervik pixel'
        'ehettervik pixel-metadata'
        'ehettervik pixel-tft'
        'ehettervik luminous'
        'ehettervik minilumi'
        'ehettervik workbench'
        'AmadhiX eudora'
        'AmadhiX eudora-bigshot'
        'AmadhiX eudora-concise'
        'InsecureSpike retroplay-clean-canela'
        'InsecureSpike retroplay-clean-detail-canela'
        'RetroPie turtle-pi'
        'Omnija simpler-turtlepi'
        'RetroPie simple'
        'RetroPie simple-dark'
        'RetroPie color-pi'
        'RetroPie simplified-static-canela'
        'RetroPie zoid'
        'RetroPie nbba'
        'lilbud material'
        'mattrixk io'
        'mattrixk metapixel'
        'mattrixk spare'
        'robertybob space'
        'robertybob simplebigart'
        'RetroPie clean-look'
        'HerbFargus tronkyfran'
    )
    while true; do
        local theme
        local repo
        local options=()
        local status=()
        local i=1
        local gallerydir="/etc/emulationstation/es-theme-gallery"
        if [[ -d "$gallerydir" ]]; then
            status+=("i")
            options+=("$i" "View or Update Theme Gallery")
        else
            status+=("n")
            options+=("$i" "Download Theme Gallery")
        fi
        ((i++))
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
        if [[ -n "$choice" && $choice > 1 ]]; then
            theme=(${themes[choice-2]})
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
        elif [[ -n "$choice" && $choice == 1 ]]; then
            if [[ "${status[0]}" == "i" ]]; then
                options=(1 "View Theme Gallery" 2 "Update Theme Gallery" 3 "Remove Theme Gallery")
                cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option for gallery" 12 40 06)
                local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                case "$choice" in
                    1)
                        cd "$gallerydir"
                        if isPlatform "x11"; then
                            feh --info "echo %f" --slideshow-delay 6 --fullscreen --auto-zoom --filelist images.list
                        else
                            fbi --timeout 6 --once --autozoom --list images.list
                        fi
                        ;;
                    2)
                        gitPullOrClone "$gallerydir" "http://github.com/wetriner/es-theme-gallery"
                        ;;
                    3)
                        if [[ -d "$gallerydir" ]]; then
                            rm -rf "$gallerydir"
                        fi
                        ;;
                esac
            else
                gitPullOrClone "$gallerydir" "http://github.com/wetriner/es-theme-gallery"
            fi
        else
            break
        fi
    done
}

