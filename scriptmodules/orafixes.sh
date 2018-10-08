#!/usr/bin/env bash

if ! grep -Fq "modprobe" /home/pigaming/fan/original/rc.local; then
    wget -O /home/pigaming/fan/original/rc.local https://pastebin.com/raw/KVyuq0wd
fi
