#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xpadneo"
rp_module_desc="Advanced Linux driver for Xbox One wireless gamepads"
rp_module_licence="GPL3 https://raw.githubusercontent.com/atar-axis/xpadneo/master/LICENSE"
rp_module_repo="git https://github.com/atar-axis/xpadneo.git :_version_xpadneo"
rp_module_section="driver"
rp_module_flags="nobin"

function _version_xpadneo() {
    local build_version=v0.10.2

    # buster and eariler get the v0.9.x version, due to v0.10 needing a newer Linux kernel
    [[ "$__os_debian_ver" -lt 11 ]] && build_version=v0.9.8

    echo "$build_version"
}

function depends_xpadneo() {
    local depends=(dkms rsync LINUX-HEADERS)
    getDepends "${depends[@]}"
}

function sources_xpadneo() {
    gitPullOrClone
    rsync -a --delete "$md_build/hid-xpadneo/" "$md_inst/"
    cp "$md_build/VERSION" "$md_inst/"
    local version="$(_version_xpadneo)"
    sed "s/@DO_NOT_CHANGE@/$version/g" "$md_inst/dkms.conf.in" > "$md_inst/dkms.conf"
}

function build_xpadneo() {
    dkmsManager install hid-xpadneo "$(_version_xpadneo)"
}

function remove_xpadneo() {
    dkmsManager remove hid-xpadneo "$(_version_xpadneo)"
}

function configure_xpadneo() {
    if [[ "$md_mode" == "remove" ]]; then
        rm -f /etc/modprobe.d/xpadneo-rpie.conf
        return
    fi

    dkmsManager reload hid-xpadneo "$(_version_xpadneo)"

    # on v0.10 and later - disable shift mode key for the home/guide button
    local num_ver="$(_version_xpadneo | tr -d v)"
    if compareVersions "$num_ver" ge 0.10 && [[ ! -f "/etc/modprobe.d/xpadneo-rpie.conf" ]]; then
        echo "options hid-xpadneo disable_shift_mode=1" > /etc/modprobe.d/xpadneo-rpie.conf
    fi
}
