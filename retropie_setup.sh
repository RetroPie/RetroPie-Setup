#!/bin/bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi 
#  with RetroArch, various cores, and EmulationStation (a graphical 
#  front end).
# 
#  (c) Copyright 2012-2013  Florian Müller (contact@petrockblock.com)
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

__ERRMSGS=""
__INFMSGS=""
__doReboot=0

__default_cflags="-O2 -pipe -mfpu=vfp -march=armv6j -mfloat-abi=hard"
__default_asflags=""
__default_gcc_version="4.7"

[[ -z "${CFLAGS}"        ]] && export CFLAGS="${__default_cflags}"
[[ -z "${CXXFLAGS}" ]] && export CXXFLAGS="${__default_cflags}"
[[ -z "${ASFLAGS}"         ]] && export ASFLAGS="${__default_asflags}"

# HELPER FUNCTIONS ###

#set -o nounset
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
        echo "Loaded module $script_absolute_dir/$module.shinc"
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

function loadConfig()
{
    # @description Routine for loading configuration files that contain key-value pairs in the format KEY="VALUE"
    # param  $1 Path to the configuration file relate to this file.
    local configfile=$1
    if test -e "$script_absolute_dir/$configfile"
    then
        . "$script_absolute_dir/$configfile"
        echo "Loaded configuration file $script_absolute_dir/$configfile"
        return
    else
        echo "Unable to find configuration file $script_absolute_dir/$configfile"
        exit 1
    fi
}

script_invoke_path="$0"
script_name=`basename "$0"`
getScriptAbsoluteDir "$script_invoke_path"
script_absolute_dir=$RESULT

# load script modules
import "scriptmodules/helpers"
import "scriptmodules/raspbianconfig"
import "scriptmodules/emulators"
import "scriptmodules/libretrocores"
import "scriptmodules/supplementary"
import "scriptmodules/setup"
import "scriptmodules/retropiesetup"

loadConfig "configs/retronetplay.cfg"

# END HELPER FUNCTIONS ###

######################################
# here starts the main loop ##########
######################################

scriptdir=`dirname $0`
scriptdir=`cd $scriptdir && pwd`

rps_checkNeededPackages
gcc_version $__default_gcc_version

if [[ "$1" == "--help" ]]; then
    showHelp
    exit 0
fi

if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./retropie_setup' or ./retropie_setup --help for further information\n"
  exit 1
fi

# if called with sudo ./retropie_setup.sh, the installation directory is /home/CURRENTUSER/RetroPie for the current user
# if called with sudo ./retropie_setup.sh USERNAME, the installation directory is /home/USERNAME/RetroPie for user USERNAME
# if called with sudo ./retropie_setup.sh USERNAME ABSPATH, the installation directory is ABSPATH for user USERNAME
    
if [[ $# -lt 1 ]]; then
    user=$SUDO_USER
    if [ -z "$user" ]
    then
        user=$(whoami)
    fi
    rootdir=/home/$user/RetroPie
elif [[ $# -lt 2 ]]; then
    user=$1
    rootdir=/home/$user/RetroPie
elif [[ $# -lt 3 ]]; then
    user=$1
    rootdir=$2
fi

if [[ $user == "root" ]]; then
    echo "Please start the RetroPie Setup Script not as user 'root', but, e.g., as user 'pi'."
    exit
fi

esscrapimgw=275 # width in pixel for EmulationStation games scraper

home=$(eval echo ~$user)

# make sure that RetroPie root directory exists
if [[ ! -d $rootdir ]]; then
    mkdir -p "$rootdir"
    if [[ ! -d $rootdir ]]; then
      echo "Couldn't make directory $rootdir"
      exit 1
    fi
fi

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

# make sure that enough space is available
rps_availFreeDiskSpace 800000

while true; do
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose installation either based on binaries or on sources." 22 76 16)
    options=(1 "Binaries-based INSTALLATION (faster, but possibly not up-to-date)"
             2 "Source-based INSTALLATION (16-20 hours (!), but up-to-date versions)"
             3 "SETUP (only if you already have run one of the installations above)"
             4 "UPDATE RetroPie Setup script"
             5 "UPDATE RetroPie Binaries"
             6 "UNINSTALL RetroPie installation"
             7 "Perform REBOOT" )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        case $choices in
            1) now=$(date +'%d%m%Y_%H%M%S')
               {
                    rps_main_binaries
               } 2>&1 | tee >(gzip --stdout > $scriptdir/logs/run_$now.log.gz)
               chown -R $user $scriptdir/logs/run_$now.log.gz
               chgrp -R $user $scriptdir/logs/run_$now.log.gz
               ;;
            2) rps_main_options ;;
            3) rps_main_setup ;;
            4) rps_main_updatescript ;;
            5) rps_downloadBinaries ;;
            6) rc_removeAPTPackages ;;
            7) rps_main_reboot ;;
        esac
    else
        break
    fi
done

if [[ $__doReboot -eq 1 ]]; then
    dialog --title "The firmware has been updated and a reboot is needed." --clear \
        --yesno "Would you like to reboot now?\
        " 22 76

        case $? in
          0)
            rps_main_reboot
            ;;
          *)        
            ;;
        esac
fi
clear
