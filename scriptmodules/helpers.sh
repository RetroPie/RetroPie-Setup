#!/bin/bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function printMsgs() {
    local type="$1"
    shift
    if [[ "$__nodialog" == "1" && "$type" == "dialog" ]]; then
        type="console"
    fi
    for msg in "$@"; do
        [[ "$type" == "dialog" ]] && dialog --backtitle "$__backtitle" --cr-wrap --no-collapse --msgbox "$msg" 20 60 >/dev/tty
        [[ "$type" == "console" ]] && echo -e "$msg"
        [[ "$type" == "heading" ]] && echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$msg\n= = = = = = = = = = = = = = = = = = = = =\n"
    done
}

function printHeading() {
    printMsgs "heading" "$@"
}

function fatalError() {
    printHeading "Error"
    echo "$1"
    exit 1
}

function fnExists() {
    declare -f "$1" > /dev/null
    return $?
}

function ask() {
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function hasFlag() {
    local string="$1"
    local flag="$2"
    [[ -z "$string" ]] || [[ -z "$flag" ]] && return 1

    local re="(^| )$flag($| )"
    if [[ $string =~ $re ]]; then
        return 0
    else
        return 1
    fi
}

function isPlatform() {
    local flag="$1"
    if hasFlag "$__platform $__platform_flags" "$flag"; then
        return 0
    fi
    return 1
}

function addLineToFile() {
    if [[ -f "$2" ]]; then
        cp -p "$2" "$2.bak"
    fi
    sed -i -e '$a\' "$2"
    echo "$1" >> "$2"
    echo "Added $1 to file $2"
}

function editFile() {
    local file="$1"
    local cmd=(dialog --backtitle "$__backtitle" --editbox "$file" 22 76)
    local choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && echo "$choice" >"$file"
}

function hasPackage() {
    local pkg="$1"
    local req_ver="$2"
    local comp="$3"
    [[ -z "$comp" ]] && comp="ge"
    local status=$(dpkg-query -W --showformat='${Status} ${Version}' $1 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        local ver="${status##* }"
        local status="${status% *}"
        # if status doesn't contain "ok installed" package is not installed
        if [[ "$status" == *"ok installed" ]]; then
            # if we didn't request a version number, be happy with any
            [[ -z "$req_ver" ]] && return 0
            dpkg --compare-versions "$ver" "$comp" "$req_ver" && return 0
        fi
    fi
    return 1
}

function aptUpdate() {
    if [[ "$__apt_update" != "1" ]]; then
        apt-get update
        __apt_update="1"
    fi
}

function aptInstall() {
    aptUpdate
    apt-get install -y "$@"
    return $?
}

function aptRemove() {
    aptUpdate
    apt-get remove -y "$@"
    return $?
}

function getDepends() {
    local required
    local packages=()
    local failed=()
    for required in $@; do
        if [[ "$md_mode" == "install" ]]; then
            # make sure we have our sdl1 / sdl2 installed
            if ! isPlatform "x11" && [[ "$required" == "libsdl1.2-dev" ]] && ! hasPackage libsdl1.2-dev 1.2.15-$(get_ver_sdl1)rpi "eq"; then
                packages+=("$required")
                continue
            fi
            if ! isPlatform "x11" && [[ "$required" == "libsdl2-dev" ]] && ! hasPackage libsdl2-dev $(get_ver_sdl2) "eq"; then
                packages+=("$required")
                continue
            fi
        fi
        if [[ "$required" == "libraspberrypi-dev" ]] && hasPackage rbp-bootloader-osmc; then
            required="rbp-userland-dev-osmc"
        fi
        if [[ "$md_mode" == "remove" ]]; then
            hasPackage "$required" && packages+=("$required")
        else
            hasPackage "$required" || packages+=("$required")
        fi
    done
    if [[ ${#packages[@]} -ne 0 ]]; then
        if [[ "$md_mode" == "remove" ]]; then
            apt-get remove --purge -y "${packages[@]}"
            apt-get autoremove --purge -y
            return 0
        fi
        echo "Did not find needed package(s): ${packages[@]}. I am trying to install them now."

        # workaround to force installation of our fixed libsdl1.2 and custom compiled libsdl2 for rpi
        if isPlatform "rpi" || isPlatform "mali"; then
            local temp=()
            for required in ${packages[@]}; do
                if isPlatform "rpi" && [[ "$required" == "libsdl1.2-dev" ]]; then
                    if [[ "$__has_binaries" -eq 1 ]]; then
                        rp_callModule sdl1 install_bin
                    else
                        rp_callModule sdl1
                    fi
                elif [[ "$required" == "libsdl2-dev" ]]; then
                    if [[ "$__has_binaries" -eq 1 ]]; then
                        rp_callModule sdl2 install_bin
                    else
                        rp_callModule sdl2
                    fi
                else
                    temp+=("$required")
                fi
            done
            packages=("${temp[@]}")
        fi

        aptInstall --no-install-recommends "${packages[@]}"

        # check the required packages again rather than return code of apt-get,
        # as apt-get might fail for other reasons (eg other half installed packages)
        for required in ${packages[@]}; do
            if ! hasPackage "$required"; then
                # workaround for installing samba in a chroot (fails due to failed smbd service restart)
                # we replace the init.d script with an empty script so the install completes
                if [[ "$required" == "samba" && "$__chroot" -eq 1 ]]; then
                    mv /etc/init.d/smbd /etc/init.d/smbd.old
                    echo "#!/bin/sh" >/etc/init.d/smbd
                    chmod u+x /etc/init.d/smbd
                    apt-get -f install
                    mv /etc/init.d/smbd.old /etc/init.d/smbd
                else
                    failed+=("$required")
                fi
            fi
        done
        if [[ ${#failed[@]} -eq 0 ]]; then
            printMsgs "console" "Successfully installed package(s): ${packages[*]}."
        else
            md_ret_errors+=("Could not install package(s): ${failed[*]}.")
            return 1
        fi
    fi
    return 0
}

function rpSwap() {
    local command=$1
    local swapfile="$__swapdir/swap"
    case $command in
        on)
            rpSwap off
            local memory=$(free -t -m | awk '/^Total:/{print $2}')
            local needed=$2
            local size=$((needed - memory))
            mkdir -p "$__swapdir/"
            if [[ $size -ge 0 ]]; then
                echo "Adding $size MB of additional swap"
                fallocate -l ${size}M "$swapfile"
                mkswap "$swapfile"
                swapon "$swapfile"
            fi
            ;;
        off)
            echo "Removing additional swap"
            swapoff "$swapfile" 2>/dev/null
            rm -f "$swapfile"
            ;;
    esac
}

# clones or updates the sources of a repository $2 into the directory $1
function gitPullOrClone() {
    local dir="$1"
    local repo="$2"
    local branch="$3"
    [[ -z "$branch" ]] && branch="master"

    if [[ -d "$dir/.git" ]]; then
        pushd "$dir" > /dev/null
        git pull > /dev/null
        popd > /dev/null
    else
        local git="git clone"
        [[ "$repo" =~ github ]] && git+=" --depth 1"
        [[ "$branch" != "master" ]] && git+=" --branch $branch"
        echo "$git \"$repo\" \"$dir\""
        $git "$repo" "$dir"
    fi
}

function ensureRootdirExists() {
    mkdir -p "$rootdir"
    mkUserDir "$datadir"
    mkUserDir "$configdir"
    mkUserDir "$configdir/all"

    # make sure we have inifuncs.sh in place and that it is up to date
    mkdir -p "$rootdir/lib"
    if [[ ! -f "$rootdir/lib/inifuncs.sh" || "$rootdir/lib/inifuncs.sh" -ot "$scriptdir/scriptmodules/inifuncs.sh" ]]; then
        cp --preserve=timestamps "$scriptdir/scriptmodules/inifuncs.sh" "$rootdir/lib/inifuncs.sh"
    fi

    # create template for autoconf.cfg and make sure it is owned by $user
    local config="$configdir/all/autoconf.cfg"
    if [[ ! -f "$config" ]]; then
        echo "# this file can be used to enable/disable retropie autoconfiguration features" >"$config"
    fi
    chown $user:$user "$config"
}

function rmDirExists() {
    if [[ -d "$1" ]]; then
        rm -rf "$1"
    fi
}

function mkUserDir() {
    mkdir -p "$1"
    chown $user:$user "$1"
}

function mkRomDir() {
    mkUserDir "$romdir/$1"
    if [[ "$1" == "megadrive" ]]; then
        pushd "$romdir"
        ln -snf "$1" "genesis"
        popd
    fi
}

function moveConfigDir() {
    local from="$1"
    local to="$2"

    # if we are in remove mode - remove the symlink
    if [[ "$md_mode" == "remove" ]]; then
        [[ -h "$from" ]] && rm -f "$from"
        return
    fi

    mkUserDir "$to"
    # move any old configs to the new location
    if [[ -d "$from" && ! -h "$from" ]]; then
        # also match hidden files
        shopt -s dotglob
        if [[ -n "$(ls -A $from)" ]]; then
            mv -f "$from/"* "$to"
        fi
        shopt -u dotglob
        rmdir "$from"
    fi
    ln -snf "$to" "$from"
    # set ownership of the actual link to $user
    chown -h $user:$user "$from"
}

function moveConfigFile() {
    local from="$1"
    local to="$2"

    # if we are in remove mode - remove the symlink
    if [[ "$md_mode" == "remove" && -h "$from" ]]; then
        rm -f "$from"
        return
    fi

    # move old file
    if [[ -f "from" && ! -h "from" ]]; then
        mv "from" "$to"
    fi
    ln -sf "$to" "$from"
    # set ownership of the actual link to $user
    chown -h $user:$user "$from"
}

function diffFiles() {
    diff -q "$1" "$2" >/dev/null
    return $?
}

function copyDefaultConfig() {
    local from="$1"
    local to="$2"
    # if the destination exists, and is different then copy the config as name.rp-dist
    if [[ -f "$to" ]]; then
        if ! diffFiles "$from" "$to"; then
            to+=".rp-dist"
            printMsgs "console" "Copying new default configuration to $to"
            cp "$from" "$to"
        fi
    else
        printMsgs "console" "Copying default configuration to $to"
        cp "$from" "$to"
    fi

    chown $user:$user "$to"
}

function setDispmanx() {
    isPlatform "rpi" || return
    local mod_id="$1"
    local status="$2"
    mkUserDir "$configdir/all"
    iniConfig "=" "\"" "$configdir/all/dispmanx.cfg"
    iniSet $mod_id "$status"
    chown $user:$user "$configdir/all/dispmanx.cfg"
}

function iniFileEditor() {
    local delim="$1"
    local quote="$2"
    local config="$3"
    [[ ! -f "$config" ]] && return

    iniConfig "$delim" "$quote" "$config"
    local sel
    local value
    local option
    local title
    while true; do
        local options=()
        local params=()
        local values=()
        local keys=()
        local i=0

        # generate menu from options
        for option in "${ini_options[@]}"; do
            # split into new array (globbing safe)
            read -ra option <<<"$option"
            key="${option[0]}"
            keys+=("$key")
            params+=("${option[*]:1}")

            # if the first parameter is _function_ we call the second parameter as a function
            # so we can handle some options with a custom menu etc
            if [[ "$key" == "_function_" ]]; then
                value="$(${option[1]} get)"
            else
                # get current value
                iniGet "$key"
                if [[ -n "$ini_value" ]]; then
                    value="$ini_value"
                else
                    value="unset"
                fi
            fi

            values+=("$value")

            # add the matching value to our id in _id_ lists
            if [[ "${option[1]}" == "_id_" && "$value" != "unset" ]]; then
                value+=" - ${option[value+2]}"
            fi

            # use custom title if provided
            if [[ -n "${ini_titles[i]}" ]]; then
                title="${ini_titles[i]}"
            else
                title="$key"
            fi

            options+=("$i" "$title ($value)" "${ini_descs[i]}")

            ((i++))
        done

        local cmd=(dialog --backtitle "$__backtitle" --default-item "$sel" --item-help --help-button --menu "Please choose the setting to modify in $config" 22 76 16)
        sel=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${sel[@]:0:4}" == "HELP" ]]; then
            printMsgs "dialog" "${sel[@]:5}"
            continue
        fi

        [[ -z "$sel" ]] && break

        # if the key is _function_ we handle the option with a custom function
        if [[ "${keys[sel]}" == "_function_" ]]; then
            "${params[sel]}" set "${values[sel]}"
            continue
        fi

        # process the editing of the option
        i=0
        options=("U" "unset")
        local default=""

        # split into new array (globbing safe)
        read -ra params <<<"${params[sel]}"

        local mode="${params[0]}"

        case "$mode" in
            _string_)
                options+=("E" "Edit (Currently ${values[sel]})")
                ;;
            _file_)
                local match="${params[1]}"
                local path="${params[*]:2}"
                local file
                while read file; do
                    [[ "${values[sel]}" == "$file" ]] && default="$i"
                    file="${file//$path\//}"
                    options+=("$i" "$file")
                    ((i++))
                done < <(find "$path" -type f -name "$match" | sort)
                ;;
            _id_|*)
                [[ "$mode" == "_id_" ]] && params=("${params[@]:1}")
                for option in "${params[@]}"; do
                    if [[ "$mode" == "_id_" ]]; then
                        [[ "${values[sel]}" == "$i" ]] && default="$i"
                    else
                        [[ "${values[sel]}" == "$option" ]] && default="$i"
                    fi
                    options+=("$i" "$option")
                    ((i++))
                done
                ;;
        esac
        [[ -z "$default" ]] && default="U"
        # display values
        cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Please choose the value for ${keys[sel]}" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        # if it is a _string_ type we will open an inputbox dialog to get a manual value
        if [[ -z "$choice" ]]; then
            continue
        elif [[ "$choice" == "E" ]]; then
            [[ "${values[sel]}" == "unset" ]] && values[sel]=""
            cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the value for ${keys[sel]}" 10 60 "${values[sel]}")
            value=$("${cmd[@]}" 2>&1 >/dev/tty)
        elif [[ "$choice" == "U" ]]; then
            value=""
        else
            if [[ "$mode" == "_id_" ]]; then
                value="$choice"
            else
                # get the actual value from the options array
                local index=$((choice*2+3))
                if [[ "$mode" == "_file_" ]]; then
                    value="$path/${options[index]}"
                else
                    value="${options[index]}"
                fi
            fi
        fi

        if [[ "$choice" == "U" ]]; then
            iniUnset "${keys[sel]}" "$value"
        else
            iniSet "${keys[sel]}" "$value"
        fi

    done
}

function setESSystem() {
    local fullname=$1
    local name=$2
    local path=$3
    local extension=$4
    local command=$5
    local platform=$6
    local theme=$7

    local conf="/etc/emulationstation/es_systems.cfg"
    mkdir -p "/etc/emulationstation"
    if [[ ! -f "$conf" ]]; then
        echo "<systemList />" >"$conf"
    fi

    cp "$conf" "$conf.bak"
    if [[ $(xmlstarlet sel -t -v "count(/systemList/system[name='$name'])" "$conf") -eq 0 ]]; then
        xmlstarlet ed -L -s "/systemList" -t elem -n "system" -v "" \
            -s "/systemList/system[last()]" -t elem -n "name" -v "$name" \
            -s "/systemList/system[last()]" -t elem -n "fullname" -v "$fullname" \
            -s "/systemList/system[last()]" -t elem -n "path" -v "$path" \
            -s "/systemList/system[last()]" -t elem -n "extension" -v "$extension" \
            -s "/systemList/system[last()]" -t elem -n "command" -v "$command" \
            -s "/systemList/system[last()]" -t elem -n "platform" -v "$platform" \
            -s "/systemList/system[last()]" -t elem -n "theme" -v "$theme" \
            "$conf"
    else
        xmlstarlet ed -L \
            -u "/systemList/system[name='$name']/fullname" -v "$fullname" \
            -u "/systemList/system[name='$name']/path" -v "$path" \
            -u "/systemList/system[name='$name']/extension" -v "$extension" \
            -u "/systemList/system[name='$name']/command" -v "$command" \
            -u "/systemList/system[name='$name']/platform" -v "$platform" \
            -u "/systemList/system[name='$name']/theme" -v "$theme" \
            "$conf"
    fi

    sortESSystems "name"
}

function sortESSystems() {
    local field="$1"
    cp "/etc/emulationstation/es_systems.cfg" "/etc/emulationstation/es_systems.cfg.bak"
    xmlstarlet sel -D -I \
        -t -m "/" -e "systemList" \
        -m "//system" -s A:T:U "$1" -c "." \
        "/etc/emulationstation/es_systems.cfg.bak" >"/etc/emulationstation/es_systems.cfg"
}

function ensureSystemretroconfig {
    local system="$1"
    local shader="$2"

    if [[ ! -d "$configdir/$system" ]]; then
        mkUserDir "$configdir/$system"
    fi

    local config="$(mktemp)"
    # add the initial comment regarding include order
    echo -e "# Settings made here will only override settings in the global retroarch.cfg if placed above the #include line\n" >"$config"

    # add the per system default settings
    iniConfig " = " '"' "$config"
    iniSet "input_remapping_directory" "$configdir/$system/"

    if [[ -n "$shader" ]]; then
        iniUnset "video_smooth" "false"
        iniSet "video_shader" "$emudir/retroarch/shader/$shader"
        iniUnset "video_shader_enable" "true"
    fi

    # include the main retroarch config
    echo -e "\n#include \"$configdir/all/retroarch.cfg\"" >>"$config"

    copyDefaultConfig "$config" "$configdir/$system/retroarch.cfg"
    rm "$config"
}

function setRetroArchCoreOption() {
    local option="$1"
    local value="$2"
    iniConfig " = " "\"" "$configdir/all/retroarch-core-options.cfg"
    iniGet "$option"
    if [[ -z "$ini_value" ]]; then
        iniSet "$option" "$value"
    fi
    chown $user:$user "$configdir/all/retroarch-core-options.cfg"
}

# sets module config root to subfolder from $configdir - used for ports that are not actually in the ports etc
function setConfigRoot() {
    local dir="$1"
    md_conf_root="$configdir"
    [[ -n "$dir" ]] && md_conf_root+="/$dir"
    mkUserDir "$md_conf_root"
}

function loadModuleConfig() {
    local options=("$@")
    local option
    local key
    local value

    for option in "${options[@]}"; do
        option=(${option/=/ })
        key="${option[0]}"
        value="${option[1]}"
        iniGet "$key"
        if [[ -z "$ini_value" ]]; then
            iniSet "$key" "$value"
            echo "local $key=\"$value\""
        else
            echo "local $key=\"$ini_value\""
        fi
    done
}

# add a framebuffer mode to /etc/fb.modes - useful for adding specific resolutions used by emulators so SDL
# can use them and utilise the rpi hardware scaling
# without a 320x240 mode in fb.modes many of the emulators that output to framebuffer (stella / snes9x / gngeo)
# would just show in a small area of the screen
function ensureFBMode() {
    local res_x="$1"
    local res_y="$2"
    local res="${res_x}x${res_y}"
    sed -i "/$res mode/,/endmode/d" /etc/fb.modes

    cat >> /etc/fb.modes <<_EOF_
# added by RetroPie-Setup - $res mode for emulators
mode "$res"
    geometry $res_x $res_y $res_x $res_y 16
    timings 0 0 0 0 0 0 0
endmode
_EOF_
}

function joy2keyStart() {
    local params=("$@")
    if [[ "${#params[@]}" -eq 0 ]]; then
        params=(1b5b44 1b5b43 1b5b41 1b5b42 0a 20)
    fi
    # check if joy2key is installed
    [[ ! -f "$rootdir/supplementary/runcommand/joy2key.py" ]] && return 1

    # get the first joystick device (if not already set)
    [[ -z "$__joy2key_dev" ]] && __joy2key_dev="$(ls -1 /dev/input/js* 2>/dev/null | head -n1)"

    # if no joystick device, or joy2key is already running exit
    [[ -z "$__joy2key_dev" ]] || pgrep -f joy2key.py >/dev/null && return 1

    # if joy2key.py is installed run it with cursor keys for axis, and enter + space for buttons 0 and 1
    if "$rootdir/supplementary/runcommand/joy2key.py" "$__joy2key_dev" "${params[@]}" & 2>/dev/null; then
        __joy2key_pid=$!
        return 0
    fi

    return 1
}

function joy2keyStop() {
    if [[ -n $__joy2key_pid ]]; then
        kill -INT $__joy2key_pid 2>/dev/null
        sleep 1
    fi
}

# arg 1: 0 or 1 to make the emulator default, arg 2: module id, arg 3: "system" or "system platform" or "system platform theme", arg 4: commandline, arg 5 (optional) fullname for es config, arg 6: extensions
function addSystem() {
    local default="$1"
    local id="$2"
    local names=($3)
    local cmd="$4"
    local fullname="$5"
    local exts=($6)

    local system
    local platform
    local theme

    # set system / platform / theme for configuration based on data in names field
    if [[ -n "${names[2]}" ]]; then
        system="${names[0]}"
        platform="${names[1]}"
        theme="${names[2]}"
    elif [[ -n "${names[1]}" ]]; then
        system="${names[0]}"
        platform="${names[1]}"
        theme="$system"
    else
        system="${names[0]}"
        platform="$system"
        theme="$system"
    fi

    # check if we are removing the system
    if [[ "$md_mode" == "remove" ]]; then
        delSystem "$id" "$system"
        return
    fi

    # for the ports section, we will handle launching from a separate script and hardcode exts etc
    local es_cmd="$rootdir/supplementary/runcommand/runcommand.sh 0 _SYS_ $system %ROM%"
    local es_path="$romdir/$system"
    local es_name="$system"
    if [[ "$theme" == "ports" ]]; then
        es_cmd="%ROM%"
        es_path="$romdir/ports"
        es_name="ports"
        exts=(".sh")
        fullname="Ports"
    else
        local conf=""
        if [[ -f "$configdir/all/platforms.cfg" ]]; then
            conf="$configdir/all/platforms.cfg"
        else
            conf="$scriptdir/platforms.cfg"
        fi

        # get extensions to show
        iniConfig "=" '"' "$conf"
        iniGet "${system}_fullname"
        [[ -n "$ini_value" ]] && fullname="$ini_value"
        iniGet "${system}_exts"
        [[ -n "$ini_value" ]] && exts+=($ini_value)

        # automatically add parameters for libretro modules
        if [[ "$id" =~ ^lr- ]]; then
            cmd="$emudir/retroarch/bin/retroarch -L $cmd --config $md_conf_root/$system/retroarch.cfg %ROM%"
        fi
    fi

    exts="${exts[@]}"
    # add the extensions again as uppercase
    exts+=" ${exts^^}"

    # create a config folder for the system / port
    mkUserDir "$md_conf_root/$system"

    # add the emulator to the $conf_dir/emulators.cfg if a commandline exists (not used for some ports)
    if [[ -n "$cmd" ]]; then
        iniConfig " = " '"' "$md_conf_root/$system/emulators.cfg"
        iniSet "$id" "$cmd"
        # set a default unless there is one already set
        iniGet "default"
        if [[ -z "$ini_value" && "$default" -eq 1 ]]; then
            iniSet "default" "$id"
        fi
        chown $user:$user "$md_conf_root/$system/emulators.cfg"
    fi

    setESSystem "$fullname" "$es_name" "$es_path" "$exts" "$es_cmd" "$platform" "$theme"
}

function delSystem() {
    local id="$1"
    local system="$2"
    local config="$md_conf_root/$system/emulators.cfg"
    # remove from apps list for system
    if [[ -f "$config" && -n "$id" ]]; then
        # delete emulator entry
        iniConfig " = " '"' "$config"
        iniDel "$id"
        # if it is the default - remove it - runcommand will prompt to select a new default
        iniGet "default"
        [[ "$ini_value" == "$id" ]] && iniDel "default"
        # if we no longer have any entries in the emulators.cfg file we can remove it
        grep -q "=" "$config" || rm -f "$config"
    fi

    # if we don't have an emulators.cfg we can remove the system from emulation station
    if [[ -f /etc/emulationstation/es_systems.cfg && ! -f "$config" ]]; then
        xmlstarlet ed -L -P -d "/systemList/system[name='$system']" /etc/emulationstation/es_systems.cfg
    fi
}

function addPort() {
    local id="$1"
    local port="$2"
    local file="$romdir/ports/$3.sh"
    local cmd="$4"

    mkUserDir "$romdir/ports"

    # move configurations from old ports location
    if [[ -d "$configdir/$port" ]]; then
        mv "$configdir/$port" "$md_conf_root/"
    fi

    if [ -t 0 ]; then
        cat >"$file" << _EOF_
#!/bin/bash
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ $port
_EOF_
    else
        cat >"$file"
    fi

    chown $user:$user "$file"
    chmod +x "$file"

    # remove the ports launch script if in remove mode
    if [[ "$md_mode" == "remove" ]]; then
        rm -f "$file"
        # if there are no more port launch scripts we can remove ports from emulation station
        if [[ "$(ls -1 "$romdir/ports/*.sh" 2>/dev/null | wc -l)" -eq 0 ]]; then
            delSystem "$id" "ports"
        fi
    else
        addSystem 1 "$id" "$port pc ports" "$cmd"
    fi
}

