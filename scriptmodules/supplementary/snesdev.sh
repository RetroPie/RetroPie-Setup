rp_module_id="snesdev"
rp_module_desc="SNESDev (Driver for the RetroPie GPIO-Adapter)"
rp_module_menus="3+configure"

function sources_snesdev() {
    gitPullOrClone "$md_build" git://github.com/petrockblog/SNESDev-RPi.git
}

function build_snesdev() {
    make clean
    make
    md_ret_require="$md_build/src/SNESDev"
}

function install_snesdev() {
    cd "$md_build"
    make install
    mkdir -p "$md_inst/src"
    mkdir -p "$md_inst/supplementary"
    mkdir -p "$md_inst/scripts"
    cp -Rv 'src/SNESDev' "$md_inst/src/"
    cp -Rv 'src/Makefile' "$md_inst/src/"
    cp -Rv 'Makefile' "$md_inst"
    cp -Rv 'scripts/Makefile' "$md_inst/scripts/"
    cp -Rv 'scripts/SNESDev' "$md_inst/scripts/"
    cp -Rv 'supplementary/snesdev.cfg' "$md_inst/supplementary/"
}

function sup_checkInstallSNESDev() {
    if [[ ! -d "$md_inst" ]]; then
        sources_snesdev
        build_snesdev
        install_snesdev
    fi
}

# start SNESDev on boot and configure RetroArch input settings
function sup_enableSNESDevAtStart() {
    clear
    printMsg "Enabling SNESDev on boot."

    case $1 in
      1)
        ensureKeyValueBootconfig "button_enabled" "0" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad1_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad2_enabled" "1" "/etc/snesdev.cfg"
        ;;
      2)
        ensureKeyValueBootconfig "button_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad1_enabled" "0" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad2_enabled" "0" "/etc/snesdev.cfg"
        ;;
      3)
        ensureKeyValueBootconfig "button_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad1_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad2_enabled" "1" "/etc/snesdev.cfg"
        ;;
      *)
        echo "[sup_enableSNESDevAtStart] I do not understand what is going on here."
        ;;
    esac

}

function sup_snesdevAdapterversion() {
  if [[ $1 -eq 1 ]]; then
    ensureKeyValueBootconfig "adapter_version" "1x" "/etc/snesdev.cfg"
  elif [[ $1 -eq 2 ]]; then
    ensureKeyValueBootconfig "adapter_version" "2x" "/etc/snesdev.cfg"
  else
    ensureKeyValueBootconfig "adapter_version" "2x" "/etc/snesdev.cfg"
  fi
}

function configure_snesdev() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable SNESDev on boot and SNESDev keyboard mapping."
             2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)."
             3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)."
             4 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button)."
             5 "Switch to adapter version 1.X."
             6 "Switch to adapter version 2.X.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) sup_checkInstallSNESDev
               make uninstallservice
               dialog --backtitle "$__backtitle" --msgbox "Disabled SNESDev on boot." 22 76
                            ;;
            2) sup_checkInstallSNESDev
               sup_enableSNESDevAtStart 3
               make installservice
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling pads and button)." 22 76
                            ;;
            3) sup_checkInstallSNESDev
               sup_enableSNESDevAtStart 1
               make installservice
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling only pads)." 22 76
                            ;;
            4) sup_checkInstallSNESDev
               sup_enableSNESDevAtStart 2
               make installservice
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling only button)." 22 76
                            ;;
            5) sup_snesdevAdapterversion 1
               dialog --backtitle "$__backtitle" --msgbox "Switched to adapter version 1.X." 22 76
                            ;;
            6) sup_snesdevAdapterversion 2
               dialog --backtitle "$__backtitle" --msgbox "Switched to adapter version 2.X." 22 76
                            ;;
        esac
    else
        break
    fi
}