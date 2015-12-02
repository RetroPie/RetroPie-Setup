#!/usr/bin/env bash
AUDIO="$1"
ROM="$2"
rootdir="/opt/retropie"
configdir="$rootdir/configs"

source "$rootdir/lib/inifuncs.sh"

function mapInput() {
    local js_device
    local js_device_num
    local ev_device
    local ev_devices
    local ev_device_num
    local device_counter
    local conf="/home/pi/.reicast/emu.cfg"
    
    # cleanup "$home/.reicast/emu.cfg"
    sed -i '/input/,/joystick_device_id/d' "$conf"
    echo "[input]" >> "$conf"

    # get a list of all present js device numbers and device names
    # and device count
    for js_device in /dev/input/js*; do
        js_device_num=${js_device/\/dev\/input\/js/}
        for ev_device in /dev/input/event*; do
            ev_device_num=${ev_device/\/dev\/input\/event/}
            if [[ -d "/sys/class/input/event${ev_device_num}/device/js${js_device_num}" ]]; then
                file[$ev_device_num]=$(grep --exclude=*.bak -rl "/home/pi/.reicast/mappings/" -e "= $(</sys/class/input/event${ev_device_num}/device/name)")
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
                echo "evdev_device_id_$counter = $ev_device_num" >> "$conf"
                echo "evdev_mapping_$counter = ${file[$ev_device_num]}" >> "$conf"
            fi
        done
    else
        # fallback to keyboard setup
        echo "evdev_device_id_1 = 0" >> "$conf"
    fi
    echo "joystick_device_id = -1" >> "$conf"
    echo "" >> "$conf"
}

if [[ -f "/home/pi/RetroPie/BIOS/dc_boot.bin" ]]; then
    mapInput
    conf="/home/pi/.reicast/emu.cfg"
    sed -i '/audio/,/disable/d' "$conf"
    echo "[audio]" >> "$conf"
    if [[ "$AUDIO" == "OSS" ]]; then
        echo "backend = oss" >> "$conf"
        echo "disable = 0" >> "$conf"
        echo "" >> "$conf"
        aoss "$rootdir/emulators/reicast/bin/reicast" -config config:homedir=/home/pi/ -config config:image="$ROM" >> /dev/null
    else
        echo "backend = alsa" >> "$conf"
        echo "disable = 0" >> "$conf"
        echo "" >> "$conf"
        "$rootdir/emulators/reicast/bin/reicast" -config config:homedir=/home/pi/ -config config:image="$ROM" >> /dev/null
    fi
else
    __INFMSGS+=("You need to copy the Dreamcast BIOS files (dc_boot.bin and dc_flash.bin) to the folder $biosdir to boot the Dreamcast emulator.")
fi
