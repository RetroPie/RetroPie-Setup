#!/usr/bin/env bash
VIDEO_PLUGIN="$1"
ROM="$2"
configdir="/opt/retropie/configs"

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
            file=$(grep --exclude=*.bak -rl "/opt/retropie/configs/all/retroarch-joypads/" -e "\"${devices[$device_num]}\"")
            if [[ -f "$file" ]]; then
                if [[ -n "$bind" ]]; then
                    bind+=","
                fi
                bind+=$(getBind "${hotkeys_rp[$i]}" "${device_num}" "$file")
            fi
        done
        # write hotkey to mupen64plus.cfg
        iniConfig " = " "\"" "/opt/retropie/configs/n64/mupen64plus.cfg"
        iniSet "${hotkeys_m64p[$i]}" "$bind"
    done
}

function fatalError() {
    echo "$1"
    exit 1
}

# arg 1: delimiter, arg 2: quote, arg 3: file
function iniConfig() {
    __ini_cfg_delim="$1"
    __ini_cfg_quote="$2"
    __ini_cfg_file="$3"
}

# arg 1: command, arg 2: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniProcess() {
    local cmd="$1"
    local key="$2"
    local value="$3"
    local file="$4"
    [[ -z "$file" ]] && file="$__ini_cfg_file"
    local delim="$__ini_cfg_delim"
    local quote="$__ini_cfg_quote"

    [[ -z "$file" ]] && fatalError "No file provided for ini/config change"
    [[ -z "$key" ]] && fatalError "No key provided for ini/config change on $file"

    # we strip the delimiter of spaces, so we can "fussy" match existing entries that have the wrong spacing
    local delim_strip=${delim// /}
    # if the stripped delimiter is empty - such as in the case of a space, just use the delimiter instead
    [[ -z "$delim_strip" ]] && delim_strip="$delim"
    local match_re="^[[:space:]#]*$key[[:space:]]*$delim_strip.*$"

    local match
    if [[ -f "$file" ]]; then
        match=$(egrep -i "$match_re" "$file" | tail -1)
    else
        touch "$file"
    fi

    if [[ "$cmd" == "del" ]]; then
        [[ -n "$match" ]] && sed -i -e "\|$match|d" "$file"
        return 0
    fi

    [[ "$cmd" == "unset" ]] && key="# $key"

    local replace="$key$delim$quote$value$quote"
    # echo "Setting $replace in $file"
    if [[ -z "$match" ]]; then
        # add key-value pair
        echo "$replace" >> "$file"
    else
        # replace existing key-value pair
        sed -i -e "s|$match|$replace|g" "$file"
    fi
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniSet() {
    iniProcess "set" "$1" "$2" "$3"
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniDel() {
    iniProcess "del" "$1" "$2" "$3"
}

# arg 1: key, arg 2: file (optional - uses file from iniConfig if not used)
# value ends up in ini_value variable
function iniGet() {
    local key="$1"
    local file="$2"
    [[ -z "$file" ]] && file="$__ini_cfg_file"
    if [[ ! -f "$file" ]]; then
        ini_value=""
        return 1
    fi
    local delim="$__ini_cfg_delim"
    local quote="$__ini_cfg_quote"
    # we strip the delimiter of spaces, so we can "fussy" match existing entries that have the wrong spacing
    local delim_strip=${delim// /}
    # if the stripped delimiter is empty - such as in the case of a space, just use the delimiter instead
    [[ -z "$delim_strip" ]] && delim_strip="$delim"
    ini_value=$(sed -rn "s/^[[:space:]]*$key[[:space:]]*$delim_strip[[:space:]]*$quote(.+)$quote.*/\1/p" $file)
}

remap
/opt/retropie/emulators/mupen64plus/bin/mupen64plus --noosd --fullscreen --gfx ${VIDEO_PLUGIN}.so --configdir $configdir/n64 --datadir $configdir/n64 "$ROM"
