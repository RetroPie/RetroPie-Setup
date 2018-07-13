#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gamecondriver"
rp_module_desc="Gamecon & db9 drivers"
rp_module_section="driver"
rp_module_flags="!x86 !mali"

function _update_hook_gamecondriver() {
    # to show as installed in retropie-setup 4.x
    hasPackage gamecon-gpio-rpi-dkms && mkdir -p "$md_inst"
}

function depends_gamecondriver() {
    # remove any old kernel headers for current kernel
    local kernel_ver="$(uname -r)"
    if hasPackage linux-headers-"${kernel_ver}" "${kernel_ver}-2" "eq"; then
        aptRemove "linux-headers-${kernel_ver}"
    fi
    getDepends dkms raspberrypi-kernel-headers
}

function install_bin_gamecondriver() {
    local gamecon_ver="1.3"
    local db9_ver="1.1"
    local url="https://www.niksula.hut.fi/~mhiienka/Rpi"

    # install gamecon
    local package
    for package in  gamecon-gpio-rpi-dkms_${gamecon_ver}_all.deb  db9-gpio-rpi-dkms_${db9_ver}_all.deb; do
        wget -q -O"$package" "${url}/$package"
        dpkg -i "$package"
    done

    # test if gamecon installation is OK
    if [[ -z "$(modinfo -n gamecon_gpio_rpi | grep gamecon_gpio_rpi.ko)" ]]; then
        md_ret_errors+=("Gamecon GPIO driver installation FAILED")
    fi

    # test if db9 installation is OK
    if [[ -z "$(modinfo -n db9_gpio_rpi | grep db9_gpio_rpi.ko)" ]]; then
        md_ret_errors+=("Db9 GPIO driver installation FAILED")
    fi
}

function remove_gamecondriver() {
    sed -i "/gamecon_gpio_rpi/d" /etc/modules
    rm -f /etc/modprobe.d/gamecon.conf
    aptRemove db9-gpio-rpi-dkms gamecon-gpio-rpi-dkms
}

function configure_gamecondriver() {
    [[ "$md_mode" == "remove" ]] && return

    if ! grep -q "gamecon_gpio_rpi" /etc/modules; then
        addLineToFile "gamecon_gpio_rpi" /etc/modules
    elif grep -q "gamecon_gpio_rpi.*map" /etc/modules; then
        sed -i "s/gamecon_gpio_rpi.*/gamecon_gpio_rpi/" /etc/modules
    fi
}

function dual_snes_gamecondriver() {
    local gpio_rev
    case "$(grep Revision /proc/cpuinfo | cut -d ':' -f 2 | tr -d ' \n' | tail -c 4)" in
        "0002"|"0003")
            gpio_rev=1
            ;;
        *)
            gpio_rev=2
            ;;
    esac

    if [[ "$gpio_rev" == 1 ]]; then
        echo "options gamecon_gpio_rpi map=0,1,1,0" >/etc/modprobe.d/gamecon.conf
    else
        echo "options gamecon_gpio_rpi map=0,0,1,0,0,1" >/etc/modprobe.d/gamecon.conf
    fi

    [[ -n "$(lsmod | grep gamecon_gpio_rpi)" ]] && rmmod gamecon_gpio_rpi
    modprobe gamecon_gpio_rpi

    iniConfig " = " "" "$configdir/all/retroarch.cfg"

    if dialog --yesno "Would you like to update button mappings in $configdir/all/retroarch.cfg for 2 SNES controllers?" 22 76 >/dev/tty; then
        if [[ "$GPIOREV" == 1 ]]; then
            iniSet "input_player1_joypad_index" "0"
            iniSet "input_player2_joypad_index" "1"
        else
            iniSet "input_player1_joypad_index" "1"
            iniSet "input_player2_joypad_index" "0"
        fi

        iniSet "input_player1_a_btn" "0"
        iniSet "input_player1_b_btn" "1"
        iniSet "input_player1_x_btn" "2"
        iniSet "input_player1_y_btn" "3"
        iniSet "input_player1_l_btn" "4"
        iniSet "input_player1_r_btn" "5"
        iniSet "input_player1_start_btn" "7"
        iniSet "input_player1_select_btn" "6"
        iniSet "input_player1_left_axis" "-0"
        iniSet "input_player1_up_axis" "-1"
        iniSet "input_player1_right_axis" "+0"
        iniSet "input_player1_down_axis" "+1"

        iniSet "input_player2_a_btn" "0"
        iniSet "input_player2_b_btn" "1"
        iniSet "input_player2_x_btn" "2"
        iniSet "input_player2_y_btn" "3"
        iniSet "input_player2_l_btn" "4"
        iniSet "input_player2_r_btn" "5"
        iniSet "input_player2_start_btn" "7"
        iniSet "input_player2_select_btn" "6"
        iniSet "input_player2_left_axis" "-0"
        iniSet "input_player2_up_axis" "-1"
        iniSet "input_player2_right_axis" "+0"
        iniSet "input_player2_down_axis" "+1"
    fi

    dialog --clear --msgbox "\
__________\n\
         |          ### Board gpio revision $gpio_rev detected ###\n\
    + *  |\n\
    * *  |\n\
    1 -  |          The driver is now set to use the following\n\
    2 *  |          configuration for 2 SNES controllers:\n\
    * *  |          (compatible with RetroPie GPIO adapter)\n\
    * *  |\n\
    * *  |          + = power\n\
    * *  |          - = ground\n\
    * *  |          C = clock\n\
    C *  |          L = latch\n\
    * *  |          1 = player1 pad\n\
    L *  |          2 = player2 pad\n\
    * *  |          * = unconnected\n\
         |\n\
         |" 22 76 >/dev/tty
}

function gui_gamecondriver() {
    local default

    local options=(
        1 "Configure for two SNES controllers"
        2 "Read Gamecon GPIO driver documentation"
        3 "Read Db9 GPIO driver documentation"
    )
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Choose an option." 22 86 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    dialog --defaultno --yesno "Gamecon driver supports RetroPie GPIO adapter board for 2 SNES controllers. Do you want to configure gamecon for 2 SNES controllers?"  22 76 >/dev/tty || continue
                    dual_snes_gamecondriver
                    ;;
                2)
                    dialog --msgbox "$(gzip -dc /usr/share/doc/gamecon_gpio_rpi/README.gz)" 22 76 >/dev/tty
                    ;;
                3)
                    dialog --msgbox "$(gzip -dc /usr/share/doc/db9_gpio_rpi/README.gz)" 22 76 >/dev/tty
                    ;;
            esac
        else
            break
        fi
    done

}
