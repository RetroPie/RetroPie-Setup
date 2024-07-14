#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uqm"
rp_module_desc="The Ur-Quan Masters (Port of DOS game Star Control 2)"
rp_module_licence="GPL https://sourceforce.net/p/sc2/uqm/ci/master/tree/sc2/COPYING?format=raw"
rp_module_repo="file :_get_archive_uqm"
rp_module_section="exp"

function _get_ver_uqm() {
    echo "0.8.0"
}

function _update_hook_uqm() {
    # to show as installed in retropie-setup 4.x
    hasPackage uqm && mkdir -p "$md_inst"
}

function _get_archive_uqm() {
    echo "$__archive_url/uqm-$(_get_ver_uqm)-src.tgz"
}

function depends_uqm() {
    getDepends libsdl2-dev libogg-dev libvorbis-dev libpng-dev zlib1g-dev
}

function sources_uqm() {
    downloadAndExtract "$(rp_resolveRepoParam "$md_repo_url")" "$md_build" --strip-components 1
    local packages="$md_build/content/packages"
    mkdir -p "$packages"
    local addons="$md_build/content/addons"
    mkdir -p "$addons"
    local ver="$(_get_ver_uqm)"
    download "$__archive_url/uqm-${ver}-content.uqm" "$packages"
    download "$__archive_url/uqm-${ver}-voice.uqm" "$addons"
    download "$__archive_url/uqm-${ver}-3domusic.uqm" "$addons"
}

function build_uqm() {
    ./build.sh uqm clean
    echo "\n" | CHOICE_debug_VALUE="nodebug" INPUT_install_prefix_VALUE="$md_inst" ./build.sh uqm config
    ./build.sh uqm
    md_ret_require="$md_build/src/uqm"
}

function install_uqm() {
    ./build.sh uqm install
}

function configure_uqm() {
    addPort "$md_id" "uqm" "Ur-quan Masters" "$md_inst/bin/uqm -f"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.uqm" "$md_conf_root/uqm"
}
