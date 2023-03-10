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

function _has_pixel_pos_esthemes() {
    local pixel_pos=0
    # get the version of emulationstation installed so we can check whether to show
    # themes that use the new pixel based positioning - we run as $user as the
    # emulationstation launch script will exit if run as root
    local es_ver="$(sudo -u $user /usr/bin/emulationstation --help | grep -oP "Version \K[^,]+")"
    # if emulationstation is newer than 2.10, enable pixel based themes
    compareVersions "$es_ver" ge "2.10" && pixel_pos=1
    echo "$pixel_pos"
}

function install_theme_esthemes() {
    local theme="$1"
    local repo="$2"
    local branch="$3"

    local pixel_pos="$(_has_pixel_pos_esthemes)"

    if [[ -z "$repo" ]]; then
        repo="RetroPie"
    fi

    if [[ -z "$theme" ]]; then
        theme="carbon"
        repo="RetroPie"
        [[ "$pixel_pos" -eq 1 ]] && theme+="-2021"
    fi

    local name="$theme"

    if [[ -z "$branch" ]]; then
        # Get the name of the default branch, fallback to 'master' if not found
        branch=$(runCmd git ls-remote --symref --exit-code "https://github.com/$repo/es-theme-$theme.git" HEAD | grep -oP ".*/\K[^\t]+")
        [[ -z "$branch" ]] && branch="master"
    else
        name+="-$branch"
    fi

    mkdir -p "/etc/emulationstation/themes"
    gitPullOrClone "/etc/emulationstation/themes/$name" "https://github.com/$repo/es-theme-$theme.git" "$branch"
}

function uninstall_theme_esthemes() {
    local theme="$1"
    if [[ -d "/etc/emulationstation/themes/$theme" ]]; then
        rm -rf "/etc/emulationstation/themes/$theme"
    fi
}

function gui_esthemes() {
    local themes=()

    local pixel_pos="$(_has_pixel_pos_esthemes)"

    if [[ "$pixel_pos" -eq 1 ]]; then
        themes+=(
            'RetroPie carbon-2021'
            'RetroPie carbon-2021 centered'
            'RetroPie carbon-2021 nometa'
        )
    fi

    local themes+=(  
        'flpowergamesretro flpowergamesretro_v1.0'
      )