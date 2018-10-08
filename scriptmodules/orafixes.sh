#!/usr/bin/env bash

if sudo grep -Fxq "modprobe" /home/pigaming/fan/rc.local; then
    wget -O /home/pigaming/fan/original/rc.local https://pastebin.com/raw/KVyuq0wd
fi
