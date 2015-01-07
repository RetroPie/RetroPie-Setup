rp_module_id="xarcade2jstick"
rp_module_desc="Xarcade2Jstick"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function sources_xarcade2jstick() {
    gitPullOrClone "$md_inst" https://github.com/petrockblog/Xarcade2Joystick.git
}

function build_xarcade2jstick() {
    cd "$md_inst"
    make
}

function install_xarcade2jstick() {
    cd "$md_inst"
    make install
}

function sup_checkInstallXarcade2Jstick() {
    if [[ ! -d "$md_inst" ]]; then
        sources_xarcade2jstick
        build_xarcade2jstick
        install_xarcade2jstick
    fi
}

function configure_xarcade2jstick() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable Xarcade2Jstick service."
             2 "Enable Xarcade2Jstick service." )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) sup_checkInstallXarcade2Jstick
               make uninstallservice
               dialog --backtitle "$__backtitle" --msgbox "Disabled Xarcade2Jstick." 22 76
                            ;;
            2) sup_checkInstallXarcade2Jstick
               make installservice
               dialog --backtitle "$__backtitle" --msgbox "Enabled Xarcade2Jstick service." 22 76
                            ;;
        esac
    else
        break
    fi
}