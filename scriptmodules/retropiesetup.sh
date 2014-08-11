#!/bin/bash

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

# downloads and installs pre-compiles binaries of all essential programs and libraries
function rps_downloadBinaries()
{
    printMsg "Downloading binaries archive"
    # wget --progress=bar:force -O - 'http://blog.petrockblock.com/?wpdmdl=3' | tar jx --overwrite -C $rootdir RetroPie
    wget -O binariesDownload.tar.bz2 http://blog.petrockblock.com/?wpdmdl=7113
    tar -jxvf binariesDownload.tar.bz2 -C $rootdir
    pushd $rootdir/retropie
    cp -r * ../
    popd
    rm -rf $rootdir/retropie
    rm binariesDownload.tar.bz2
}

# download, extract, and install binaries
function rps_main_binaries()
{
    local idx

    __INFMSGS=""

    clear
    printMsg "Binaries-based installation"

    ensureRootdirExists
    now=$(date +'%d%m%Y_%H%M')
    {
        # install all needed dependencies
        for idx in "${__mod_idx[@]}"; do
            rp_callModule "$idx" "depends"
        done

        rp_callModule aptpackages
        rp_callModule handleaptpackages
        rp_callModule modules

        rps_downloadBinaries

        rp_callModule libsdlbinaries
        rp_callModule emulationstation install
        rp_callModule emulationstation configure
        rp_callModule snesdev install
        rp_callModule disabletimeouts
        rp_callModule esthemesimple
        rp_callModule retroarchautoconf

        rp_callModule stella
        rp_callModule scummvm
        rp_callModule zmachine
        rp_callModule fuse
        rp_callModule c64roms
        rp_callModule hatari
        rp_callModule dosbox
        rp_callModule eduke32

        rp_callModule setavoidsafemode
        rp_callModule runcommand
        rp_callModule usbromservice
        rp_callModule bashwelcometweak

        # configure all emulator and libretro components
        for idx in "${__mod_idx[@]}"; do
            [[ $idx < 300 ]] && rp_callModule "$idx" "configure"
        done

        rp_callModule sambashares

    } 2>&1 > >(tee >(gzip --stdout > $scriptdir/logs/run_$now.log.gz))

    chown -R $user:$user $scriptdir/logs/run_$now.log.gz

    __INFMSGS="$__INFMSGS The Amiga emulator can be started from command line with '$rootdir/emulators/uae4all/uae4all'. Note that you must manually copy a Kickstart rom with the name 'kick.rom' to the directory $rootdir/emulators/uae4all/."
    __INFMSGS="$__INFMSGS You need to copy NeoGeo BIOS files to the folder '$rootdir/emulators/gngeo-0.7/neogeo-bios/'."
    __INFMSGS="$__INFMSGS You need to copy Intellivision BIOS files to the folder '/usr/local/share/jzintv/rom'."

    if [[ ! -z $__INFMSGS ]]; then
        dialog --backtitle "$__backtitle" --msgbox "$__INFMSGS" 20 60
    fi

    dialog --backtitle "$__backtitle" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 22 76
}

function rps_main_updatescript()
{
  printMsg "Fetching latest version of the RetroPie Setup Script."
  pushd $scriptdir
  if [[ ! -d ".git" ]]; then
    dialog --backtitle "$__backtitle" --msgbox "Cannot find direcotry '.git'. Please clone the RetroPie Setup script via 'git clone git://github.com/petrockblog/RetroPie-Setup.git'" 20 60
    popd
    return
  fi
  git pull
  popd
  dialog --backtitle "$__backtitle" --msgbox "Fetched the latest version of the RetroPie Setup script. You need to restart the script." 20 60
}

function rps_main_options()
{
    buildMenu 2 "bool"
    cmd=(dialog --separate-output --backtitle "$__backtitle" --checklist "Select options with 'space' and arrow keys. The default selection installs a complete set of packages and configures basic settings. The entries marked as (C) denote the configuration steps. For an update of an installation you would deselect these to keep all your settings untouched." 22 76 16)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    __ERRMSGS=""
    __INFMSGS=""
    if [ "$choices" != "" ]; then
        now=$(date +'%d%m%Y_%H%M')
        logfilename=$scriptdir/logs/run_$now.log.gz
        touch $logfilename
        for choice in $choices
        do
            rp_callModule $choice ${command[$choice]} 2>&1 > >(tee >(gzip --stdout >$logfilename))
        done

        if [[ ! -z $__ERRMSGS ]]; then
            dialog --backtitle "$__backtitle" --msgbox "$__ERRMSGS See debug.log for more details." 20 60
        fi

        if [[ ! -z $__INFMSGS ]]; then
            dialog --backtitle "$__backtitle" --msgbox "$__INFMSGS" 20 60
        fi

        dialog --backtitle "$__backtitle" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 20 60

        chown -R $user:$user $logfilename
    fi
}

function rps_main_setup()
{
    now=$(date +'%d%m%Y_%H%M')
    logfilename=$scriptdir/logs/run_$now.log.gz
    touch $logfilename
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose task." 22 76 16)
        buildMenu 3
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [ "$choices" != "" ]; then
            rp_callModule $choices ${command[$choices]} 2>&1 > >(tee >(gzip --stdout >$logfilename))
        else
            break
        fi
    done

    chown -R $user:$user $logfilename
}

function rps_main_experimental()
{
    now=$(date +'%d%m%Y_%H%M')
    logfilename=$scriptdir/logs/run_$now.log.gz
    touch $logfilename
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose task." 22 76 16)
        buildMenu 4
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [ "$choices" != "" ]; then
            rp_callModule $choices ${command[$choices]} 2>&1 > >(tee >(gzip --stdout >$logfilename))
        else
            break
        fi
    done

    chown -R $user:$user $logfilename
}

function rps_main_reboot()
{
    clear
    reboot
}
