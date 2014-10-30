rp_module_id="hotkey"
rp_module_desc="Change hotkey behaviour"
rp_module_menus="3+"

function configure_hotkey() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired hotkey behaviour." 22 76 16)
    options=(1 "Hotkeys enabled. (default)"
             2 "Press ALT to enable hotkeys."
             3 "Hotkeys disabled. Press ESCAPE to open RGUI.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) ensureKeyValue "input_enable_hotkey" "nul" "$rootdir/configs/all/retroarch.cfg"
               ensureKeyValue "input_exit_emulator" "escape" "$rootdir/configs/all/retroarch.cfg"
               ensureKeyValue "input_menu_toggle" "F1" "$rootdir/configs/all/retroarch.cfg"
                            ;;
            2) ensureKeyValue "input_enable_hotkey" "alt" "$rootdir/configs/all/retroarch.cfg"
               ensureKeyValue "input_exit_emulator" "escape" "$rootdir/configs/all/retroarch.cfg"
               ensureKeyValue "input_menu_toggle" "F1" "$rootdir/configs/all/retroarch.cfg"
                            ;;
            3) ensureKeyValue "input_enable_hotkey" "escape" "$rootdir/configs/all/retroarch.cfg"
               ensureKeyValue "input_exit_emulator" "nul" "$rootdir/configs/all/retroarch.cfg"
               ensureKeyValue "input_menu_toggle" "escape" "$rootdir/configs/all/retroarch.cfg"
                            ;;
        esac
    else
        break
    fi
}
