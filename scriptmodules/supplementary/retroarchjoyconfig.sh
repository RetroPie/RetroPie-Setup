rp_module_id="retroarchjoyconfig"
rp_module_desc="Register RetroArch controller"
rp_module_menus="3+"
rp_module_flags="nobindist"

function configure_retroarchjoyconfig() {
    local configfname
    local numJoypads

    dialog --backtitle "$__backtitle" --msgbox "Connect ONLY the controller to be registered for RetroArch to the Raspberry Pi." 22 76
    clear
    # todo Find number of first joystick device in /dev/input
    numJoypads=$(ls -1 /dev/input/js* | head -n 1)
    $emudir/retroarch/retroarch-joyconfig --autoconfig "$emudir/retroarch/configs/tempconfig.cfg" --timeout 4 --joypad ${numJoypads:13}
    configfname=`grep "input_device = \"" "$emudir/retroarch/configs/tempconfig.cfg"`
    configfname=`echo ${configfname:16:-1} | tr -d ' '`
    mv "$emudir/retroarch/configs/tempconfig.cfg" "$emudir/retroarch/configs/$configfname.cfg"
    chown -R $user:$user "$emudir/retroarch/configs"
    dialog --backtitle "$__backtitle" --msgbox "The configuration file has been saved as $configfname.cfg and will be used by RetroArch from now on whenever that controller is connected." 22 76
}
