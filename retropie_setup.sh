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

function checkForLogDirectory() {
        # make sure that RetroPie-Setup log directory exists
        if [[ ! -d $scriptdir/logs ]]; then
            mkdir -p "$scriptdir/logs"
            chown $user:$user "$scriptdir/logs"
            if [[ ! -d $scriptdir/logs ]]; then
              echo "Couldn't make directory $scriptdir/logs"
              exit 1
            fi
        fi
}

# =============================================================
#  START OF THE MAIN SCRIPT
# =============================================================

scriptdir=`dirname $0`
scriptdir=`cd $scriptdir && pwd`

source $scriptdir/retropie_packages.sh init

import "scriptmodules/retropiesetup"

checkForLogDirectory

# make sure that enough space is available
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


