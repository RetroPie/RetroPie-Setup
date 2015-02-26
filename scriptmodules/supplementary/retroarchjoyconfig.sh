rp_module_id="retroarchjoyconfig"
rp_module_desc="Register RetroArch controller"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_retroarchjoyconfig() {
    local configfname
    local numJoypads

    printMsgs "dialog" "Connect ONLY the controller to be registered for RetroArch to the Raspberry Pi."
    clear
    # todo Find number of first joystick device in /dev/input
    numJoypads=$(ls -1 /dev/input/js* | head -n 1)
    $emudir/retroarch/retroarch-joyconfig --autoconfig "$emudir/retroarch/configs/tempconfig.cfg" --timeout 4 --joypad ${numJoypads:13}
    configfname=$(grep "input_device = \"" "$emudir/retroarch/configs/tempconfig.cfg")
    configfname=$(echo ${configfname:16:-1} | tr -d ' ')
    mv "$emudir/retroarch/configs/tempconfig.cfg" "$emudir/retroarch/configs/$configfname.cfg"
    # Add hotkeys
    rp_callModule retroarchautoconf configure
    chown -R $user:$user "$emudir/retroarch/configs"
    printMsgs "dialog" "The configuration file has been saved as $configfname.cfg and will be used by RetroArch from now on whenever that controller is connected."
}
