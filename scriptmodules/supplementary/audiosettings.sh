rp_module_id="audiosettings"
rp_module_desc="Configure audio settings"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_audiosettings() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Set audio output." 22 86 16)
    options=(1 "Auto"
             2 "Headphones - 3.5mm jack"
             3 "HDMI"
             4 "Reset to default")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1) amixer cset numid=3 0
               alsactl store
               ###set
               dialog --backtitle "$__backtitle" --msgbox "Set audio output to auto" 22 76
                            ;;
            2) amixer cset numid=3 1
               alsactl store
               ###set
               dialog --backtitle "$__backtitle" --msgbox "Set audio output to headphones / 3.5mm jack " 22 76
                            ;;
            3) amixer cset numid=3 2
               alsactl store
               ###set
               dialog --backtitle "$__backtitle" --msgbox "Set audio output to HDMI" 22 76
                            ;;
            4) /etc/init.d/alsa-utils reset
               alsactl store
                 ###set
               dialog --backtitle "$__backtitle" --msgbox "Audio settings reset to defaults" 22 76
                            ;;
        esac
    else
        break
    fi
}