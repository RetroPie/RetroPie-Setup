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
   wget -O /opt/retropie/configs/all/retroarch-core-options https://pastebin.com/raw/ATeS35pE
   touch /home/pigaming/scripts/update002
fi
