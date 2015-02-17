rp_module_id="gamecondriver"
rp_module_desc="Gamecon driver"
rp_module_menus="3+install"
rp_module_flags="nobin"

function install_gamecondriver() {
    GAMECON_VER=0.9
    DB9_VER=0.7
    DOWNLOAD_LOC="http://www.niksula.hut.fi/~mhiienka/Rpi"

    clear

    dialog --title " GPIO gamepad drivers installation " --clear \
    --yesno "GPIO gamepad drivers require that most recent kernel (firmware)\
    is installed and active. Continue with installation?" 22 76
    case $? in
      0)
        echo "Starting installation.";;
      *)
        return 0;;
    esac

    #install dkms
    getDepends dkms

    #reconfigure / install headers (takes a a while)
    if [[ "$(dpkg-query -W -f='${Version}' linux-headers-$(uname -r))" == "$(uname -r)-2" ]]; then
        dpkg-reconfigure linux-headers-$(uname -r)
    else
        wget ${DOWNLOAD_LOC}/linux-headers-rpi/linux-headers-$(uname -r)_$(uname -r)-2_armhf.deb
        dpkg -i linux-headers-$(uname -r)_$(uname -r)-2_armhf.deb
        rm linux-headers-$(uname -r)_$(uname -r)-2_armhf.deb
    fi

    #install gamecon
    if [[ "$(dpkg-query -W -f='${Version}' gamecon-gpio-rpi-dkms)" == ${GAMECON_VER} ]]; then
        #dpkg-reconfigure gamecon-gpio-rpi-dkms
        echo "gamecon is the newest version"
    else
        wget ${DOWNLOAD_LOC}/gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb
        dpkg -i gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb
        rm gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb
    fi

    #install db9 joystick driver
    if [[ "$(dpkg-query -W -f='${Version}' db9-gpio-rpi-dkms)" == ${DB9_VER} ]]; then
        echo "db9 is the newest version"
    else
        wget ${DOWNLOAD_LOC}/db9-gpio-rpi-dkms_${DB9_VER}_all.deb
        dpkg -i db9-gpio-rpi-dkms_${DB9_VER}_all.deb
        rm db9-gpio-rpi-dkms_${DB9_VER}_all.deb
    fi

    #test if gamecon installation is OK
    if [[ -n $(modinfo -n gamecon_gpio_rpi | grep gamecon_gpio_rpi.ko) ]]; then
        dialog --backtitle "$__backtitle" --msgbox "$(gzip -dc /usr/share/doc/gamecon_gpio_rpi/README.gz)" 22 76
    else
        dialog --backtitle "$__backtitle" --msgbox "Gamecon GPIO driver installation FAILED"\
        22 76
    fi

    #test if db9 installation is OK
    if [[ -n $(modinfo -n db9_gpio_rpi | grep db9_gpio_rpi.ko) ]]; then
            dialog --backtitle "$__backtitle" --msgbox "Db9 GPIO driver successfully installed. \
        Use 'zless /usr/share/doc/db9_gpio_rpi/README.gz' to read how to use it." 22 76
    else
        dialog --backtitle "$__backtitle" --msgbox "Db9 GPIO driver installation FAILED"\
        22 76
    fi
}

function configure_gamecondriver() {
    if [[ "$(dpkg-query -W -f='${Status}' gamecon-gpio-rpi-dkms)" != "install ok installed" ]]; then
        dialog --msgbox "gamecon_gpio_rpi not found, install it first" 22 76
        return 0
    fi

    REVSTRING=$(grep Revision /proc/cpuinfo | cut -d ':' -f 2 | tr -d ' \n' | tail -c 4)
    case "$REVSTRING" in
          "0002"|"0003")
             GPIOREV=1
             ;;
          *)
             GPIOREV=2
             ;;
    esac

dialog --msgbox "\
__________\n\
         |          ### Board gpio revision $GPIOREV detected ###\n\
    + *  |\n\
    * *  |\n\
    1 -  |          The driver is set to use the following configuration\n\
    2 *  |          for 2 SNES controllers:\n\
    * *  |\n\
    * *  |\n\
    * *  |          + = power\n\
    * *  |          - = ground\n\
    * *  |          C = clock\n\
    C *  |          L = latch\n\
    * *  |          1 = player1 pad\n\
    L *  |          2 = player2 pad\n\
    * *  |          * = unconnected\n\
         |\n\
         |" 22 76

    if [[ -n $(lsmod | grep gamecon_gpio_rpi) ]]; then
        rmmod gamecon_gpio_rpi
    fi

    if [[ $GPIOREV == 1 ]]; then
        modprobe gamecon_gpio_rpi map=0,1,1,0
    else
        modprobe gamecon_gpio_rpi map=0,0,1,0,0,1
    fi

    dialog --title " Update $configdir/all/retroarch.cfg " --clear \
        --yesno "Would you like to update button mappings \
    to $configdir/all/retroarch.cfg ?" 22 76

    iniConfig " = " "" "$configdir/all/retroarch.cfg"

      case $? in
       0)
        if [[ $GPIOREV == 1 ]]; then
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
        ;;
       *)
        ;;
      esac

    dialog --title " Enable SNES configuration permanently " --clear \
        --yesno "Would you like to permanently enable SNES configuration?\
        " 22 76

    case $? in
      0)
    if ! grep "gamecon_gpio_rpi" /etc/modules; then
        if [[ $GPIOREV == 1 ]]; then
            addLineToFile "gamecon_gpio_rpi map=0,1,1,0" "/etc/modules"
        else
            addLineToFile "gamecon_gpio_rpi map=0,0,1,0,0,1" "/etc/modules"
        fi
    fi
    ;;
      *)
        #TODO: delete the line from /etc/modules
        ;;
    esac

    dialog --backtitle "$__backtitle" --msgbox \
    "Gamecon GPIO driver enabled with 2 SNES pads." 22 76
}
