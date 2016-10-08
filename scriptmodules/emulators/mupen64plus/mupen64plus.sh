#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

AUDIO_PLUGIN="mupen64plus-audio-sdl"
VIDEO_PLUGIN="$1"
ROM="$2"
RES="$3"
RSP_PLUGIN="$4"
[[ -n "$RES" ]] && RES="--resolution $RES"
[[ -z "$RSP_PLUGIN" ]] && RSP_PLUGIN="mupen64plus-rsp-hle"
rootdir="/opt/retropie"
configdir="$rootdir/configs"
config="$configdir/n64/mupen64plus.cfg"

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)
home="$(eval echo ~$user)"
datadir="$home/RetroPie"
romdir="$datadir/roms"

source "$rootdir/lib/inifuncs.sh"

# arg 1: hotkey name, arg 2: device number, arg 3: retroarch auto config file
function getBind() {
    local key="$1"
    local m64p_hotkey="J$2"
    local file="$3"

    iniConfig " = " "" "$file"

    # search hotkey enable button
    local hotkey
    local input_type
    local i=0
    for hotkey in input_enable_hotkey "$key"; do
        for input_type in "_btn" "_axis"; do
            iniGet "${hotkey}${input_type}"
            ini_value="${ini_value// /}"
            if [[ -n "$ini_value" ]]; then
                ini_value="${ini_value//\"/}"
                case "$input_type" in
                    _axis)
                        m64p_hotkey+="A${ini_value:1}${ini_value:0:1}"
                    ;;
                    _btn)
                        # if ini_value contains "h" it should be a hat device
                        if [[ "$ini_value" == *h* ]]; then
                            local dir="${ini_value:2}"
                            ini_value="${ini_value:1}"
                            case $dir in
                                up)
                                    dir="1"
                                    ;;
                                right)
                                    dir="2"
                                    ;;
                                down)
                                    dir="4"
                                    ;;
                                left)
                                    dir="8"
                                    ;;
                            esac
                            m64p_hotkey+="H${ini_value}V${dir}"
                        else
                            [[ "$atebitdo_hack" -eq 1 && "$ini_value" -ge 11 ]] && ((ini_value-=11))
                            m64p_hotkey+="B${ini_value}"
                        fi
                    ;;
                esac
            fi
        done
        [[ "$i" -eq 0 ]] && m64p_hotkey+="/"
        ((i++))
    done
    echo "$m64p_hotkey"
}

function remap() {
    local device
    local devices
    local device_num

    # get lists of all present js device numbers and device names
    # get device count
    while read -r device; do
        device_num="${device##*/js}"
        devices[$device_num]=$(</sys/class/input/js${device_num}/device/name)
    done < <(find /dev/input -name "js*")

    # read retroarch auto config file and use config
    # for mupen64plus.cfg
    local file
    local bind
    local hotkeys_rp=( "input_exit_emulator" "input_load_state" "input_save_state" )
    local hotkeys_m64p=( "Joy Mapping Stop" "Joy Mapping Load State" "Joy Mapping Save State" )
    local i
    local j

    iniConfig " = " "" "$config"
    if ! grep -q "\[CoreEvents\]" "$config"; then
        echo "[CoreEvents]" >> "$config"
        echo "Version = 1" >> "$config"
    fi

    local atebitdo_hack
    for i in {0..2}; do
        bind=""
        for device_num in "${!devices[@]}"; do
            # get name of retroarch auto config file
            file=$(grep --exclude=*.bak -rl "$configdir/all/retroarch-joypads/" -e "\"${devices[$device_num]}\"")
            atebitdo_hack=0
            [[ "$file" == *8Bitdo* ]] && getAutoConf "8bitdo_hack" && atebitdo_hack=1
            if [[ -f "$file" ]]; then
                if [[ -n "$bind" && "$bind" != *, ]]; then
                    bind+=","
                fi
                bind+=$(getBind "${hotkeys_rp[$i]}" "${device_num}" "$file")
            fi
        done
        # write hotkey to mupen64plus.cfg
        iniConfig " = " "\"" "$config"
        iniSet "${hotkeys_m64p[$i]}" "$bind"
    done
}

function setAudio() {
    if [[ "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" == *BCM27* ]]; then
        # If a raspberry pi is used try to set the right output and use audio omx if possible
        local audio_device=$(amixer)
        if [[ "$audio_device" == *PCM* ]]; then
            # use audio omx if we use rpi internal audio device
            AUDIO_PLUGIN="mupen64plus-audio-omx"
            iniConfig " = " "\"" "$config"
            # create section if necessary
            if ! grep -q "\[Audio-OMX\]" "$config"; then
                echo "[Audio-OMX]" >> "$config"
                echo "Version = 1" >> "$config"
            fi
            # read output configuration
            local audio_port=$(amixer cget numid=3)
            # set output port
            if [[ "$audio_port" == *": values=0"* ]]; then
                # echo "auto configuration"
                # try to find the best solution
                local video_device=$(tvservice -s)
                if [[ "$video_device" == *HDMI* ]]; then
                    iniSet "OUTPUT_PORT" "1"
                else
                    iniSet "OUTPUT_PORT" "0"
                fi
            elif [[ "$audio_port" == *": values=1"* ]]; then
                # echo "audio jack"
                iniSet "OUTPUT_PORT" "0"
            else
                # echo "hdmi"
                iniSet "OUTPUT_PORT" "1"
            fi
        fi
    fi
}

function testCompatibility() {
    # fallback for glesn64 and rice plugin
    # some roms lead to a black screen of death
    local game
    local blacklist=(
        resident
        gauntlet
        rogue
        squadron
    )

    local glesn64_blacklist=(
        zelda
        paper
        kazooie
        tooie
        instinct
        beetle
    )

    local glesn64rice_blacklist=(
        yoshi
    )

    local GLideN64FBEMU_whitelist=(
        ocarina
        empire
        pokemon
        rayman
        donald
        diddy
        beetle
        tennis
        golf
        instinct
        gemini
        majora
        1080
        quake
        ridge
    )

    local GLideN64LegacyBlending_blacklist=(
        empire
        beetle
        donkey
    )

    local GLideN64NativeResolution_blacklist=(
        majora
    )

    for game in "${blacklist[@]}"; do
        if [[ "${ROM,,}" == *"$game"* ]]; then
            exit
        fi
    done

    case "$VIDEO_PLUGIN" in
        "mupen64plus-video-GLideN64")
            if ! grep -q "\[Video-GLideN64\]" "$config"; then
                echo "[Video-GLideN64]" >> "$config"
            fi
            iniConfig " = " "" "$config"
            # Settings version. Don't touch it.
            iniSet "configVersion" "14"
            # Enable FBEmulation if necessary
            iniSet "EnableFBEmulation" "False"
            for game in "${GLideN64FBEMU_whitelist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    iniSet "EnableFBEmulation" "True"
                    break
                fi
            done
            # Set native resolution factor of 1
            iniSet "UseNativeResolutionFactor" "1"
            for game in "${GLideN64NativeResolution_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    iniSet "UseNativeResolutionFactor" "0"
                    break
                fi
            done
            # Disable LegacyBlending if necessary
            iniSet "EnableLegacyBlending" "True"
            for game in "${GLideN64LegacyBlending_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    iniSet "EnableLegacyBlending" "False"
                    break
                fi
            done
            ;;
        "mupen64plus-video-n64"|"mupen64plus-video-rice")
            for game in "${glesn64_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    VIDEO_PLUGIN="mupen64plus-video-rice"
                fi
            done
            for game in "${glesn64rice_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    VIDEO_PLUGIN="mupen64plus-video-GLideN64"
                fi
            done
            ;;
    esac
}

if ! grep -q "\[Core\]" "$config"; then
    echo "[Core]" >> "$config"
    echo "Version = 1.010000" >> "$config"
fi
iniConfig " = " "\"" "$config"
iniSet "ScreenshotPath" "$romdir/n64"
iniSet "SaveStatePath" "$romdir/n64"
iniSet "SaveSRAMPath" "$romdir/n64"

getAutoConf mupen64plus_hotkeys && remap
getAutoConf mupen64plus_compatibility_check && testCompatibility
getAutoConf mupen64plus_audio && setAudio

if [[ "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" == *BCM27* ]]; then
    # If a raspberry pi is used lower resolution to 320x240 and enable SDL dispmanx scaling mode 1
    SDL_VIDEO_RPI_SCALE_MODE=1 "$rootdir/emulators/mupen64plus/bin/mupen64plus" --noosd --windowed $RES --rsp ${RSP_PLUGIN}.so --gfx ${VIDEO_PLUGIN}.so --audio ${AUDIO_PLUGIN}.so --configdir "$configdir/n64" --datadir "$configdir/n64" "$ROM"
else
    "$rootdir/emulators/mupen64plus/bin/mupen64plus" --noosd --fullscreen --rsp ${RSP_PLUGIN}.so --gfx ${VIDEO_PLUGIN}.so --audio mupen64plus-audio-sdl.so --configdir "$configdir/n64" --datadir "$configdir/n64" "$ROM"
fi
