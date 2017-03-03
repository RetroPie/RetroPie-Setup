#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openpht"
rp_module_desc="OpenPHT is a community driven fork of Plex Home Theater"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RasPlex/OpenPHT/openpht-1.7/LICENSE.GPL"
rp_module_section="opt"
rp_module_flags="!arm"

function depends_openpht() {
    getDepends pulseaudio-utils
    addUdevInputRules
}

function install_bin_openpht() {
    local version="1.7.1.137-b604995c"
    local package="openpht_${version}-${__os_codename}_amd64.deb"
    local getdeb="https://github.com/RasPlex/OpenPHT/releases/download/v$version/$package"

    wget -nv -O "$__tmpdir/$package" $getdeb
    if hasPackage "apt" "1.1" "ge"; then
        apt install -y --allow-downgrades "$__tmpdir/$package"
    else
        # Falling back to dpkg
        dpkg -i "$__tmpdir/$package"
        apt-get -f -y install
    fi
    rm "$__tmpdir/$package"
}

function remove_openpht() {
    aptRemove openpht
}

function configure_openpht() {
    addPort "openpht" "openpht" "OpenPHT" "pasuspender -- env AE_SINK=ALSA openpht"
}
