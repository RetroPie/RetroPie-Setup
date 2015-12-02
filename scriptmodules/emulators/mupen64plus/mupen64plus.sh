#!/usr/bin/env bash
VIDEO_PLUGIN="$1"
ROM="$2"
rootdir="/opt/retropie"
configdir="$rootdir/configs"

source "$rootdir/lib/inifuncs.sh"

# arg 1: hotkey name, arg 2: device number, arg 3: retroarch auto config file
function getBind() {
    local key="$1"
    local m64p_hotkey="J$2"
    local file="$3"
    local input_type
    
    iniConfig " = " "" "$file"

    # search hotkey enable button
    for input_type in "_btn" "_axis"; do 
        iniGet "input_enable_hotkey${input_type}"
        ini_value="${ini_value// /}"
        if [[ -n "$ini_value" ]]; then
            case "$input_type" in
                _axis)
                    ini_value="${ini_value//\"/}"
                    m64p_hotkey+="A${ini_value:1}${ini_value:0:1}/"
                    break
                ;;
                _btn)
                    # if ini_value contains "h" it should be a hat device
                    if [[ "$ini_value" == *h* ]]; then
                        ini_value="${ini_value//\"/}"
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
                        m64p_hotkey+="H${ini_value:0:1}V${dir}/"
                        break
                    else
                        m64p_hotkey+="B${ini_value//\"/}/"
                        break
                    fi
                ;;
            esac
        fi
    done

    # search hotkey
    for input_type in "_btn" "_axis"; do 
        # add hotkey and append enable hotkey button
        # return if hotkey exists
        iniGet "${key}${input_type}"
        ini_value="${ini_value// /}"
        if [[ -n "$ini_value" ]]; then
            case "$input_type" in
                _axis)
                    ini_value="${ini_value//\"/}"
                    m64p_hotkey+="A${ini_value:1}${ini_value:0:1}"
                    echo "$m64p_hotkey"
                    return
                    ;;
                _btn)
                    # if ini_value contains "h" it should be a hat device
                    if [[ "$ini_value" == *h* ]]; then
                        ini_value="${ini_value//\"/}"
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
                        m64p_hotkey+="H${ini_value:0:1}V${dir}"
                        echo "$m64p_hotkey"
                        return
                    else
                        m64p_hotkey+="B${ini_value//\"/}"
                        echo "$m64p_hotkey"
                        return
                    fi 
                    ;;
            esac
        fi
    done
    return
}

function remap() {
    local device
    local devices
    local device_num
    
    # get lists of all present js device numbers and device names
    # get device count
    for device in /dev/input/js*; do
        device_num=${device/\/dev\/input\/js/}
        devices[$device_num]=$(</sys/class/input/js${device_num}/device/name)
    done

    # read retroarch auto config file and use config 
    # for mupen64plus.cfg
    local file
    local bind
    local hotkeys_rp=( "input_exit_emulator" "input_load_state" "input_save_state" )
    local hotkeys_m64p=( "Joy Mapping Stop" "Joy Mapping Load State" "Joy Mapping Save State" )
    local i
    local j
    
    for i in {0..2}; do
        bind=""
        for device_num in "${!devices[@]}"; do
            # get name of retroarch auto config file
            file=$(grep --exclude=*.bak -rl "$configdir/all/retroarch-joypads/" -e "\"${devices[$device_num]}\"")
            if [[ -f "$file" ]]; then
                if [[ -n "$bind" && "$bind" != *, ]]; then
                    bind+=","
                fi
                bind+=$(getBind "${hotkeys_rp[$i]}" "${device_num}" "$file")
            fi
        done
        # write hotkey to mupen64plus.cfg
        iniConfig " = " "\"" "$configdir/n64/mupen64plus.cfg"
        iniSet "${hotkeys_m64p[$i]}" "$bind"
    done
}

function setAudio() {
    local audio_device=$(amixer cget numid=3)
    iniConfig " = " "\"" "$configdir/n64/mupen64plus.cfg"
    if [[ "$audio_device" == *": values=0"* ]]; then
        local video_device=$(tvservice -s)
        if [[ "$video_device" == *HDMI* ]]; then
            iniSet "OUTPUT_PORT" "1"
        else
            iniSet "OUTPUT_PORT" "0"
        fi
    elif [[ "$audio_device" == *": values=1"* ]]; then
        # echo "audio jack"
        iniSet "OUTPUT_PORT" "0"
    else
        # echo "hdmi"
        iniSet "OUTPUT_PORT" "1"
    fi
}

function testCompatibility() {
    # fallback for glesn64 and rice plugin
    # some roms lead to a black screen of death
    local game
    local glesn64_blacklist=(
        zelda
        Zelda
        ZELDA
        paper
        Paper
        PAPER
        kazooie
        Kazooie
        KAZOOIE
        tooie
        Tooie
        TOOIE
        instinct
        Instinct
        INSTINCT
    )

    local glesn64rice_blacklist=(
        yoshi
        Yoshi
        YOSHI
    )

    if [[ "$VIDEO_PLUGIN" == "mupen64plus-video-n64" ]];then
        for game in "${glesn64_blacklist[@]}"; do
            if [[ "$ROM" == *"$game"* ]]; then
                VIDEO_PLUGIN="mupen64plus-video-rice"
            fi
        done
    fi

    if [[ "$VIDEO_PLUGIN" != "mupen64plus-video-GLideN64" ]];then
        for game in "${glesn64rice_blacklist[@]}"; do
            if [[ "$ROM" == *"$game"* ]]; then
                VIDEO_PLUGIN="mupen64plus-video-GLideN64"
            fi
        done
    fi
}

remap
testCompatibility
setAudio
"$rootdir/emulators/mupen64plus/bin/mupen64plus" --noosd --fullscreen --gfx ${VIDEO_PLUGIN}.so --configdir "$configdir/n64" --datadir "$configdir/n64" "$ROM"
