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
[[ "$3" != 0 ]] && RES="$3"
[[ "$4" -ne 0 ]] && RSP_PLUGIN="$4"
PARAMS="${@:5}"
[[ -n "$RES" ]] && RES="--resolution $RES"
[[ -z "$RSP_PLUGIN" ]] && RSP_PLUGIN="mupen64plus-rsp-hle"
WINDOW_MODE="--fullscreen $RES"

rootdir="/opt/retropie"
configdir="$rootdir/configs"
config="$configdir/n64/mupen64plus.cfg"
inputconfig="$configdir/n64/InputAutoCfg.ini"
datadir="$HOME/RetroPie"
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
    iniSet "Version" "1" "" "[CoreEvents]"

    local atebitdo_hack
    for i in {0..2}; do
        bind=""
        for device_num in "${!devices[@]}"; do
            # get name of retroarch auto config file
            file=$(grep -lF "\"${devices[$device_num]}\"" "$configdir/all/retroarch-joypads/"*.cfg)
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
        iniSet "${hotkeys_m64p[$i]}" "$bind" "" "[CoreEvents]"
    done
}

function setAudio() {
    if [[ "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" == *BCM* ]]; then
        # If a raspberry pi is used try to set the right output and use audio omx if possible
        local audio_device=$(amixer)
        if [[ "$audio_device" == *PCM* ]]; then
            # use audio omx if we use rpi internal audio device
            AUDIO_PLUGIN="mupen64plus-audio-omx"
            iniConfig " = " "\"" "$config"
            iniSet "Version" "1" "" "[Audio-OMX]"
            # read output configuration
            local audio_port=$(amixer cget numid=3)
            # set output port
            if [[ "$audio_port" == *": values=0"* ]]; then
                # echo "auto configuration"
                # try to find the best solution
                local video_device=$(tvservice -s)
                if [[ "$video_device" == *HDMI* ]]; then
                    iniSet "OUTPUT_PORT" "1" "" "[Audio-OMX]"
                else
                    iniSet "OUTPUT_PORT" "0" "" "[Audio-OMX]"
                fi
            elif [[ "$audio_port" == *": values=1"* ]]; then
                # echo "audio jack"
                iniSet "OUTPUT_PORT" "0" "" "[Audio-OMX]"
            else
                # echo "hdmi"
                iniSet "OUTPUT_PORT" "1" "" "[Audio-OMX]"
            fi
        fi
    fi
}

function testCompatibility() {
    # fallback for glesn64 and rice plugin
    # some roms lead to a black screen of death
    local game

    # these games need RSP-LLE
    local blacklist=(
        naboo
        body
    )

    # these games do not run with gles2n64
    local glesn64_blacklist=(
        zelda
        paper
        kazooie
        tooie
        instinct
        beetle
        rogue
        squadron
        gauntlet
    )

    # these games do not run with rice
    local glesn64rice_blacklist=(
        yoshi
        rogue
        squadron
        gauntlet
        infernal
    )

    # these games have massive glitches if legacy blending is enabled
    local GLideN64LegacyBlending_blacklist=(
        empire
        beetle
        donkey
        zelda
        bomberman
        infernal
    )

    local GLideN64NativeResolution_blacklist=(
        majora
    )

    # these games have major problems with GLideN64
    local gliden64_blacklist=(
        zelda
        conker
    )

    # these games crash if audio-omx is selected
    local AudioOMX_blacklist=(
        pokemon
        resident
        starcraft
        rogue
        squadron
        infernal
    )

    for game in "${blacklist[@]}"; do
        if [[ "${ROM,,}" == *"$game"* ]]; then
            exit
        fi
    done

    for game in "${AudioOMX_blacklist[@]}"; do
        if [[ "${ROM,,}" == *"$game"* ]]; then
            AUDIO_PLUGIN="mupen64plus-audio-sdl"
        fi
    done

    case "$VIDEO_PLUGIN" in
        "mupen64plus-video-GLideN64")
            iniConfig " = " "" "$config"
            # Settings version. Don't touch it.
            local config_version="20"
            if [[ -f "$configdir/n64/GLideN64_config_version.ini" ]]; then
                config_version=$(<"$configdir/n64/GLideN64_config_version.ini")
            fi
            iniSet "configVersion" "$config_version" "" "[Video-GLideN64]"
            # Set native resolution factor of 1
            iniSet "UseNativeResolutionFactor" "1" "" "[Video-GLideN64]"
            for game in "${GLideN64NativeResolution_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    iniSet "UseNativeResolutionFactor" "0" "" "[Video-GLideN64]"
                    break
                fi
            done
            # Disable LegacyBlending if necessary
            iniSet "EnableLegacyBlending" "True" "" "[Video-GLideN64]"
            for game in "${GLideN64LegacyBlending_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    iniSet "EnableLegacyBlending" "False" "" "[Video-GLideN64]"
                    break
                fi
            done
            for game in "${gliden64_blacklist[@]}"; do
                if [[ "${ROM,,}" == *"$game"* ]]; then
                    VIDEO_PLUGIN="mupen64plus-video-rice"
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

    # fix Audio-SDL crackle
    iniConfig " = " "\"" "$config"
    iniSet "Version" "1" "" "[Audio-SDL]"
    iniSet "RESAMPLE" "src-sinc-fastest" "" "[Audio-SDL]"
}

function useTexturePacks() {
    # video-GLideN64
    iniConfig " = " "" "$config"
    # Settings version. Don't touch it.
    local config_version="17"
    if [[ -f "$configdir/n64/GLideN64_config_version.ini" ]]; then
        config_version=$(<"$configdir/n64/GLideN64_config_version.ini")
    fi
    iniSet "configVersion" "$config_version" "" "[Video-GLideN64]"
    iniSet "txHiresEnable" "True" "" "[Video-GLideN64]"

    # video-rice
    iniSet "LoadHiResTextures" "True" "" "[Video-Rice]"
}

function autoset() {
    VIDEO_PLUGIN="mupen64plus-video-GLideN64"
    RES="--resolution 320x240"
    PARAMS="--set Video-GLideN64[UseNativeResolutionFactor]=1"

    local game
    # these games run fine and look better with 640x480
    local highres=(
        yoshi
        worms
        party
        pokemon
        bomberman
        harvest
        diddy
        1080
        starcraft
        wipeout
        dark
    )

    for game in "${highres[@]}"; do
        if [[ "${ROM,,}" == *"$game"* ]]; then
            RES="--resolution 640x480"
            PARAMS="--set Video-GLideN64[UseNativeResolutionFactor]=2"
            break
        fi
    done

    # these games have no glitches and run faster with gles2n64
    local gles2n64=(
        wave
        kart
    )

    for game in "${gles2n64[@]}"; do
        if [[ "${ROM,,}" == *"$game"* ]]; then
            VIDEO_PLUGIN="mupen64plus-video-n64"
            break
        fi
    done

    # these games have no glitches or run faster with rice
    local gles2rice=(
        diddy
        1080
        conker
        tooie
        darkness
    )

    for game in "${gles2rice[@]}"; do
        if [[ "${ROM,,}" == *"$game"* ]]; then
            VIDEO_PLUGIN="mupen64plus-video-rice"
            break
        fi
    done
}

iniConfig " = " "\"" "$config"
iniSet "Version" "1.010000" "" "[Core]"

function setPath() {
    iniSet "ScreenshotPath" "$romdir/n64" "" "[Core]"
    iniSet "SaveStatePath" "$romdir/n64" "" "[Core]"
    iniSet "SaveSRAMPath" "$romdir/n64" "" "[Core]"
}


# add default keyboard configuration if InputAutoCFG.ini is missing
if [[ ! -f "$inputconfig" ]]; then
    cat > "$inputconfig" << _EOF_
; InputAutoCfg.ini for Mupen64Plus SDL Input plugin

; Keyboard_START
[Keyboard]
plugged = True
plugin = 2
mouse = False
DPad R = key(100)
DPad L = key(97)
DPad D = key(115)
DPad U = key(119)
Start = key(13)
Z Trig = key(122)
B Button = key(306)
A Button = key(304)
C Button R = key(108)
C Button L = key(106)
C Button D = key(107)
C Button U = key(105)
R Trig = key(99)
L Trig = key(120)
Mempak switch = key(44)
Rumblepak switch = key(46)
X Axis = key(276,275)
Y Axis = key(273,274)
; Keyboard_END

_EOF_
fi

getAutoConf mupen64plus_savepath && setPath
getAutoConf mupen64plus_hotkeys && remap
getAutoConf mupen64plus_audio && setAudio
[[ "$VIDEO_PLUGIN" == "AUTO" ]] && autoset
getAutoConf mupen64plus_compatibility_check && testCompatibility
getAutoConf mupen64plus_texture_packs && useTexturePacks

if [[ "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" == BCM* ]]; then
    WINDOW_MODE="--windowed $RES"
    SDL_VIDEO_RPI_SCALE_MODE=1
    # If a raspberry pi is used lower resolution to 320x240 and enable SDL dispmanx scaling mode 1
elif [[ -e /opt/vero3/lib/libMali.so  ]]; then
    SDL_AUDIODRIVER=alsa
else
    SDL_AUDIODRIVER=pulse
fi

SDL_AUDIODRIVER=${SDL_AUDIODRIVER} SDL_VIDEO_RPI_SCALE_MODE=${SDL_VIDEO_RPI_SCALE_MODE} "$rootdir/emulators/mupen64plus/bin/mupen64plus" --noosd $PARAMS ${WINDOW_MODE} --rsp ${RSP_PLUGIN}.so --gfx ${VIDEO_PLUGIN}.so --audio ${AUDIO_PLUGIN}.so --configdir "$configdir/n64" --datadir "$configdir/n64" "$ROM"
