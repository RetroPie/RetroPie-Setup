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
rp_module_menus="3+"
rp_module_flags="nobin !x86 !mali"

function depends_gamecondriver() {
    getDepends dkms gcc-4.7
}

function install_gamecondriver() {
    local GAMECON_VER="1.0"
    local DB9_VER="1.0"
    local DOWNLOAD_LOC="http://www.niksula.hut.fi/~mhiienka/Rpi"

    clear

    dialog \
        --title "GPIO gamepad drivers installation" --clear \
        --yesno "GPIO gamepad drivers require that most recent kernel (firmware) is installed and active. Continue with installation?" \
        22 76 >/dev/tty || return 0

    clear
    printMsgs "console" "Starting installation."

    # install kernel headers (takes a a while)
    local kernel_ver="$(uname -r)"
    if ! hasPackage linux-headers-"${kernel_ver}" "${kernel_ver}-2" "eq"; then
        local package_file="linux-headers-${kernel_ver}_${kernel_ver}-2_armhf.deb"
        if wget -nv "${DOWNLOAD_LOC}/linux-headers-rpi/$package_file"; then
            dpkg -i "$package_file"
            rm -f "$package_file"
        else
            printMsgs "dialog" "No linux-headers package could be found for your kernel version at ${DOWNLOAD_LOC} - this could be due to you running a new kernel that is not yet supported, or if you are using the BerryBoot image, which shares the BerryBoot kernel between all OSes - in which case you will need to manually set this up"
            return 0
        fi
    fi

    # install gamecon
    if hasPackage gamecon-gpio-rpi-dkms "${DB9_VER}" "eq"; then
        printMsgs "console" "gamecon is the newest version"
    else
        wget "${DOWNLOAD_LOC}/gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb"
        dpkg -i "gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb"
        rm -f "gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb"
    fi

    # install db9 joystick driver
    if hasPackage db9-gpio-rpi-dkms "${DB9_VER}" "eq"; then
        printMsgs "console" "db9 is the newest version"
    else
        wget "${DOWNLOAD_LOC}/db9-gpio-rpi-dkms_${DB9_VER}_all.deb"
        dpkg -i "db9-gpio-rpi-dkms_${DB9_VER}_all.deb"
        rm -f "db9-gpio-rpi-dkms_${DB9_VER}_all.deb"
    fi

    # test if gamecon installation is OK
    if [[ -n "$(modinfo -n gamecon_gpio_rpi | grep gamecon_gpio_rpi.ko)" ]]; then
        if dialog --clear --yesno "Gamecon GPIO driver successfully installed. Would you like to see README?" \
            22 76 >/dev/tty; then
            dialog --msgbox "$(gzip -dc /usr/share/doc/gamecon_gpio_rpi/README.gz)" 22 76 >/dev/tty
        fi
    else
        printMsgs "dialog" "Gamecon GPIO driver installation FAILED"
        return 0
    fi

    # test if db9 installation is OK
    if [[ -n "$(modinfo -n db9_gpio_rpi | grep db9_gpio_rpi.ko)" ]]; then
        if dialog --clear --yesno "Db9 GPIO driver successfully installed. Would you like to see README?" \
            22 76 >/dev/tty; then
            dialog --msgbox "$(gzip -dc /usr/share/doc/db9_gpio_rpi/README.gz)" 22 76 >/dev/tty
        fi
    else
        printMsgs "dialog" "Db9 GPIO driver installation FAILED"
        return 0
    fi
}

function configure_gamecondriver() {
    ! hasPackage gamecon-gpio-rpi-dkms && return 0

    dialog \
        --title "Configuration for SNES controllers" --clear \
        --yesno "Gamecon driver supports RetroPie GPIO adapter board for 2 SNES controllers. Do you want to configure gamecon for 2 SNES controllers?" \
        22 76 >/dev/tty || return 0

    clear
    printMsgs "console" "Configuring gamecon for 2 SNES controllers."

    REVSTRING=$(grep Revision /proc/cpuinfo | cut -d ':' -f 2 | tr -d ' \n' | tail -c 4)
    case "$REVSTRING" in
        "0002"|"0003")
            GPIOREV=1
            ;;
        *)
            GPIOREV=2
            ;;
    esac

    if [[ -n $(lsmod | grep gamecon_gpio_rpi) ]]; then
        rmmod gamecon_gpio_rpi
    fi

    if [[ "$GPIOREV" == 1 ]]; then
        modprobe gamecon_gpio_rpi map=0,1,1,0
    else
        modprobe gamecon_gpio_rpi map=0,0,1,0,0,1
    fi

    dialog --clear --msgbox "\
__________\n\
         |          ### Board gpio revision $GPIOREV detected ###\n\
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

    iniConfig " = " "" "$configdir/all/retroarch.cfg"

    if dialog --title " Update $configdir/all/retroarch.cfg " --clear \
    --yesno "Would you like to update button mappings \
    in $configdir/all/retroarch.cfg \
    for 2 SNES controllers?" 22 76 >/dev/tty; then
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

    dialog \
        --title " Enable SNES configuration permanently " --clear \
        --yesno "Would you like to permanently enable the SNES configuration?" \
        22 76 >/dev/tty

    case $? in
        0)
            if ! grep -q "gamecon_gpio_rpi" "/etc/modules"; then
                addLineToFile "gamecon_gpio_rpi" "/etc/modules"
            else
                # replace old config with option in /etc/modules
                sed -i "s/gamecon_gpio_rpi.*/gamecon_gpio_rpi/" /etc/modules
            fi
            if [[ ! -f "/etc/modprobe.d/gamecon.conf" ]]; then
                if [[ "$GPIOREV" == 1 ]]; then
                    echo "options gamecon_gpio_rpi map=0,1,1,0" >/etc/modprobe.d/gamecon.conf
                else
                    echo "options gamecon_gpio_rpi map=0,0,1,0,0,1" >/etc/modprobe.d/gamecon.conf
                fi
            fi
            printMsgs "dialog" "Gamecon GPIO driver is now permanently enabled with SNES configuration."
            ;;
        *)
            sed -i "/gamecon_gpio_rpi/d" /etc/modules
            ;;
    esac
}
