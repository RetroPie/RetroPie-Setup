#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

AUDIO="$1"
ROM="$2"
XRES="$3"
YRES="$4"
rootdir="/opt/retropie"
configdir="$rootdir/configs"
biosdir="$HOME/RetroPie/BIOS/dc"

source "$rootdir/lib/inifuncs.sh"

function mapInput() {
    local js_device
    local js_device_num
    local ev_device
    local ev_devices
    local ev_device_num
    local device_counter
    local conf="$configdir/dreamcast/emu.cfg"
    local params=""

    # get a list of all present js device numbers and device names
    # and device count
    for js_device in /dev/input/js*; do
        js_device_num=${js_device/\/dev\/input\/js/}
        for ev_device in /dev/input/event*; do
            ev_device_num=${ev_device/\/dev\/input\/event/}
            if [[ -d "/sys/class/input/event${ev_device_num}/device/js${js_device_num}" ]]; then
                file[$ev_device_num]=$(grep --exclude=*.bak -rl -m 1 "$configdir/dreamcast/mappings/" -e "= $(</sys/class/input/event${ev_device_num}/device/name)" | tail -n 1)
                if [[ -f "${file[$ev_device_num]}" ]]; then
                    #file[$ev_device_num]="${file[$ev_device_num]##*/}"
                    ev_devices[$ev_device_num]=$(</sys/class/input/event${ev_device_num}/device/name)
                    device_counter=$(($device_counter+1))
                fi
            fi
        done
    done

    # emu.cfg: store up to four event devices and mapping files
    if [[ "$device_counter" -gt "0" ]]; then
        # reicast supports max 4 event devices
        if [[ "$device_counter" -gt "4" ]]; then
            device_counter="4"
        fi
        local counter=0
        for ev_device_num in "${!ev_devices[@]}"; do
            if [[ "$counter" -lt "$device_counter" ]]; then
                counter=$(($counter+1))
                params+="-config input:evdev_device_id_$counter=$ev_device_num "
                params+="-config input:evdev_mapping_$counter=${file[$ev_device_num]} "
            fi
        done
        while [[ "$counter" -lt "4" ]]; do
            counter=$(($counter+1))
            params+="-config input:evdev_device_id_$counter=-1 "
            params+="-config input:evdev_mapping_$counter=-1 "
        done
    else
        # fallback to keyboard setup
        params+="-config input:evdev_device_id_1=0 "
        device_counter=1
    fi
    params+="-config input:joystick_device_id=-1 "
    params+="-config players:nb=$device_counter "
    echo "$params"
}

if [[ ! -f "$biosdir/dc_boot.bin" ]]; then
    dialog --no-cancel --pause "You need to copy the Dreamcast BIOS files (dc_boot.bin and dc_flash.bin) to the folder $biosdir to boot the Dreamcast emulator." 22 76 15
    exit 1
fi

params=(-config config:homedir=$HOME -config x11:fullscreen=1)
[[ -n "$XRES" ]] && params+=(-config x11:width=$XRES -config x11:height=$YRES)
getAutoConf reicast_input && params+=($(mapInput))
[[ -n "$AUDIO" ]] && params+=(-config audio:backend=$AUDIO -config audio:disable=0)
[[ -n "$ROM" ]] && params+=(-config config:image="$ROM")
if [[ "$AUDIO" == "oss" ]]; then
    aoss "$rootdir/emulators/reicast/bin/reicast" "${params[@]}"
else
    "$rootdir/emulators/reicast/bin/reicast" "${params[@]}"
fi
