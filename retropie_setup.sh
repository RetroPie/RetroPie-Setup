#!/usr/bin/env bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi 
#  with RetroArch, various cores, and EmulationStation (a graphical 
#  front end).
# 
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
# 
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
# 
#  Permission to use, copy, modify and distribute RetroPie-Setup in both binary and
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
#  Raspberry Pi is a trademark of the Raspberry Pi Foundation.
# 

function getScriptAbsoluteDir() {
    # @description used to get the script path
    # @param $1 the script $0 parameter
    local script_invoke_path="$1"
    local cwd=`pwd`

    # absolute path ? if so, the first character is a /
    if test "x${script_invoke_path:0:1}" = 'x/'
    then
        RESULT=`dirname "$script_invoke_path"`
    else
        RESULT=`dirname "$cwd/$script_invoke_path"`
    fi
}

function import() { 
    # @description importer routine to get external functionality.
    # @description the first location searched is the script directory.
    # @description if not found, search the module in the paths contained in $SHELL_LIBRARY_PATH environment variable
    # @param $1 the .shinc file to import, without .shinc extension
    module=$1

    if test "x$module" == "x"
    then
        echo "$script_name : Unable to import unspecified module. Dying."
        exit 1
    fi

    if test "x${script_absolute_dir:-notset}" == "xnotset"
    then
        echo "$script_name : Undefined script absolute dir. Did you remove getScriptAbsoluteDir? Dying."
        exit 1
    fi

    if test "x$script_absolute_dir" == "x"
    then
        echo "$script_name : empty script path. Dying."
        exit 1
    fi

    if test -e "$script_absolute_dir/$module.shinc"
    then
        # import from script directory
        . "$script_absolute_dir/$module.shinc"
        # echo "Loaded module $script_absolute_dir/$module.shinc"
        return
    elif test "x${SHELL_LIBRARY_PATH:-notset}" != "xnotset"
    then
        # import from the shell script library path
        # save the separator and use the ':' instead
        local saved_IFS="$IFS"
        IFS=':'
        for path in $SHELL_LIBRARY_PATH
        do
            if test -e "$path/$module.shinc"
            then
                . "$path/$module.shinc"
                return
            fi
        done
        # restore the standard separator
        IFS="$saved_IFS"
    fi
    echo "$script_name : Unable to find module $module."
    exit 1
}

function initImport() {
	script_invoke_path="$0"
	script_name=`basename "$0"`
	getScriptAbsoluteDir "$script_invoke_path"
	script_absolute_dir=$RESULT	
}

function rps_checkNeededPackages() {
    if [[ -z $(type -P git) || -z $(type -P dialog) ]]; then
        echo "Did not find needed packages 'git' and/or 'dialog'. I am trying to install these now."
        apt-get update
        apt-get install -y git dialog
        if [ $? == '0' ]; then
            echo "Successfully installed 'git' and/or 'dialog'."
        else
            echo "Could not install 'git' and/or 'dialog'. Aborting now."
            exit 1
        fi
    else
        echo "Found needed packages 'git' and 'dialog'."
    fi 
}

function rps_availFreeDiskSpace() {
    local __required=$1
    local __avail=`df -P $rootdir | tail -n1 | awk '{print $4}'`

    required_MB=`expr $__required / 1024`
    available_MB=`expr $__avail / 1024`

    if [[ "$__required" -le "$__avail" ]] || ask "Minimum recommended disk space ($required_MB MB) not available. Try 'sudo raspi-config' to resize partition to full size. Only $available_MB MB available at $rootdir continue anyway?"; then
        return 0;
    else
        exit 0;
    fi
}

function checkForLogDirectory() {
	# make sure that RetroPie-Setup log directory exists
	if [[ ! -d $scriptdir/logs ]]; then
	    mkdir -p "$scriptdir/logs"
	    chown $user "$scriptdir/logs"
	    chgrp $user "$scriptdir/logs"
	    if [[ ! -d $scriptdir/logs ]]; then
	      echo "Couldn't make directory $scriptdir/logs"
	      exit 1
	    fi
	fi	
}

# =============================================================
#  START OF THE MAIN SCRIPT
# =============================================================

user=$SUDO_USER
if [ -z "$user" ]
then
    user=$(whoami)
fi
home=$(eval echo ~$user)

rootdir=/opt/retropie
homedir="$home/RetroPie"
romdir="$homedir/roms"
if [[ ! -d $romdir ]]; then
	mkdir $romdir
fi

# check, if sudo is used
if [ $(id -u) -ne 0 ]; then
    printf "Script must be run as root. Try 'sudo ./retropackages'\n"
    exit 1
fi   

scriptdir=`dirname $0`
scriptdir=`cd $scriptdir && pwd`

# load script modules
initImport
import "scriptmodules/helpers"
import "scriptmodules/retropiesetup"

checkForLogDirectory

rps_checkNeededPackages

# make sure that enough space is available
if [[ ! -d $rootdir ]]; then
	mkdir -p $rootdir
fi
rps_availFreeDiskSpace 800000

while true; do
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose installation either based on binaries or on sources." 22 76 16)
    options=(1 "Binaries-based INSTALLATION (faster, but possibly not up-to-date)"
             2 "Source-based INSTALLATION (16-20 hours (!), but up-to-date versions)"
             3 "SETUP (only if you already have run one of the installations above)"
             4 "UPDATE RetroPie Setup script"
             5 "UPDATE RetroPie Binaries"
             7 "Perform REBOOT" )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        case $choices in
            1) rps_main_binaries ;;
            2) rps_main_options ;;
            3) rps_main_setup ;;
            4) rps_main_updatescript ;;
            5) rps_downloadBinaries ;;
            7) rps_main_reboot ;;
        esac
    else
        break
    fi
done

# make sure that the user has access to all files in the home folder
chown -R $user:$user $homedir


