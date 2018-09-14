#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retroarch-dev"
rp_module_desc="RetroArch (latest development version) - frontend to the libretro emulator cores - required by all lr-* emulators\n\nNote: to remove, go to Core packages"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/RetroArch/master/COPYING "
rp_module_section="exp"

function depends_retroarch-dev() {
    depends_retroarch
}

function sources_retroarch-dev() {
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch.git master
    applyPatch "/home/pigaming/RetroPie-Setup/scriptmodules/emulators/retroarch/01_hotkey_hack.diff"
    applyPatch "/home/pigaming/RetroPie-Setup/scriptmodules/emulators/retroarch/02_disable_search.diff"
    applyPatch "/home/pigaming/RetroPie-Setup/scriptmodules/emulators/retroarch/03_disable_udev_sort.diff"
}

function build_retroarch-dev() {
    build_retroarch
}

function install_retroarch-dev() {
    install_retroarch
}

function install_bin_retroarch-dev() {
    downloadAndExtract "http://github.com/Retro-Arena/xu4-bins/raw/master/retroarch-dev.tar.gz" "$md_inst" 1
}

function update_shaders_retroarch-dev() {
    update_shaders_retroarch
}

function update_overlays_retroarch-dev() {
    update_overlays_retroarch
}

function update_assets_retroarch-dev() {
    update_assets_retroarch
}

function install_xmb_monochrome_assets_retroarch-dev() {
    install_xmb_monochrome_assets_retroarch
}

function _package_xmb_monochrome_assets_retroarch-dev() {
    _package_xmb_monochrome_assets_retroarch
}

function configure_retroarch-dev() {
    configure_retroarch
    # rename retroarch-dev to retroarch
    if [[ -d /opt/retropie/emulators/retroarch ]]; then
        rm -rf /opt/retropie/emulators/retroarch
        mv /opt/retropie/emulators/retroarch-dev /opt/retropie/emulators/retroarch
    else
        mv /opt/retropie/emulators/retroarch-dev /opt/retropie/emulators/retroarch
    fi
}

function keyboard_retroarch-dev() {
    keyboard_retroarch
}

function hotkey_retroarch-dev() {
    hotkey_retroarch
}

function gui_retroarch-dev() {
    gui_retroarch
}
