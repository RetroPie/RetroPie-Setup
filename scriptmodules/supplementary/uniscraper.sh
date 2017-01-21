#!/usr/bin/env bash

# Script made by Riccardo Bux as part of RetroPie project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uniscraper"
rp_module_desc="Configure uniscraper"
rp_module_section="config"

function install_uniscraper() {
cp /etc/samba/smb.conf /etc/samba/smb.conf.unibak
cp /home/pi/RetroPie-Setup/scriptmodules/supplementary/uniscraper/smb.conf /etc/samba/smb.conf 
/etc/init.d/smbd restart
printMsgs "dialog" "Uniscraper config succesfully installed"
}
function manually(){
printMsgs "dialog" "Add in /etc/samba/smb.conf [downloaded_images] path=/home/pi/.emulationstation/downloaded_images writable=yes guest ok=yes create mask = 0644 directory mask = 0755 force user = pi"
}
function remove_uniscraper(){
mv /etc/samba/smb.conf.unibak /etc/samba/smb.conf
printMsgs "dialog" "Uniscraper config removed"
return
}
function gui_uniscraper(){
while true; do
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option. $user" 22 76 16)
local options=(
1 "Install uniscraper"
2 "Manually configure uniscraper"
3 "Remove uniscraper"
)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
		install_uniscraper
                    ;;
		2)
		manually
		   ;;
		3)
		remove_uniscraper
		;;
esac
else
break
fi
done
}
