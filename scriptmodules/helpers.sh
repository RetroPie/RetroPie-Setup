#!/bin/bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

function printMsgs() {
    local type="$1"
    shift
    for msg in "$@"; do
        [[ "$type" == "dialog" ]] && dialog --backtitle "$__backtitle" --msgbox "$msg" 20 60 >/dev/tty
        [[ "$type" == "console" ]] && echo "$msg"
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
    # isPlatform "rpi" matches both rpi1 and rpi2
    if [[ "$1" == "rpi" ]] && [[ "$__platform" == "rpi1" || "$__platform" == "rpi2" ]]; then
        return 0
    fi
    if [[ "$__platform" == "$1" ]]; then
        return 0
    else
        return 1
    fi
}

function addLineToFile() {
    if [[ -f "$2" ]]; then
        cp -p "$2" "$2.old"
    fi
    sed -i -e '$a\' "$2"
    echo "$1" >> "$2"
    echo "Added $1 to file $2"
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
    echo "Setting $replace in $file"
    if [[ -z "$match" ]]; then
        # add key-value pair
        echo "$replace" >> "$file"
    else
        # replace existing key-value pair
        sed -i -e "s|$match|$replace|g" "$file"
    fi
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniUnset() {
    iniProcess "unset" "$1" "$2" "$3"
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

function hasPackage() {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]]; then
        return 1
    else
        return 0
    fi
}

function aptUpdate() {
    if [[ "$__apt_update" != "1" ]]; then
        apt-get update
        __apt_update="1"
    fi
}

function aptInstall() {
    aptUpdate
    apt-get install -y --no-install-recommends $@
    return $?
}

function getDepends() {
    local required
    local packages=()
    local failed=()
    for required in $@; do
        hasPackage "$required" || packages+=("$required")
    done
    if [[ ${#packages[@]} -ne 0 ]]; then
        echo "Did not find needed package(s): ${packages[@]}. I am trying to install them now."

        # workaround to force installation of our fixed libsdl1.2 and custom compiled libsdl2 for rpi
        if isPlatform "rpi"; then
            for required in ${packages[@]}; do
                [[ "$required" == "libsdl1.2-dev" ]] && rp_callModule sdl1 install_bin
                [[ "$required" == "libsdl2-dev" ]] && rp_callModule sdl2 install_bin
            done
        fi

        aptInstall ${packages[@]}
        # check the required packages again rather than return code of apt-get, as apt-get
        # might fail for other reasons (other broken packages, eg samba in a chroot environment)
        for required in ${packages[@]}; do
            hasPackage "$required" || failed+=("$required")
        done
        if [[ ${#failed[@]} -eq 0 ]]; then
            echo "Successfully installed package(s): ${packages[@]}."
        else
            md_ret_errors+=("Could not install package(s): ${failed[@]}.")
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

    mkdir -p "$dir"

    # to work around a issue with git hanging in a qemu-arm-static chroot we can use a github created archive
    if [[ $__chroot -eq 1 ]] && [[ "$repo" =~ github ]] && [[ ! "$repo" =~ picodrive ]]; then
        local archive=${repo/.git/}
        archive="${archive/git:/https:}/archive/$branch.tar.gz"
        wget -O- -q "$archive" | tar -xvz --strip-components=1 -C "$dir"
        return
    fi

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

# gcc version helper
set_default() {
    if [[ -e "$1-$2" ]] ; then
        # echo $1-$2 is now the default
        ln -sf $1-$2 $1
    else
        echo $1-$2 is not installed
    fi
}

# sets default gcc version
gcc_version() {
    pushd /usr/bin > /dev/null
    for i in gcc cpp g++ gcov ; do
        set_default $i $1
    done
    popd > /dev/null
}

function ensureRootdirExists() {
    mkdir -p "$rootdir"
    mkUserDir "$datadir"
    mkUserDir "$configdir"
    mkUserDir "$configdir/all"
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

function setDispmanx() {
    local mod_id="$1"
    local status="$2"
    mkUserDir "$configdir/all"
    iniConfig "=" "\"" "$configdir/all/dispmanx.cfg"
    iniSet $mod_id "$status"
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
    local config="$configdir/$system/retroarch.cfg"

    if [[ ! -d "$configdir/$system" ]]; then
        mkUserDir "$configdir/$system"
    fi

    if [[ ! -f "$config" ]]; then
        echo "#include \"$configdir/all/retroarch.cfg\"" >"$config"
        echo "# All settings made here will override the global settings for the current emulator core" >>"$config"
        chown $user:$user "$config"
    fi

    if ! grep -q "#include \"$configdir/all/retroarch.cfg" "$config"; then
        sed -i "1i#include \"$configdir/all/retroarch.cfg\"" "$config"
    fi

    iniConfig " = " "" "$config"
    iniSet "input_remapping_directory" "$configdir/$system/"

    if [[ -n "$shader" ]]; then
        iniSet "video_shader" "$emudir/retroarch/shader/$shader"
        iniSet "video_shader_enable" "false"
        iniSet "video_smooth" "false"
    fi
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

    local conf=""
    if [[ -f "$configdir/all/platforms.cfg" ]]; then
        conf="$configdir/all/platforms.cfg"
    else
        conf="$scriptdir/supplementary/platforms.cfg"
    fi

    iniConfig "=" '"' "$conf"
    iniGet "${system}_fullname"
    [[ -n "$ini_value" ]] && fullname="$ini_value"
    iniGet "${system}_exts"
    [[ -n "$ini_value" ]] && exts+=($ini_value)

    exts="${exts[@]}"
    # add the extensions again as uppercase
    exts+=" ${exts^^}"

    # automatically add parameters for libretro modules
    if [[ "$id" =~ ^lr- ]]; then
        cmd="$emudir/retroarch/bin/retroarch -L $cmd --config $configdir/$system/retroarch.cfg %ROM%"
    fi

    setESSystem "$fullname" "$system" "~/RetroPie/roms/$system" "$exts" "$rootdir/supplementary/runcommand/runcommand.sh 0 _SYS_ $system %ROM%" "$platform" "$theme"

    if [[ ! -d "$configdir/$system" ]]; then
        mkdir "$configdir/$system"
        chown $user:$user "$configdir/$system"
    fi

    iniConfig "=" '"' "$configdir/$system/emulators.cfg"
    iniSet "$id" "$cmd"
    if [[ "$default" == "1" ]]; then
        iniSet "default" "$id"
    fi
    chown $user:$user "$configdir/$system/emulators.cfg"
}

function delSystem() {
    local id="$1"
    local system="$2"
    # remove from emulation station
    xmlstarlet ed -L -P -d "/systemList/system[name='$system']" /etc/emulationstation/es_systems.cfg
    # remove from apps list for system
    if [[ -f "$configdir/$system/emulators.cfg" ]]; then
        iniConfig "=" '"' "$configdir/$system/emulators.cfg"
        iniDel "$id"
    fi
}
