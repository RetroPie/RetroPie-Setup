#!/usr/bin/env bash

# Script made by Riccardo Bux as part of RetroPie project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="usbstorage"
rp_module_desc="Configure usb"
rp_module_section="config"

function remove_fstab(){
if grep -q "/mnt/usb" "/etc/fstab"; then
sed -i "s/UUID=.*/ /g" /etc/fstab
systemctl disable bind.service
printMsgs "dialog" "Usb removed"
else
printMsgs "dialog" "Nothing to remove"
fi
}

function usb_share(){
local options=(
1 "Set usb for samba shares"
2 "No thanks, I will use it without network sharing"
)
local cmd=(dialog --backtitle "$__backtitle" --menu "Do you want to share usb in your local network? (Need Samba installed)" 22 86 16)
local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
[[ "$choice" -eq 1 ]] && cp /etc/samba/smb.conf /etc/samba/smb.conf.usbbak && write_shares 
[[ "$choice" -eq 2 ]] && return
}
function write_shares(){
if grep -q "/mnt/usb" "/etc/samba/smb.conf"; then
printMsgs "dialog" "Usb already setted in /etc/samba/smb.conf, if doesn't work as you expect: restore backup from previous menu, or remove manually part from [usb] to force user=pi in your /etc/smb/smb.conf file and try again"
else
cat >>/etc/samba/smb.conf <<_EOF_
[usb]
comment = usb share
path = /mnt/usb/retropie
writable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = pi
_EOF_
fi
/etc/init.d/smbd restart
}

function remove_shares(){
mv /etc/samba/smb.conf.usbbak /etc/samba/smb.conf
printMsgs "dialog" "Samba shares restored"
}
 
function write_fstab(){
cp /home/pi/RetroPie-Setup/scriptmodules/supplementary/usbstorage/bind.sh /etc/init.d/bind.sh
chmod +x /etc/init.d/bind.sh
cp /home/pi/RetroPie-Setup/scriptmodules/supplementary/usbstorage/bind.service /etc/systemd/system/bind.service
if grep -q "/mnt/usb" "/etc/fstab"; then
sed -i "s/UUID=.*/UUID=$uuid \/mnt\/usb $fs nofail,nobootwait/g" /etc/fstab
else
echo "UUID=$uuid /mnt/usb $fs noauto" >> /etc/fstab
fi
systemctl enable bind.service
systemctl start bind.service
}
function set_usb(){
mkdir /mnt/usb
usb_path_from_rp="$usb_path/configs/from_retropie"
usb_path_to_rp="$usb_path/configs/to_retropie"
local usb_path
    usb_path1="$(choose_usb)"
if [[ "$usb_path1" == "" ]]; then
printMsgs "dialog" "No usb drive detected"
return
fi
	umount /mnt/usb > /dev/null 2>&1 
	mount /dev/$usb_path1 /mnt/usb
	fs=$(eval $(blkid /dev/$usb_path1 | awk '{print $3}'); echo $TYPE)
	if [[ "$fs" == "" ]];then
	fs=$(eval $(blkid /dev/$usb_path1 | awk '{print $4}'); echo $TYPE) #exfat fs
	mount -o nonempty /dev/$usb_path1 /mnt/usb
	fi
	uuid=$(blkid /dev/$usb_path1 -sUUID | cut -d'"' -f2)
    	usb_path=/mnt/usb
	chmod +x /home/pi/RetroPie-Setup/scriptmodules/supplementary/usbstorage/unbind.sh
	/home/pi/RetroPie-Setup/scriptmodules/supplementary/usbstorage/unbind.sh > /dev/null 2>&1
if [[ -d $usb_path/retropie ]]; then
local options=(
1 "Continue and use this usb anyway"
2 "Exit"
)

local cmd=(dialog --backtitle "$__backtitle" --menu "It seems that this usb was already used with retrorangepi" 22 86 16)
local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
[[ "$choice" -eq 1 ]] && write_fstab && usb_share

[[ "$choice" -eq 2 ]] && return
else
usb_path=/mnt/usb
mkdir -p "$usb_path/retropie/"{roms,BIOS} "$usb_path_from_rp" "$usb_path_to_rp"
mkdir -p "$usb_path/retropie/roms/"{amiga,amstradcpc,apple2,arcade,atari2600,atari5200,atari7800,atari800,atarilynx,atarist,c64,coco,coleco,crvision,daphne,dragon32,dreamcast,fba,fds,gameandwatch,gamegear,gb,gba,gbc,genesis,intellivision,kodi,love,macintosh,mame-advmame,mame-libretro,mame-mame4all,mastersystem,megadrive,msx,n64,neogeo,nes,ngp,ngpc,pc,pcengine,ports,psp,psx,scummvm,sega32x,segacd,sg-1000,snes,vectrex,videopac,virtualboy,wonderswan,wonderswancolor,zmachine,zxspectrum} && rm -rf /home/$user/RetroPie/roms/amiga/usb && rm -rf /home/$user/RetroPie/roms/nes/usb && rm -rf /home/$user/RetroPie/roms/amstradcpc/usb && rm -rf /home/$user/RetroPie/roms/apple2/usb && rm -rf /home/$user/RetroPie/roms/arcade/usb && rm -rf /home/$user/RetroPie/roms/atari2600/usb && rm -rf /home/$user/RetroPie/roms/atari5200/usb && rm -rf /home/$user/RetroPie/roms/atari7800/usb && rm -rf /home/$user/RetroPie/roms/atari800/usb && rm -rf /home/$user/RetroPie/roms/atarilynx/usb && rm -rf /home/$user/RetroPie/roms/atarist/usb && rm -rf /home/$user/RetroPie/roms/c64/usb && rm -rf /home/$user/RetroPie/roms/coco/usb && rm -rf /home/$user/RetroPie/roms/coleco/usb && rm -rf /home/$user/RetroPie/roms/crvision/usb && rm -rf /home/$user/RetroPie/roms/daphne/usb && rm -rf /home/$user/RetroPie/roms/dragon32/usb && rm -rf /home/$user/RetroPie/roms/dreamcast/usb && rm -rf /home/$user/RetroPie/roms/fba/usb && rm -rf /home/$user/RetroPie/roms/fds/usb && rm -rf /home/$user/RetroPie/roms/gameandwatch/usb && rm -rf /home/$user/RetroPie/roms/gamegear/usb && rm -rf /home/$user/RetroPie/roms/gb/usb && rm -rf /home/$user/RetroPie/roms/gba/usb && rm -rf /home/$user/RetroPie/roms/gbc/usb && rm -rf /home/$user/RetroPie/roms/genesis/usb && rm -rf /home/$user/RetroPie/roms/intellivision/usb && rm -rf /home/$user/RetroPie/roms/kodi/usb && rm -rf /home/$user/RetroPie/roms/love/usb && rm -rf /home/$user/RetroPie/roms/macintosh/usb && rm -rf /home/$user/RetroPie/roms/mame-advmame/usb && rm -rf /home/$user/RetroPie/roms/mame-libretro/usb && rm -rf /home/$user/RetroPie/roms/mame-mame4all/usb && rm -rf /home/$user/RetroPie/roms/mastersystem/usb && rm -rf /home/$user/RetroPie/roms/megadrive/usb && rm -rf /home/$user/RetroPie/roms/msx/usb && rm -rf /home/$user/RetroPie/roms/n64/usb && rm -rf /home/$user/RetroPie/roms/neogeo/usb && rm -rf /home/$user/RetroPie/roms/ngp/usb && rm -rf /home/$user/RetroPie/roms/ngpc/usb && rm -rf /home/$user/RetroPie/roms/pc/usb && rm -rf /home/$user/RetroPie/roms/pcengine/usb && rm -rf /home/$user/RetroPie/roms/ports/usb && rm -rf /home/$user/RetroPie/roms/psp/usb && rm -rf /home/$user/RetroPie/roms/psx/usb && rm -rf /home/$user/RetroPie/roms/scummvm/usb && rm -rf /home/$user/RetroPie/roms/sega32x/usb && rm -rf /home/$user/RetroPie/roms/segacd/usb && rm -rf /home/$user/RetroPie/roms/sg-1000/usb && rm -rf /home/$user/RetroPie/roms/snes/usb && rm -rf /home/$user/RetroPie/roms/vectrex/usb && rm -rf /home/$user/RetroPie/roms/videopac/usb && rm -rf /home/$user/RetroPie/roms/virtualboy/usb && rm -rf /home/$user/RetroPie/roms/wonderswan/usb && rm -rf /home/$user/RetroPie/roms/wonderswancolor/usb && rm -rf /home/$user/RetroPie/roms/zmachine/usb && rm -rf /home/$user/RetroPie/roms/zxspectrum/usb && mkdir -p /home/$user/RetroPie/roms/amiga/usb && mkdir -p /home/$user/RetroPie/roms/nes/usb && mkdir -p /home/$user/RetroPie/roms/amstradcpc/usb && mkdir -p /home/$user/RetroPie/roms/apple2/usb && mkdir -p /home/$user/RetroPie/roms/arcade/usb && mkdir -p /home/$user/RetroPie/roms/atari2600/usb && mkdir -p /home/$user/RetroPie/roms/atari5200/usb && mkdir -p /home/$user/RetroPie/roms/atari7800/usb && mkdir -p /home/$user/RetroPie/roms/atari800/usb && mkdir -p /home/$user/RetroPie/roms/atarilynx/usb && mkdir -p /home/$user/RetroPie/roms/atarist/usb && mkdir -p /home/$user/RetroPie/roms/c64/usb && mkdir -p /home/$user/RetroPie/roms/coco/usb && mkdir -p /home/$user/RetroPie/roms/coleco/usb && mkdir -p /home/$user/RetroPie/roms/crvision/usb && mkdir -p /home/$user/RetroPie/roms/daphne/usb && mkdir -p /home/$user/RetroPie/roms/dragon32/usb && mkdir -p /home/$user/RetroPie/roms/dreamcast/usb && mkdir -p /home/$user/RetroPie/roms/fba/usb && mkdir -p /home/$user/RetroPie/roms/fds/usb && mkdir -p /home/$user/RetroPie/roms/gameandwatch/usb && mkdir -p /home/$user/RetroPie/roms/gamegear/usb && mkdir -p /home/$user/RetroPie/roms/gb/usb && mkdir -p /home/$user/RetroPie/roms/gba/usb && mkdir -p /home/$user/RetroPie/roms/gbc/usb && mkdir -p /home/$user/RetroPie/roms/genesis/usb && mkdir -p /home/$user/RetroPie/roms/intellivision/usb && mkdir -p /home/$user/RetroPie/roms/kodi/usb && mkdir -p /home/$user/RetroPie/roms/love/usb && mkdir -p /home/$user/RetroPie/roms/macintosh/usb && mkdir -p /home/$user/RetroPie/roms/mame-advmame/usb && mkdir -p /home/$user/RetroPie/roms/mame-libretro/usb && mkdir -p /home/$user/RetroPie/roms/mame-mame4all/usb && mkdir -p /home/$user/RetroPie/roms/mastersystem/usb && mkdir -p /home/$user/RetroPie/roms/megadrive/usb && mkdir -p /home/$user/RetroPie/roms/msx/usb && mkdir -p /home/$user/RetroPie/roms/n64/usb && mkdir -p /home/$user/RetroPie/roms/neogeo/usb && mkdir -p /home/$user/RetroPie/roms/ngp/usb && mkdir -p /home/$user/RetroPie/roms/ngpc/usb && mkdir -p /home/$user/RetroPie/roms/pc/usb && mkdir -p /home/$user/RetroPie/roms/pcengine/usb && mkdir -p /home/$user/RetroPie/roms/ports/usb && mkdir -p /home/$user/RetroPie/roms/psp/usb && mkdir -p /home/$user/RetroPie/roms/psx/usb && mkdir -p /home/$user/RetroPie/roms/scummvm/usb && mkdir -p /home/$user/RetroPie/roms/sega32x/usb && mkdir -p /home/$user/RetroPie/roms/segacd/usb && mkdir -p /home/$user/RetroPie/roms/sg-1000/usb && mkdir -p /home/$user/RetroPie/roms/snes/usb && mkdir -p /home/$user/RetroPie/roms/vectrex/usb && mkdir -p /home/$user/RetroPie/roms/videopac/usb && mkdir -p /home/$user/RetroPie/roms/virtualboy/usb && mkdir -p /home/$user/RetroPie/roms/wonderswan/usb && mkdir -p /home/$user/RetroPie/roms/wonderswancolor/usb && mkdir -p /home/$user/RetroPie/roms/zmachine/usb && mkdir -p /home/$user/RetroPie/roms/zxspectrum/usb  
chown -R -h pi:pi /mnt/usb/retropie
write_fstab
usb_share
fi

}

function choose_usb(){

local options=()
    local i=0

devs=`ls -al /dev/disk/by-path/*usb*part* 2>/dev/null | awk '{print($11)}'`; 
for dev in $devs; 
do dev=${dev##*\/};
dim=$(df -Ph /dev/$dev | tail -1 | awk '{print $4}')
options+=("$dev" "Usb$l Size $dim")
((i++)) 
done



#if [[ $i != 0 ]]; then
local cmd1=(dialog --menu "Choose Usb." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
     	[[ -n "$choice" ]] && echo "${choice[0]}"
 

}

function gui_usbstorage(){
while true; do
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option. $user" 22 76 16)
local options=(
1 "Choose your usb drive"
2 "Remove setted usb"
3 "Remove shares by restore samba backup"
)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
		1)
		set_usb
		   ;;
		2)
		remove_fstab
		;;
		3)
		remove_shares
		;;
esac
else
break
fi
done
}
