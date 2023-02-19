#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="raspbiantools"
rp_module_desc="Raspbian related tools"
rp_module_section="config"
rp_module_flags="!all rpi"

function apt_upgrade_raspbiantools() {
    # install an older kernel/firmware for stretch to resolve newer kernel issues or unhold if updating to a newer release
    stretch_fix_raspbiantools

    aptUpdate
    apt-get -y dist-upgrade
}

function lxde_raspbiantools() {
    aptInstall --no-install-recommends xorg lxde
    aptInstall raspberrypi-ui-mods rpi-chromium-mods gvfs
    # On `buster`, disable PulseAudio since it messes up the audio settings
    # remove the lxpanel plugin for PulseAudio volume, to prevent a crash due to missing PulseAudio
    #  and install the volume lxpanel plugin that supports ALSA
    if [[ "$__os_debian_ver" -lt 11 ]]; then
       __toggle_pulseaudio_audiosettings "off"
       aptRemove  lxplug-volumepulse
       aptInstall lxplug-volume
    fi

    setConfigRoot "ports"
    addPort "lxde" "lxde" "Desktop" "XINIT:startx"
    enable_autostart
}

function package_cleanup_raspbiantools() {
    # remove PulseAudio since this is slowing down the whole system significantly. Cups is also not needed
    apt-get remove -y pulseaudio cups wolfram-engine sonic-pi
    apt-get -y autoremove
}

function disable_blanker_raspbiantools() {
    sed -i 's/BLANK_TIME=\d*/BLANK_TIME=0/g' /etc/kbd/config
    sed -i 's/POWERDOWN_TIME=\d*/POWERDOWN_TIME=0/g' /etc/kbd/config
}

function stretch_fix_raspbiantools() {
    # install an older kernel/firmware and hold it for stretch to resolve sony bt, composite
    # and overscan issues, but also unhold for newer Raspbian versions to allow upgrading.
    local ver="1.20190401-1"
    # make sure we are on a rpi and have the raspberrypi-kernel package
    if isPlatform "rpi" && hasPackage raspberrypi-kernel; then
        if [[ "$__os_debian_ver" -eq 9 ]]; then
            # for Raspbian 9 (stretch) we want to install / hold the older kernel
            install_firmware_raspbiantools "$ver" hold
        elif hasPackage raspberrypi-kernel "$ver" eq; then
            # if we are not running Raspbian 9 (stretch), but are running the old kernel
            # we want to unhold it to allow kernel updates again
            install_firmware_raspbiantools "$ver" unhold
        fi
    fi
}

function install_firmware_raspbiantools() {
    local ver="$1"
    local state="$2"
    [[ -z "$ver" ]] && return 1

    local url="http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware"

    mkdir -p "$md_build"
    pushd "$md_build" >/dev/null

    local pkg
    local pkgs=(raspberrypi-bootloader libraspberrypi0 libraspberrypi-doc libraspberrypi-dev libraspberrypi-bin raspberrypi-kernel-headers raspberrypi-kernel)
    local deb

    # download all packages then install later to reduce issues if interrupted or a networking issue
    for pkg in "${pkgs[@]}"; do
        if hasPackage "$pkg" "$ver" ne; then
            deb="${pkg}_${ver}_armhf.deb"
            if ! download "$url/$deb"; then
               md_ret_errors+=("Failed to download $deb")
               return 1
            fi
        fi
    done

    # install packages if needed
    for pkg in "${pkgs[@]}"; do
        deb="${pkg}_${ver}_armhf.deb"
        if hasPackage "$pkg" "$ver" ne && [[ -f "$deb" ]]; then
            dpkg -i "$deb"
            rm "$deb"
        fi
        # set package state
        [[ -n "$state" ]] && apt-mark "$state" "$pkg"
    done

    popd >/dev/null
    rm -rf "$md_build"

    return 0
}

function enable_modules_raspbiantools() {
    sed -i '/snd_bcm2835/d' /etc/modules

    local modules=(uinput)

    local module
    for module in "${modules[@]}"; do
        modprobe $module
        if ! grep -q "$module" /etc/modules; then
            addLineToFile "$module" "/etc/modules"
        else
            echo "$module module already contained in /etc/modules"
        fi
    done
}

function gui_raspbiantools() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Upgrade Raspbian packages"
            2 "Install Pixel desktop environment"
            3 "Remove some unneeded packages (pulseaudio / cups / wolfram)"
            4 "Disable screen blanker"
            5 "Enable needed kernel module uinput"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rp_callModule "$md_id" apt_upgrade
                    ;;
                2)
                    dialog --defaultno --yesno "Are you sure you want to install the Pixel desktop?" 22 76 2>&1 >/dev/tty || continue
                    rp_callModule "$md_id" lxde
                    printMsgs "dialog" "Pixel desktop/LXDE is installed."
                    ;;
                3)
                    rp_callModule "$md_id" package_cleanup
                    ;;
                4)
                    rp_callModule "$md_id" disable_blanker
                    ;;
                5)
                    rp_callModule "$md_id" enable_modules
                    ;;
            esac
        else
            break
        fi
    done
}
