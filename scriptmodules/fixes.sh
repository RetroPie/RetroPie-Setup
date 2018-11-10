#!/bin/bash

if [[ ! -f /home/pigaming/scripts/update001 ]]; then
    wget -O /home/pigaming/fan/original/rc.local https://pastebin.com/raw/KVyuq0wd
    wget -O /home/pigaming/fan/cool-mode/rc.local https://pastebin.com/raw/4Vjs9nWL
    wget -O /home/pigaming/fan/aggressive/rc.local https://pastebin.com/raw/cgA7KeeY
    dos2unix /home/pigaming/fan/original/rc.local
    dos2unix /home/pigaming/fan/cool-mode/rc.local
    dos2unix /home/pigaming/fan/aggressive/rc.local
    wget -O /home/pigaming/ogst/system-pcfx.png https://raw.githubusercontent.com/Retro-Arena/xu4-bins/master/ogst/system-pcfx.png
    chmod a+x /home/pigaming/ogst/system-pcfx.png
    sudo cp -p /etc/rc.local.bak /etc/rc.local
    touch /home/pigaming/scripts/update001
fi

if [[ ! -f /home/pigaming/scripts/update002 ]]; then
   wget -O /opt/retropie/configs/all/retroarch-core-options.cfg https://pastebin.com/raw/ATeS35pE
   touch /home/pigaming/scripts/update002
fi

if [[ ! -f /home/pigaming/scripts/update003 ]]; then
   wget -O /opt/retropie/configs/saturn/emulators.cfg https://pastebin.com/raw/1s960yPS
   touch /home/pigaming/scripts/update003
fi

if [[ ! -f /home/pigaming/scripts/update004 ]]; then
   wget -O /etc/usbmount/usbmount.conf https://pastebin.com/raw/dNn591bL
   dos2unix /etc/usbmount/usbmount.conf
   wget -O /etc/usbmount/mount.d/10_retropie_mount https://pastebin.com/raw/M6ZG9iu8
   dos2unix /etc/usbmount/mount.d/10_retropie_mount
   rm /etc/usbmount/mount.d/01_retropie_copyroms
   touch /home/pigaming/scripts/update004
fi

if [[ ! -f /home/pigaming/scripts/update005 ]]; then
    # add naomi to showcase theme
    if [[ ! -f /etc/emulationstation/themes/showcase/naomi/theme.xml ]]; then
        cp -R /etc/emulationstation/themes/showcase/arcade/. /etc/emulationstation/themes/showcase/naomi/
        wget -O /etc/emulationstation/themes/showcase/naomi/_inc/system.png https://image.ibb.co/kDMSAK/showcase_naomi_system.png
        wget -O /etc/emulationstation/themes/showcase/naomi/_inc/background.png https://image.ibb.co/gLBije/showcase_naomi_background.png
    fi
    # add atomiswave to showcase theme
    if [[ ! -f /etc/emulationstation/themes/showcase/atomiswave/theme.xml ]]; then
        cp -R /etc/emulationstation/themes/showcase/arcade/. /etc/emulationstation/themes/showcase/atomiswave/
        wget -O /etc/emulationstation/themes/showcase/atomiswave/_inc/system.png https://image.ibb.co/f5fCKe/system.png
        wget -O /etc/emulationstation/themes/showcase/atomiswave/_inc/background.png https://image.ibb.co/kgftsz/background.png
    fi
    touch /home/pigaming/scripts/update005
fi
