rp_module_id="retronetplay"
rp_module_desc="RetroNetplay"
rp_module_menus="4+"

function configure_retronetplay() {
    ipaddress_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    ipaddress_ext=$(curl http://ipecho.net/plain; echo)
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure RetroArch Netplay.\nInternal IP: $ipaddress_int\nExternal IP: $ipaddress_ext" 22 76 16)
        options=(1 "(E)nable/(D)isable RetroArch Netplay. Currently: $__netplayenable"
                 2 "Set mode, (H)ost or (C)lient. Currently: $__netplaymode"
                 3 "Set port. Currently: $__netplayport"
                 4 "Set host IP address (for client mode). Currently: $__netplayhostip"
                 5 "Set delay frames. Currently: $__netplayframes" )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [ "$choices" != "" ]; then
            case $choices in
                 1) rps_retronet_enable ;;
                 2) rps_retronet_mode ;;
                 3) rps_retronet_port ;;
                 4) rps_retronet_hostip ;;
                 5) rps_retronet_frames ;;
            esac
        else
            break
        fi
    done
}

function rps_retronet_enable() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Enable or disable RetroArch's Netplay mode." 22 76 16)
    options=(1 "ENABLE netplay"
             2 "DISABLE netplay" )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
             1) __netplayenable="E"
                ;;
             2) __netplayenable="D"
                ;;
        esac
        rps_retronet_saveconfig
        sup_generate_esconfig
    fi
}

function rps_retronet_mode() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Please set the netplay mode." 22 76 16)
    options=(1 "Set as HOST"
             2 "Set as CLIENT" )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
             1) __netplaymode="H"
                __netplayhostip_cfile=""
                ;;
             2) __netplaymode="C"
                __netplayhostip_cfile="$__netplayhostip"
                ;;
        esac
        rps_retronet_saveconfig
        sup_generate_esconfig
    fi
}

function rps_retronet_port() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the port to be used for netplay (default: 55435)." 22 76 $__netplayport)
    choices=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        __netplayport=$choices
        rps_retronet_saveconfig
        sup_generate_esconfig
    fi
}

function rps_retronet_hostip() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the IP address of the host." 22 76 $__netplayhostip)
    choices=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        __netplayhostip=$choices
        if [[ $__netplaymode == "H" ]]; then
            __netplayhostip_cfile=""
        else
            __netplayhostip_cfile="$__netplayhostip"
        fi
        rps_retronet_saveconfig
        sup_generate_esconfig
    fi
}

function rps_retronet_frames() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the number of delay frames for netplay (default: 15)." 22 76 $__netplayframes)
    choices=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        __netplayframes=$choices
        rps_retronet_saveconfig
        sup_generate_esconfig
    fi
}

function rps_retronet_saveconfig() {
    echo -e "__netplayenable=\"$__netplayenable\"\n__netplaymode=\"$__netplaymode\"\n__netplayport=\"$__netplayport\"\n__netplayhostip=\"$__netplayhostip\"\n__netplayhostip_cfile=\"$__netplayhostip_cfile\"\n__netplayframes=\"$__netplayframes\"" > $scriptdir/configs/retronetplay.cfg
}