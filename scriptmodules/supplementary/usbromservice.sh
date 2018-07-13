#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="usbromservice"
rp_module_desc="USB ROM Service"
rp_module_section="main"

function _get_ver_usbromservice() {
    echo 0.0.24
}

function _update_hook_usbromservice() {
    [[ ! -f "$md_inst/disabled" ]] && install_scripts_usbromservice
}

function depends_usbromservice() {
    local depends=(rsync ntfs-3g exfat-fuse)
    if ! hasPackage usbmount $(_get_ver_usbromservice); then
        depends+=(debhelper devscripts pmount lockfile-progs)
        getDepends "${depends[@]}"
        gitPullOrClone "$md_build" https://github.com/RetroPie/usbmount.git systemd
        cd "$md_build"
        dpkg-buildpackage
        dpkg -i ../usbmount_*_all.deb
        rm -f ../usbmount_*
        rm -rf "$md_build"
    fi
}

function install_bin_usbromservice() {
    [[ ! -f "$md_inst/disabled" ]] && install_scripts_usbromservice
    touch "$md_inst/installed"
}

function install_scripts_usbromservice() {
    # copy our mount.d scripts over
    local file
    local dest
    for file in "$md_data/"*; do
        dest="/etc/usbmount/mount.d/${file##*/}"
        sed "s/USERTOBECHOSEN/$user/g" "$file" >"$dest"
        chmod +x "$dest"
    done
}

function enable_usbromservice() {
    rm -f "$md_inst/disabled"
    install_scripts_usbromservice
}

function disable_usbromservice() {
    local file
    for file in "$md_data/"*; do
        file="/etc/usbmount/mount.d/${file##*/}"
        rm -f "$file"
    done
    touch "$md_inst/disabled"
}

function remove_usbromservice() {
    disable_usbromservice
    apt-get remove -y usbmount
}

function configure_usbromservice() {
    iniConfig "=" '"' /etc/usbmount/usbmount.conf
    local fs
    for fs in ntfs exfat; do
        iniGet "FILESYSTEMS"
        if [[ "$ini_value" != *$fs* ]]; then
            iniSet "FILESYSTEMS" "$ini_value $fs"
        fi
    done
    iniGet "MOUNTOPTIONS"
    local uid=$(id -u $user)
    local gid=$(id -g $user)
    if [[ ! "$ini_value" =~ uid|gid ]]; then
        iniSet "MOUNTOPTIONS" "$ini_value,uid=$uid,gid=$gid"
    fi
}

function gui_usbromservice() {
    local cmd
    local options
    local choice
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose from an option below." 22 86 16)
        options=(
            1 "Enable USB ROM Service scripts"
            2 "Disable USB ROM Service scripts"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rp_callModule "$md_id" depends
                    rp_callModule "$md_id" enable
                    printMsgs "dialog" "Enabled $md_desc"
                    ;;
                2)
                    rp_callModule "$md_id" disable
                    printMsgs "dialog" "Disabled $md_desc"
                    ;;
            esac
        else
            break
        fi
    done
}
