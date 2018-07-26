#!/usr/bin/env bash
stop_bgm(){
        pkill -STOP mpg123
        sudo rm /home/pigaming/scripts/bgm/start.sc
    clear
        echo -e "\n\n\n                               Background Music Halted\n\n\n"
        sleep 3
}

start_bgm(){
        pkill -CONT mpg123
        touch /home/pigaming/scripts/bgm/start.sc
        echo -e "\n\n\n                               Background Music Enabled\n\n\n"
        sleep 3
}

if [ -a /home/pigaming/scripts/bgm/start.sc ]; then
        stop_bgm
else
        start_bgm
fi
exit

