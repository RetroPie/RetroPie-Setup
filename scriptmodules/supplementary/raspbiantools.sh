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

    # on Buster, use the legacy Raspbian archive for package installation
    buster_fix_apt_raspbiantools

    # on Buster, always install the Bluez package from the RPI repos
    buster_bluez_pin_raspbiantools

    # remove our own SDL1 package for non-dispmanx/non-videocore platforms
    if isPlatform "rpi" && ! isPlatform "dispmanx"; then
        sdl1_replace_raspbiantools
    fi

    aptUpdate
    apt-get -y dist-upgrade --allow-downgrades
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

    # Firefox is supported starting with Bookworm, install it along with Chromium
    [[ "$__os_debian_ver" -ge 12 ]] && aptInstall --no-install-recommends firefox rpi-firefox-mods

    setConfigRoot "ports"
    addPort "lxde" "lxde" "Desktop" "XINIT:startx"
    if (isPlatform "rpi4" || isPlatform "rpi5")  && [[ "$__os_debian_ver" -ge 12 ]]; then
        addPort "wayfire" "wayfire" "Desktop (Wayland)" "wayfire-pi"
    fi
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

function buster_fix_apt_raspbiantools() {
    if isPlatform "rpi" && [[ "$__os_debian_ver" -eq 10 ]]; then
        sed -i 's/raspbian\.raspberrypi\.org/legacy.raspbian.org/' /etc/apt/sources.list
    fi
}

function buster_bluez_pin_raspbiantools() {
    # pin the 'bluez' package to the RPI repos to prevent any Debian updates overwriting it
    # use Priority 1001 to force the the installation even when the Debian package is installed
    local pin_file="/etc/apt/preferences.d/01-bluez-pin"
    if isPlatform "rpi" && [[ "$__os_debian_ver" -eq 10 && ! -f "$pin_file" ]] ; then
        cat << PIN_EOF > "$pin_file"
Package: bluez
Pin: origin archive.raspberrypi.org
Pin-Priority: 1001
PIN_EOF
    fi
}

function sdl1_replace_raspbiantools() {
    local inst_ver="$(dpkg-query --show --showformat '${Version}' libsdl1.2-dev)"
    local sdl1_ver="$(get_pkg_ver_sdl1)"
    local repo_ver="$(apt-cache madison libsdl1.2-dev | head -n 1 | cut -d'|' -f 2 | tr -d '[:blank:]')"
    # check if the version installed is our own
    [[ -z "$inst_ver" || ! "$inst_ver" == "$sdl1_ver" || -z "$repo_ver" ]] && return
    printMsgs "console" "Replacing RetroPie SDL1 version since it's not needed anymore"
    apt-get -y --allow-downgrades --allow-change-held-packages install libsdl1.2debian=$repo_ver libsdl1.2-dev=$repo_ver

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

function enable_zram_raspbiantools() {
    if [[ "$__os_id" == "Raspbian" ]] || [[ "$__os_id" == "Debian" ]]; then
        aptInstall zram-tools
        # Use 50% of the current memory for ZRAM
        local percent="50"
        iniConfig "=" "" "/etc/default/zramswap"
        # Raspbian Buster uses keyword PERCENTAGE
        iniSet "PERCENTAGE" "$percent"
        # Debian Bullseye/Bookworm use keyword PERCENT
        iniSet "PERCENT" "$percent"
        # Use zstd compression algorithm if kernel supports it
        [[ -f /sys/class/block/zram0/comp_algorithm ]] && [[ "$(cat /sys/class/block/zram0/comp_algorithm)" == *zstd* ]] && iniSet "ALGO" "zstd"
        service zramswap stop
        service zramswap start
    elif [[ "$__os_id" == "Ubuntu" ]]; then
        aptInstall zram-config
        # Ubuntu has a automatic zram configuration
    fi
}

function disable_zram_raspbiantools() {
    if [[ "$__os_id" == "Raspbian" ]] || [[ "$__os_id" == "Debian" ]]; then
        aptRemove zram-tools
    elif [[ "$__os_id" == "Ubuntu" ]]; then
        aptRemove zram-config
    fi
}

function gui_raspbiantools() {
    while true; do
        local zram_status="Enable"
        [[ $(cat /proc/swaps) == *zram* ]] && zram_status="Disable"
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Upgrade Raspbian packages"
            2 "Install Pixel desktop environment"
            3 "Remove some unneeded packages (pulseaudio / cups / wolfram)"
            4 "Disable screen blanker"
            5 "Enable needed kernel module uinput"
        )
        # exclude ZRAM config for Armbian, it is handled by `armbian-config`
        ! isPlatform "armbian" && options+=(6 "$zram_status compressed memory (ZRAM)")

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
                6)
                    [[ "$zram_status" == "Enable" ]] && rp_callModule "$md_id" enable_zram || rp_callModule "$md_id" disable_zram
                    ;;
            esac
        else
            break
        fi
    done
}
