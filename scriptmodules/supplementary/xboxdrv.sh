rp_module_id="xboxdrv"
rp_module_desc="Install XBox contr. 360 driver"
rp_module_menus="3+"
rp_module_flags="nobin"

function install_xboxdrv() {
    getDepends xboxdrv
    if grep -q "xboxdrv" /etc/rc.local; then
        sed -i -e '13,$ s|exit 0|xboxdrv --daemon --id 0 --led 2 --deadzone 4000 --silent --trigger-as-button --next-controller --id 1 --led 3 --deadzone 4000 --silent --trigger-as-button --dbus disabled --detach-kernel-driver \&\nexit 0|g' /etc/rc.local
    fi
    iniConfig "=" "" "/boot/config.txt"
    iniSet "dwc_otg.speed" "1"
    dialog --backtitle "$__backtitle" --msgbox "Installed xboxdrv and adapted /etc/rc.local. It will be started on boot." 22 76
}
