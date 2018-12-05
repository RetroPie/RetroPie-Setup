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
rp_module_desc="Steam Link for Raspberry Pi 3"
rp_module_licence="PROP https://steamcommunity.com/app/353380/discussions/0/1743353164093954254/"
rp_module_section="exp"
rp_module_flags="!mali !x86 !kms !rpi1 !rpi2"
rp_module_help="Streaming games to your computer with Steam.\n\nIf you experience a black screen during startup, you may need to disable the overscan_scale setting in your Pi's /boot/config.txt."

function depends_steamlink() {
    getDepends python3-dev curl xz-utils
}

function install_bin_steamlink() {
    local ver="1.0.5"
    local url="http://media.steampowered.com/steamlink/rpi"
    wget -qO "$__tmpdir/steamlink_"$ver"_armhf.deb" ""$url"/steamlink_"$ver"_armhf.deb"
    dpkg -i "$__tmpdir/steamlink_"$ver"_armhf.deb"
}

function remove_steamlink() {
    aptRemove steamlink
}

function configure_steamlink() {
    local sl_dir="$home/.local/share/SteamLink"
    local valve_dir="$home/.local/share/Valve Software"

    mkUserDir "$sl_dir"
    mkUserDir "$valve_dir"
    mkUserDir "$valve_dir/Streaming Client"

    # create optional streaming_args.txt for user modification
    touch "$valve_dir/Streaming Client/streaming_args.txt"
    chown $user:$user "$valve_dir/Streaming Client/streaming_args.txt"
    moveConfigFile "$valve_dir/Streaming Client/streaming_args.txt" "$md_conf_root/$md_id/streaming_args.txt"

    # RetroPie sets overscan by default, which requires an override
    if grep '^overscan_scale=1' /boot/config.txt &>/dev/null; then
        touch "$sl_dir/.ignore_overscan"
        chown $user:$user "$sl_dir/.ignore_overscan"
    fi

    addPort "$md_id" "steamlink" "Steam Link" "/usr/bin/steamlink"
}
