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

function ask()
{
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function addLineToFile()
{
    if [[ -f "$2" ]]; then
        cp "$2" ./temp
        mv "$2" "$2.old"
    fi
    sed -i -e '$a\' ./temp
    echo "$1" >> ./temp
    mv ./temp "$2"
    echo "Added $1 to file $2"
}

# arg 1: key, arg 2: value, arg 3: file
# make sure that a key-value pair is set in file
# key = value
function ensureKeyValue()
{
    echo "Setting $1 = $2 in $3"
    if [[ -z $(egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "$1 = ""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3 | tail -1`
        sed $3 -i -e "s|$toreplace|$1 = ""$2""|g"
    fi
}

# make sure that a key-value pair is NOT set in file
# # key = value
function disableKeyValue()
{
    if [[ -z $(egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "# $1 = ""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3 `
        sed $3 -i -e "s|$toreplace|# $1 = ""$2""|g"
    fi
}

# arg 1: key, arg 2: value, arg 3: file
# make sure that a key-value pair is set in file
# key=value
function ensureKeyValueShort()
{
    if [[ -z $(egrep -i "#? *$1\s?=\s?""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "$1=""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1\s?=\s?""?[+|-]?[0-9]*[a-z]*"""? $3 | tail -1`
        sed $3 -i -e "s|$toreplace|$1=""$2""|g"
    fi
}

# make sure that a key-value pair is NOT set in file
# # key=value
function disableKeyValueShort()
{
    if [[ -z $(egrep -i "#? *$1=""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "# $1=""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1=""?[+|-]?[0-9]*[a-z]*"""? $3`
        sed $3 -i -e "s|$toreplace|# $1=""$2""|g"
    fi
}

# ensures pair of key ($1)-value ($2) in file $3
function ensureKeyValueBootconfig()
{
    if [[ -z $(egrep -i "#? *$1=[+|-]?[0-9]*[a-z]*" $3) ]]; then
        # add key-value pair
        echo "$1=$2" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1=[+|-]?[0-9]*[a-z]*" $3`
        sed $3 -i -e "s|$toreplace|$1=$2|g"
    fi
}

function printMsg()
{
    echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$1\n= = = = = = = = = = = = = = = = = = = = =\n"
}

function checkForInstalledAPTPackage()
{
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        return 0
    else
        return 1
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

function checkNeededPackages() {
    local required
    local packages=()
    local failed=()
    for required in $@; do
        checkForInstalledAPTPackage "$required" && packages+=("$required")
    done
    if [[ ${#packages[@]} -ne 0 ]]; then
        echo "Did not find needed package(s): ${packages[@]}. I am trying to install them now."
        aptInstall ${packages[@]}
        # check the required packages again rather than return code of apt-get, as apt-get
        # might fail for other reasons (other broken packages, eg samba in a chroot environment)
        for required in ${packages[@]}; do
            checkForInstalledAPTPackage "$required" && failed+=("$required")
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
    if [ -d "$1/.git" ]; then
        pushd $1 > /dev/null
        git pull > /dev/null
        popd > /dev/null
    else
        if [ "$3" = "NS" ]; then
            git clone "$2" "$1"
        else
            git clone --depth=1 "$2" "$1"
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

function setESSystem() {
    local fullname=$1
    local name=$2
    local rompath=$3
    local extension=$4
    local command=$5
    local platform=$6
    local theme=$7

    checkNeededPackages python-lxml

    gitPullOrClone "$rootdir/supplementary/ESConfigEdit" git://github.com/petrockblog/ESConfigEdit

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
