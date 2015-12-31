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

function editFile() {
    local file="$1"
    local cmd=(dialog --backtitle "$__backtitle" --editbox "$file" 22 76)
    local choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && echo "$choice" >"$file"
}

function hasPackage() {
    local pkg="$1"
    local req_ver="$2"
    ver=$(dpkg-query -W --showformat='${Version}' $1 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        # if version is blank $pkg isnt installed
        [[ -z "$ver" ]] && return 1
        # if we didn't request a version number, be happy with any
        [[ -z "$req_ver" ]] && return 0
        dpkg --compare-versions "$ver" ge "$req_ver" && return 0
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
    apt-get install -y --no-install-recommends $@
    return $?
}

function getDepends() {
    local required
    local packages=()
    local failed=()
    for required in $@; do
        # make sure we have our sdl1 / sdl2 installed
        if [[ "$required" == "libsdl1.2-dev" ]] && ! hasPackage libsdl1.2-dev 1.2.15-$(get_ver_sdl1)rpi; then
            packages+=("$required")
            continue
        fi
        if [[ "$required" == "libsdl2-dev" ]] && ! hasPackage libsdl2-dev $(get_ver_sdl2); then
            packages+=("$required")
            continue
        fi
        if [[ "$required" == "libraspberrypi-dev" ]] && hasPackage rbp-bootloader-osmc; then
            required="rbp-userland-dev-osmc"
        fi
        hasPackage "$required" || packages+=("$required")
    done
    if [[ ${#packages[@]} -ne 0 ]]; then
        echo "Did not find needed package(s): ${packages[@]}. I am trying to install them now."

        # workaround to force installation of our fixed libsdl1.2 and custom compiled libsdl2 for rpi
        if isPlatform "rpi"; then
            local temp=()
            for required in ${packages[@]}; do
                if [[ "$required" == "libsdl1.2-dev" ]]; then
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

        aptInstall ${packages[@]}
        # check the required packages again rather than return code of apt-get, as apt-get
        # might fail for other reasons (other broken packages, eg samba in a chroot environment)
        for required in ${packages[@]}; do
            hasPackage "$required" || failed+=("$required")
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

    mkdir -p "$dir"

    # to work around a issue with git hanging in a qemu-arm-static chroot we can use a github created archive
    if [[ $__chroot -eq 1 && "$repo" =~ github && ! "$md_id" =~ lr-picodrive|splashscreen|esthemes|ppsspp ]]; then
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

function ensureRootdirExists() {
    mkdir -p "$rootdir"
    # make sure we have inifuncs.sh in place and that it is up to date
    mkdir -p "$rootdir/lib"
    if [[ ! -f "$rootdir/lib/inifuncs.sh" || "$rootdir/lib/inifuncs.sh" -ot "$scriptdir/scriptmodules/inifuncs.sh" ]]; then
        cp --preserve=timestamps "$scriptdir/scriptmodules/inifuncs.sh" "$rootdir/lib/inifuncs.sh"
    fi
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

function moveConfigDir() {
    local from="$1"
    local to="$2"
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
    # move old file
    if [[ -f "from" && ! -h "from" ]]; then
        mv "from" "$to"
    fi
    ln -sf "$to" "$from"
    # set ownership of the actual link to $user
    chown -h $user:$user "$from"
}

function setDispmanx() {
    local mod_id="$1"
    local status="$2"
    mkUserDir "$configdir/all"
    iniConfig "=" "\"" "$configdir/all/dispmanx.cfg"
    iniSet $mod_id "$status"
    chown $user:$user "$configdir/all/dispmanx.cfg"
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

    local include_comment="# Settings made here will only override settings in the global retroarch.cfg if placed above the #include line"
    local include="#include \"$configdir/all/retroarch.cfg\""

    local config="$configdir/$system/retroarch.cfg"
    # if the user has an existing config we will not overwrite it, but instead create the 
    # default config as retroarch.cfg.rp-dist (apart from the very important #include addition)
    if [[ -f "$config" ]]; then
        if ! grep -q "$include" "$config"; then
            sed -i "1i$include_comment\n" "$config"
            echo -e "\n$include" >>"$config"
        fi
        config="$configdir/$system/retroarch.cfg.rp-dist"
        rm -f "$config"
    fi

    # add the initial comment regarding include order
    if [[ ! -f "$config" ]]; then
        echo -e "$include_comment\n" >"$config"
    fi

    # add the per system default settings
    iniConfig " = " "" "$config"
    iniSet "input_remapping_directory" "$configdir/$system/"

    if [[ -n "$shader" ]]; then
        iniUnset "video_smooth" "false"
        iniSet "video_shader" "$emudir/retroarch/shader/$shader"
        iniUnset "video_shader_enable" "true"
    fi

    # include the main retroarch config
    echo -e "\n$include" >>"$config"

    chown $user:$user "$config"
}

function setRetroArchCoreOption() {
    local option="$1"
    local value="$2"
    iniConfig " = " "\"" "$configdir/all/retroarch-core-options.cfg"
    iniSet "$option" "$value"
    chown $user:$user "$configdir/all/retroarch-core-options.cfg"
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
            cmd="$emudir/retroarch/bin/retroarch -L $cmd --config $configdir/$system/retroarch.cfg %ROM%"
        fi
    fi

    exts="${exts[@]}"
    # add the extensions again as uppercase
    exts+=" ${exts^^}"

    setESSystem "$fullname" "$es_name" "$es_path" "$exts" "$es_cmd" "$platform" "$theme"

    # create a config folder for the system
    if [[ ! -d "$configdir/$system" ]]; then
        mkUserDir "$configdir/$system"
    fi

    # add the emulator to the $system/emulators.cfg if a commandline exists (not used for some ports)
    if [[ -n "$cmd" ]]; then
        iniConfig "=" '"' "$configdir/$system/emulators.cfg"
        iniSet "$id" "$cmd"
        if [[ "$default" == "1" ]]; then
            iniSet "default" "$id"
        fi
        chown $user:$user "$configdir/$system/emulators.cfg"
    fi
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

function addPort() {
    local id="$1"
    local port="$2"
    local file="$romdir/ports/$3.sh"
    local cmd="$4"

    if [ -t 0 ]; then
        cat >"$file" << _EOF_
#!/bin/bash
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _SYS_ $port
_EOF_
    else
        cat >"$file"
    fi

    chown $user:$user "$file"
    chmod +x "$file"

    addSystem 1 "$id" "$port pc ports" "$cmd"
}
