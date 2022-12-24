#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="steamlink"
rp_module_desc="Steam Link for Raspberry Pi 3 or later"
rp_module_licence="PROP https://steamcommunity.com/app/353380/discussions/0/1743353164093954254/"
rp_module_section="exp"
rp_module_flags="!all rpi3 rpi4"
rp_module_help="Stream games from your computer with Steam"

function depends_steamlink() {
    getDepends python3-dev libinput10 libxkbcommon-x11-0 matchbox-window-manager xorg zenity
}

function install_bin_steamlink() {
    aptInstall steamlink
}

function remove_steamlink() {
    aptRemove steamlink
}

function configure_steamlink() {
    local sl_script="$md_inst/steamlink_xinit.sh"
    local sl_dir="$home/.local/share/SteamLink"
    local valve_dir="$home/.local/share/Valve Corporation"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$sl_dir"
        mkUserDir "$valve_dir"
        mkUserDir "$valve_dir/SteamLink"
        mkUserDir "$md_conf_root/$md_id"

        # create optional streaming_args.txt for user modification
        touch "$valve_dir/SteamLink/streaming_args.txt"
        chown $user:$group "$valve_dir/SteamLink/streaming_args.txt"
        moveConfigFile "$valve_dir/SteamLink/streaming_args.txt" "$md_conf_root/$md_id/streaming_args.txt"

        cat > "$sl_script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
/usr/bin/steamlink
_EOF_
        chmod +x "$sl_script"
    fi

    addPort "$md_id" "steamlink" "Steam Link" "XINIT:$sl_script"
}
