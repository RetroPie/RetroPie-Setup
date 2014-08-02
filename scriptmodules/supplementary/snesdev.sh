rp_module_id="snesdev"
rp_module_desc="SNESDev"
rp_module_menus="3+configure"

function sources_snesdev() {
    gitPullOrClone "$rootdir/supplementary/SNESDev-Rpi" git://github.com/petrockblog/SNESDev-RPi.git
}

function build_snesdev() {
    pushd "$rootdir/supplementary/SNESDev-Rpi"
    ./build.sh
    popd
}

function install_snesdev() {
    if [[ ! -f "$rootdir/supplementary/SNESDev-Rpi/SNESDev" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNESDev."
    else
        service SNESDev stop
        cp "$rootdir/supplementary/SNESDev-Rpi/SNESDev" /usr/local/bin/
    fi
    cp "$rootdir/supplementary/SNESDev-Rpi/supplementary/snesdev.cfg" /etc/
}

# start SNESDev on boot and configure RetroArch input settings
function sup_enableSNESDevAtStart()
{
    clear
    printMsg "Enabling SNESDev on boot."

    if [[ ! -f "/etc/init.d/SNESDev" ]]; then
        if [[ ! -f "$rootdir/supplementary/SNESDev-Rpi/SNESDev" ]]; then
            dialog --backtitle "$__backtitle" --msgbox "Cannot find SNESDev binary. Please install SNESDev." 22 76
            return
        else
            echo "Copying service script for SNESDev to /etc/init.d/ ..."
            chmod +x "$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev"
            cp "$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev" /etc/init.d/
        fi
    fi

    echo "Copying SNESDev to /usr/local/bin/ ..."
    cp "$rootdir/supplementary/SNESDev-Rpi/SNESDev" /usr/local/bin/

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

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d SNESDev defaults
    # This command starts the daemon now so no need for a reboot
    service SNESDev start
}

# disable start SNESDev on boot and remove RetroArch input settings
function sup_disableSNESDevAtStart()
{
    clear
    printMsg "Disabling SNESDev on boot."

    # This command stops the daemon now so no need for a reboot
    service SNESDev stop

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d SNESDev remove
}

function configure_snesdev() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable SNESDev on boot and SNESDev keyboard mapping."
             2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)."
             3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)."
             4 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button).")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) sup_disableSNESDevAtStart
               dialog --backtitle "$__backtitle" --msgbox "Disabled SNESDev on boot." 22 76
                            ;;
            2) sup_enableSNESDevAtStart 3
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling pads and button)." 22 76
                            ;;
            3) sup_enableSNESDevAtStart 1
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling only pads)." 22 76
                            ;;
            4) sup_enableSNESDevAtStart 2
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling only button)." 22 76
                            ;;
        esac
    else
        break
    fi
}