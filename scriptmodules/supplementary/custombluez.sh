#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="custombluez"
rp_module_desc="Updated version of BlueZ Bluetooth stack"
rp_module_help="Install alongside 'sixaxis' driver if you need to pair third-party (Gasia/Shanwan) DualShock 3 controllers.\nNeeded only if your distribution's BlueZ version is <5.48."
rp_module_repo="git https://salsa.debian.org/bluetooth-team/bluez.git debian/5.50-1"
rp_module_licence="GPL2 http://www.bluez.org/faq/common/"
rp_module_section="driver"

function _version_custombluez() {
    echo "5.50-1~rpi1"
}

function depends_custombluez() {
    local depends=(bison check dh-systemd flex icu-devtools libasound2-dev libcap-ng-dev libdbus-1-dev libdbus-glib-1-dev libdw-dev libical-dev libicu-dev libreadline-dev libsubunit-dev libtinfo-dev libudev-dev)

    getDepends "${depends[@]}"
}

function sources_custombluez() {
    gitPullOrClone "$md_build/custombluez"
    cd "custombluez"
    applyPatch "$md_data/01_raspbian_patches.diff"
}

function build_custombluez() {
    rm -rf *.{buildinfo,changes,deb}
    pushd custombluez
    dpkg-buildpackage -b -us -uc
    popd
    md_ret_require+=("$md_build/bluetooth_$(_version_custombluez)_all.deb")
}

function _install_custombluez_packages() {
    local custombluez_depends=(bluetooth bluez libbluetooth3 libbluetooth-dev)
    local custombluez_optional=(bluez-cups bluez-hcidump bluez-obexd bluez-test-scripts)
    local custombluez_packages=()
    local mode="$1"
    local dest="$2"
    local optional

    for optional in "${custombluez_optional[@]}"; do
        hasPackage "$optional" && custombluez_depends+=("$optional")
    done

    if [[ "$mode" == "install" ]]; then
        local package
        pushd "$dest"
        for package in "${custombluez_depends[@]/%/_"$(_version_custombluez)"_"{all,$(dpkg --print-architecture)}".deb}"; do
            [[ -f "$package" ]] && custombluez_packages+=("$package")
        done
        dpkg --force-confnew -i "${custombluez_packages[@]}"
        popd
    elif [[ "$mode" == "remove" ]]; then
        custombluez_packages=("${custombluez_depends[@]/%//"$__os_codename"}")
        aptInstall --force-yes -o Dpkg::Options::="--force-confnew" "${custombluez_packages[@]}"
    fi
}

function install_custombluez() {
    _install_custombluez_packages "install" "$md_build"
}

function remove_custombluez() {
    _install_custombluez_packages "remove" ""
}
