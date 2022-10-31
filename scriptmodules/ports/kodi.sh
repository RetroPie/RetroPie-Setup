#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="kodi"
rp_module_desc="Kodi - Open source home theatre software"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xbmc/xbmc/master/LICENSE.md"
rp_module_section="opt"
rp_module_flags="!mali !osmc !xbian"

function _update_hook_kodi() {
    # to show as installed in retropie-setup 4.x
    hasPackage kodi && mkdir -p "$md_inst"
}

function depends_kodi() {
    # Raspberry Pi OS
    if [[ "$__os_id" = "Raspbian" ]] && isPlatform "rpi"; then
        if [[ "$__os_debian_ver" -le 10 ]]; then
            if [[ "$md_mode" == "install" ]]; then
                # remove old repository
                rm -f /etc/apt/sources.list.d/mene.list
                echo "deb http://pipplware.pplware.pt/pipplware/dists/$__os_codename/main/binary/ ./" >/etc/apt/sources.list.d/pipplware.list
                download http://pipplware.pplware.pt/pipplware/key.asc - | apt-key add - &>/dev/null
            else
                rm -f /etc/apt/sources.list.d/pipplware.list
                apt-key del 4096R/BAA567BB >/dev/null
            fi
        fi
    # ubuntu
    elif [[ -n "$__os_ubuntu_ver" ]] && isPlatform "x86"; then
        if [[ "$md_mode" == "install" ]]; then
            apt-add-repository -y ppa:team-xbmc/ppa
        else
            apt-add-repository --remove -y ppa:team-xbmc/ppa
        fi
    # others
    else
        md_ret_errors+=("Sorry, but kodi is not installable for your OS/Platform via RetroPie-Setup")
        return 1
    fi

    # required for reboot/shutdown options. Don't try and remove if removing dependencies
    [[ "$md_mode" == "install" ]] && getDepends policykit-1

    addUdevInputRules
}

function install_bin_kodi() {
    # force aptInstall to get a fresh list before installing
    __apt_update=0

    # not all the kodi packages may be available depending on repository
    # so we will check and install what's available
    local all_pkgs=(kodi kodi-peripheral-joystick kodi-inputstream-adaptive kodi-vfs-libarchive kodi-vfs-sftp kodi-vfs-nfs)
    compareVersions "$__os_ubuntu_ver" lt 22.04 && all_pkgs+=(kodi-inputstream-rtmp)
    local avail_pkgs=()
    local pkg
    for pkg in "${all_pkgs[@]}"; do
        # check if the package is available - we use "madison" rather than "show"
        # as madison won't show referenced virtual packages which we don't want
        local ret=$(apt-cache madison "$pkg" 2>/dev/null)
        [[ -n "$ret" ]] && avail_pkgs+=("$pkg")
    done
    aptInstall "${avail_pkgs[@]}"
}

function remove_kodi() {
    aptRemove kodi
    rp_callModule kodi depends remove
}

function configure_kodi() {
    moveConfigDir "$home/.kodi" "$md_conf_root/kodi"

    addPort "$md_id" "kodi" "Kodi" "kodi-standalone"
}
