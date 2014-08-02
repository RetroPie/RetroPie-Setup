rp_module_id="retroarchjoyconfig"
rp_module_desc="Register RetroArch controller"
rp_module_menus="3+"

function configure_retroarchjoyconfig() {
    local configfname
    local numJoypads

    dialog --backtitle "$__backtitle" --msgbox "Connect ONLY the controller to be registered for RetroArch to the Raspberry Pi." 22 76
    clear
    # todo Find number of first joystick device in /dev/input
    numJoypads=$(ls -1 /dev/input/js* | head -n 1)
    $rootdir/emulators/RetroArch/installdir/bin/retroarch-joyconfig --autoconfig "$rootdir/emulators/RetroArch/configs/tempconfig.cfg" --timeout 4 --joypad ${numJoypads:13}
    configfname=`grep "input_device = \"" $rootdir/emulators/RetroArch/configs/tempconfig.cfg`
    configfname=`echo ${configfname:16:-1} | tr -d ' '`
    mv $rootdir/emulators/RetroArch/configs/tempconfig.cfg $rootdir/emulators/RetroArch/configs/$configfname.cfg
    chown $user:$user $rootdir/emulators/RetroArch/configs/
    dialog --backtitle "$__backtitle" --msgbox "The configuration file has been saved as $configfname.cfg and will be used by RetroArch from now on whenever that controller is connected." 22 76
}