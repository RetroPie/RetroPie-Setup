#!/usr/bin/env bash

# This file is part of the microplay-hub
# Designs by Liontek1985
# for RetroPie and offshoot
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
# xboxdrvnxscript v1.9 - 2023-03-07
# CC BY-NC-SA 4.0

rp_module_id="xboxdrvnxt"
rp_module_desc="Xbox 360/Classic driver -nxt (max compatibility)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/zerojay/xboxdrv/stable/COPYING"
rp_module_repo="git https://github.com/Liontek1985/xboxdrv-nxt.git retropie-stable"
rp_module_section="driver"

function def_controllers_xboxdrvnxt() {
    echo "2"
}

function def_deadzone_xboxdrvnxt() {
    echo "4000"
}

function depends_xboxdrvnxt() {
    getDepends libboost-dev libusb-1.0-0-dev libudev-dev libx11-dev scons pkg-config python3 x11proto-core-dev libdbus-glib-1-dev
}

function sources_xboxdrvnxt() {
    gitPullOrClone
}

function build_xboxdrvnxt() {
    python3 /usr/bin/scons
}

function install_xboxdrvnxt() {
    make install PREFIX="$md_inst"
}

function enable-xclassic_xboxdrvnxt() {
    local controllers="$1"
    local deadzone="$2"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrvnxt)"
    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrvnxt)"

    local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --dbus disabled --detach-kernel-driver"

    local i
    for (( i=0; i<$controllers; i++)); do
        [[ $i -gt 0 ]] && config+=" --next-controller"
        config+=" --type xbox --id $i --led $((i+2)) --deadzone $deadzone --trigger-as-button --silent & sleep 1"
    done

    if grep -q "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf; then
        dialog --yesno "xpad is already blacklisted in /etc/modprobe.d/fbdev-blacklist.conf with the following config. Do you want to update it ?\n\n$(grep "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/blacklist xpad/d" /etc/modprobe.d/fbdev-blacklist.conf
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/modprobe.d/fbdev-blacklist.conf

    if grep -q "xboxdrv" /etc/rc.local; then
        dialog --yesno "xboxdrv is already enabled in /etc/rc.local with the following config. Do you want to update it ?\n\n$(grep "xboxdrv" /etc/rc.local)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/xboxdrv/d" /etc/rc.local
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "xboxdrv for wired-controllers enabled in /etc/rc.local with the following config\n\n$config\n\nIt will be started on next boot."
}

function enable-x360_xboxdrvnxt() {
    local controllers="$1"
    local deadzone="$2"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrvnxt)"
    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrvnxt)"

    local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --dbus disabled --detach-kernel-driver"

    local i
    for (( i=0; i<$controllers; i++)); do
        [[ $i -gt 0 ]] && config+=" --next-controller"
        config+=" --type xbox360 --id $i --led $((i+2)) --deadzone $deadzone --trigger-as-button --silent & sleep 1"
    done

    if grep -q "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf; then
        dialog --yesno "xpad is already blacklisted in /etc/modprobe.d/fbdev-blacklist.conf with the following config. Do you want to update it ?\n\n$(grep "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/blacklist xpad/d" /etc/modprobe.d/fbdev-blacklist.conf
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/modprobe.d/fbdev-blacklist.conf

    if grep -q "xboxdrv" /etc/rc.local; then
        dialog --yesno "xboxdrv is already enabled in /etc/rc.local with the following config. Do you want to update it ?\n\n$(grep "xboxdrv" /etc/rc.local)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/xboxdrv/d" /etc/rc.local
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "xboxdrv for wired-controllers enabled in /etc/rc.local with the following config\n\n$config\n\nIt will be started on next boot."
}

function enable-x360w_xboxdrvnxt() {
    local controllers="$1"
    local deadzone="$2"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrvnxt)"
    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrvnxt)"

    local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --dbus disabled --detach-kernel-driver"

    local i
    for (( i=0; i<$controllers; i++)); do
        [[ $i -gt 0 ]] && config+=" --next-controller"
        config+=" --type xbox360-wireless --wid $i --led $((i+2)) --deadzone $deadzone --trigger-as-button --silent & sleep 1"
    done

    if grep -q "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf; then
        dialog --yesno "xpad is already blacklisted in /etc/modprobe.d/fbdev-blacklist.conf with the following config. Do you want to update it ?\n\n$(grep "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/blacklist xpad/d" /etc/modprobe.d/fbdev-blacklist.conf
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/modprobe.d/fbdev-blacklist.conf

    if grep -q "xboxdrv" /etc/rc.local; then
        dialog --yesno "xboxdrv is already enabled in /etc/rc.local with the following config. Do you want to update it ?\n\n$(grep "xboxdrv" /etc/rc.local)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/xboxdrv/d" /etc/rc.local
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "xboxdrv for wireless-controllers enabled in /etc/rc.local with the following config\n\n$config\n\nIt will be started on next boot."
}

function blackliston_xboxdrvnxt() {

    if grep -q "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf; then
        dialog --yesno "xpad is already blacklisted in /etc/modprobe.d/fbdev-blacklist.conf with the following config. Do you want to update it ?\n\n$(grep "blacklist xpad" /etc/modprobe.d/fbdev-blacklist.conf)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/blacklist xpad/d" /etc/modprobe.d/fbdev-blacklist.conf
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/modprobe.d/fbdev-blacklist.conf

    printMsgs "dialog" "xpad blacklisted in /etc/modprobe.d/fbdev-blacklist.conf this fix controller issues"
}

function blacklistoff_xboxdrvnxt() {

    sed -i "/blacklist xpad/d" /etc/modprobe.d/fbdev-blacklist.conf

    printMsgs "dialog" "remove xpad from blacklist in /etc/modprobe.d/fbdev-blacklist.conf"
}

function blacklistnew_xboxdrvnxt() {
	cd /etc/modprobe.d
	cat > fbdev-blacklist.conf
    chown -R $user:$user "fbdev-blacklist.conf"
	chmod 755 "fbdev-blacklist.conf"
    printMsgs "dialog" "create an new blacklist /etc/modprobe.d/fbdev-blacklist.conf"
}


function disable_xboxdrvnxt() {
    sed -i "/xboxdrv/d" /etc/rc.local
    sed -i "/blacklist xpad/d" /etc/modprobe.d/fbdev-blacklist.conf
    printMsgs "dialog" "xboxdrv configuration in /etc/rc.local has been removed."
}

function controllers_xboxdrvnxt() {
    local controllers="$1"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrvnxt)"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$controllers" --menu "Select the number of controllers to enable" 22 86 16)
    local options=(
        1 "1 controller"
        2 "2 controllers"
        3 "3 controllers"
        4 "4 controllers"
    )

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        controllers="$choice"
    fi

    echo "$controllers"
}

function deadzone_xboxdrvnxt() {
    local deadzone="$1"

    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrvnxt)"

    local zones=()
    local options=()
    local i
    local label
    local default
    for i in {0..12}; do
        zones[i]=$((i*500))
        [[ ${zones[i]} -eq $deadzone ]] && default=$i
        label="0-${zones[i]}"
        [[ "$i" -eq 0 ]] && label="No Deadzone"
        options+=($i "$label")
    done

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Select range of your analog stick deadzone" 22 86 16)

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        deadzone="${zones[$choice]}"
    fi

    echo "$deadzone"
}

function configure_xboxdrvnxt() {
    # make sure existing configs will point to the new xboxdrv
    sed -i "s|^xboxdrv|\"$md_inst/bin/xboxdrv\"|" /etc/rc.local
}

function gui_xboxdrvnxt() {
    if [[ ! -f "$md_inst/bin/xboxdrv" ]]; then
        if [[ $__has_binaries -eq 1 ]]; then
            rp_callModule "$md_id" depends
            rp_callModule "$md_id" install_bin
            rp_callModule "$md_id" configure
        else
            rp_callModule "$md_id"
        fi
    fi
    iniConfig "=" "" "/boot/config.txt"

    local controllers="$(def_controllers_xboxdrvnxt)"
    local deadzone="$(def_deadzone_xboxdrvnxt)"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)

    while true; do
        local options=(
            1 "Enable Xbox360 driver (Wired)"
            2 "Enable Xbox360 driver (Wireless)"
            3 "Enable Xbox-Classic driver (Wired)"			
            4 "Disable xboxdrv"
            5 "Set number of controllers to enable (currently $controllers)"
            6 "Set analog stick deadzone (currently $deadzone)"
            7 "Controller Fix (blacklist xpad)"
            8 "remove xpad from blacklist"
            9 "create new blacklist file"
            10 "Set dwc_otg.speed=1 in /boot/config.txt"
            11 "Remove dwc_otg.speed=1 from /boot/config.txt"
            TEK "### Script by Liontek1985 ###"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then

            case "$choice" in
                1)
                    enable-x360_xboxdrvnxt "$controllers" "$deadzone"
                    ;;
                2)
                    enable-x360w_xboxdrvnxtw "$controllers" "$deadzone"
                    ;;
                3)
                    enable-xclassic_xboxdrvnxtw "$controllers" "$deadzone"
                    ;;
                4)
                    disable_xboxdrvnxt
                    ;;
                5)
                    controllers=$(controllers_xboxdrvnxt $controllers)
                    ;;
                6)
                    deadzone=$(deadzone_xboxdrvnxt $deadzone)
                    ;;
                7)
                    blackliston_xboxdrvnxt
                    ;;
                8)
                    blacklistoff_xboxdrvnxt
                    ;;
                9)
                    blacklistnew_xboxdrvnxt
                    ;;
                10)
                    iniSet "dwc_otg.speed" "1"
                    printMsgs "dialog" "dwc_otg.speed=1 has been set in /boot/config.txt"
                    ;;
                11)
                    iniDel "dwc_otg.speed"
                    printMsgs "dialog" "dwc_otg.speed=1 has been removed from /boot/config.txt"
                    ;;
				
            esac
        else
            break
        fi
    done
}
