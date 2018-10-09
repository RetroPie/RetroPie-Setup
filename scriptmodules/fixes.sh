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
    cp -r /home/pigaming/fan/original/* /sys/devices/odroid_fan.14
    touch /home/pigaming/scripts/update001
fi
