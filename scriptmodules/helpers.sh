#!/bin/bash

#
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
#
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
#
#  Permission to use, copy, modify and distribute this work in both binary and
#  source form, for non-commercial purposes, is hereby granted without fee,
#  providing that this license information and copyright notice appear with
#  all copies and any derived work.
#
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event shall the authors be held liable for any damages
#  arising from the use of this software.
#
#  RetroPie-Setup is freeware for PERSONAL USE only. Commercial users should
#  seek permission of the copyright holders first. Commercial use includes
#  charging money for RetroPie-Setup or software derived from RetroPie-Setup.
#
#  The copyright holders request that bug fixes and improvements to the code
#  should be forwarded to them so everyone can benefit from the modifications
#  in future versions.
#
#  Many, many thanks go to all people that provide the individual packages!!!
#

function printMsg()
{
    echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$1\n= = = = = = = = = = = = = = = = = = = = =\n"
}

function fatalError()
{
    printMsg "Fatal Error"
    echo "$1"
    exit 1
}

function ask()
{
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function hasFlag()
{
    local string="$1"
    local flag="$2"
    [ -z "$string" ] || [ -z "$flag" ] && return 1

    local re="(^| )$flag($| )"
    if [[ $string =~ $re ]]; then
        return 0
    else
        return 1
    fi
}

function isPlatform()
{
    if [ "$__platform" = "$1" ]; then
        return 0
    else
        return 1
    fi
}

function addLineToFile()
{
    if [[ -f "$2" ]]; then
        cp "$2" "$2.old"
    fi
    sed -i -e '$a\' "$2"
    echo "$1" >> "$2"
    echo "Added $1 to file $2"
}

# arg 1: delimiter, arg 2: quote, arg 3: file
function iniConfig()
{
    __ini_cfg_delim="$1"
    __ini_cfg_quote="$2"
    __ini_cfg_file="$3"
}

# arg 1: command, arg 2: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniProcess()
{
    local cmd="$1"
    local key="$2"
    local value="$3"
    local file="$4"
    [ "$file" == "" ] && file="$__ini_cfg_file"
    local delim="$__ini_cfg_delim"
    local quote="$__ini_cfg_quote"

    [ "$file" == "" ] && fatalError "No file provided for ini/config change"
    [ "$key" == "" ] && fatalError "No key provided for ini/config change on $file"

    local delim_strip=${delim// /}
    local match_re="[\s#]*$key\s*$delim_strip.*$"

    local match
    if [ -f "$file" ]; then
        match=$(egrep -i "$match_re" "$file" | tail -1)
    else
        touch "$file"
    fi

    [ "$cmd" == "unset" ] && key="# $key"
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
function iniUnset()
{
    iniProcess "unset" "$1" "$2" "$3"
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniSet()
{
    iniProcess "set" "$1" "$2" "$3"
}

function hasPackage()
{
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        return 1
    else
        return 0
    fi
}

function aptUpdate()
{
    if [[ "$__apt_update" != "1" ]]; then
        apt-get update
        __apt_update="1"
    fi
}

function aptInstall()
{
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
        aptInstall ${packages[@]}
        # check the required packages again rather than return code of apt-get, as apt-get
        # might fail for other reasons (other broken packages, eg samba in a chroot environment)
        for required in ${packages[@]}; do
            hasPackage "$required" || failed+=("$required")
        done
        if [[ ${#failed[@]} -eq 0 ]]; then
            echo "Successfully installed package(s): ${packages[@]}."
        else
            echo "Could not install package(s): ${packages[@]}. Aborting now."
            exit 1
        fi
    fi
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
            if [ $size -ge 0 ]; then
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
function gitPullOrClone()
{
    local dir="$1"
    local repo="$2"
    local shallow="$3"

    mkdir -p "$dir"

    # to work around a issue with git hanging in a qemu-arm-static chroot we can use a github created archive
    if [ $__chroot -eq 1 ] && [[ "$repo" =~ "github" ]]; then
        local archive=${repo/.git/}
        archive=${archive/git:/https:}/archive/master.tar.gz
        wget -O- -q "$archive" | tar -xvz --strip-components=1 -C "$dir"
        return
    fi

    if [ -d "$dir/.git" ]; then
        pushd "$dir" > /dev/null
        git pull > /dev/null
        popd > /dev/null
    else
        if [ "$shallow" = "NS" ]; then
            git clone "$repo" "$dir"
        else
            git clone --depth=1 "$repo" "$dir"
        fi
    fi
}

# gcc version helper
set_default()
{
    if [ -e "$1-$2" ] ; then
        # echo $1-$2 is now the default
        ln -sf $1-$2 $1
    else
        echo $1-$2 is not installed
    fi
}

# sets default gcc version
gcc_version()
{
    pushd /usr/bin > /dev/null
    for i in gcc cpp g++ gcov ; do
        set_default $i $1
    done
    popd > /dev/null
}

function ensureRootdirExists() {
    mkdir -p $rootdir
}

function rmDirExists()
{
    if [[ -d "$1" ]]; then
        rm -rf "$1"
    fi
}

# enforce rom directory permissions - root:$user for roms folder with the sticky bit set,
# and root:$user for first level subfolders with group writable. This allows them to be
# writable by the pi user, yet avoid being deleted by accident
function mkRootRomDir() {
    mkdir -p "$1"
    chown root:$user "$1"
    chmod +t "$1"
}

function mkRomDir() {
    mkdir -p "$romdir/$1"
    chown root:$user "$romdir/$1"
    chmod g+rw "$romdir/$1"
}

function mkUserDir() {
    mkdir -p "$1"
    chown $user:$user "$1"
}

function updateESConfigEdit() {
    gitPullOrClone "$rootdir/supplementary/ESConfigEdit" git://github.com/petrockblog/ESConfigEdit
}

function setESSystem() {
    local fullname=$1
    local name=$2
    local rompath=$3
    local extension=$4
    local command=$5
    local platform=$6
    local theme=$7

    if [ ! -f "$rootdir/supplementary/ESConfigEdit/esconfedit.py" ]; then
        updateESConfigEdit
    fi

    mkdir -p "/etc/emulationstation"

    $rootdir/supplementary/ESConfigEdit/esconfedit.py --dontstop \
                                                    -f "$fullname" \
                                                    -n "$name" \
                                                    -d "$rompath" \
                                                    -e "$extension" \
                                                    -c "$command" \
                                                    -p "$platform" \
                                                    -t "$theme" \
                                                    add \
                                                    "/etc/emulationstation/es_systems.cfg" \
                                                    "/etc/emulationstation/es_systems.cfg"
}
