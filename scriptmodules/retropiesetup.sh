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

function rps_setLogFilename() {
    local now=$(date +'%d%m%Y_%H%M')
    logfilename="$scriptdir/logs/run_$now.log.gz"
    touch "$logfilename"
}


function rps_checkForLogDirectory() {
    # make sure that RetroPie-Setup log directory exists
    if [[ ! -d $scriptdir/logs ]]; then
        if mkdir -p "$scriptdir/logs"; then
            chown $user:$user "$scriptdir/logs"
        else
            echo "Couldn't make directory $scriptdir/logs"
            exit 1
        fi
    fi
}

function rps_printInfo() {
    if [[ ${#__ERRMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__ERRMSGS[@]}"
        printMsgs "dialog" "Please see $1 more in depth information regarding the errors."
    fi
    printMsgs "dialog" "${__INFMSGS[@]}"
}

function rps_buildMenu()
{
    options=()
    command=()
    local status
    local id
    local menu
    local menus
    for id in "${__mod_idx[@]}"; do
        menus="${__mod_menus[$id]}"
        for menu in $menus; do
            command[$id]="${menu:2}"
            if [[ "${menu:0:1}" == "$1" ]]; then
                options=("${options[@]}" "$id" "${__mod_desc[$id]}")
                if [[ "$2" == "bool" ]]; then
                    status="ON"
                    [[ "${menu:1:1}" == "-" ]] && status="OFF"
                    options=("${options[@]}" "$status")
                fi
            fi
        done
    done
}

function rps_availFreeDiskSpace() {
    local rootdirExists=0
    if [[ ! -d "$rootdir" ]]; then
        rootdirExists=1
        mkdir -p $rootdir
    fi
    local __required=$1
    local __avail=$(df -P $rootdir | tail -n1 | awk '{print $4}')
    if [[ $rootdirExists -eq 1 ]]; then
        rmdir $rootdir
    fi

    required_MB=$((__required/1024))
    available_MB=$((__avail/1024))

    if [[ "$__required" -le "$__avail" ]] || ask "Minimum recommended disk space ($required_MB MB) not available. Try 'sudo raspi-config' to resize partition to full size. Only $available_MB MB available at $rootdir continue anyway?"; then
        return 0;
    else
        exit 0;
    fi
}

# retropie-setup main menu
rps_main_menu() {
    while true; do
        __ERRMSGS=()
        __INFMSGS=()

        cmd=(dialog --backtitle "$__backtitle" --menu "Choose installation either based on binaries or on sources." 22 76 16)
        options=()
        if [[ $__has_binaries -eq 1 ]]; then
            options+=(
            1 "Binaries-based INSTALLATION (faster, but possibly not up-to-date)")
        fi
        options+=(
            2 "Source-based INSTALLATION (16-20 hours (!), but up-to-date versions)"
            3 "SETUP (only if you already have run one of the installations above)"
            4 "EXPERIMENTAL packages (these are potentially unstable packages)"
        )
        if [[ $__has_binaries -eq 1 ]]; then
            options+=(
                5 "INSTALL individual emulators from binary or source"
            )
        else
            options+=(5 "INSTALL individual emulators from source")
        fi
        options+=(
            U "UPDATE RetroPie Setup script"
            R "Perform REBOOT"
        )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            case $choices in
                1) rps_main_binaries ;;
                2) rps_main_options ;;
                3) rps_main_setup ;;
                4) rps_main_experimental ;;
                5) rps_install_individual ;;
                U) rps_main_updatescript ;;
                R) rps_main_reboot ;;
            esac
        else
            break
        fi
    done
    clear
}

# downloads and installs pre-compiles binaries of all essential programs and libraries
function rps_downloadBinaries()
{
    for idx in "${__mod_idx[@]}"; do
        if [[ ! "${__mod_menus[$idx]}" =~ 4 ]] && [[ ! "${__mod_flags[$idx]}" =~ nobin ]]; then
            rp_callModule $idx install_bin
        fi
    done
}

# download, extract, and install binaries
function rps_main_binaries()
{
    local idx

    clear
    printHeading "Binaries-based installation"

    ensureRootdirExists
    local logfilename
    rps_setLogFilename
    {
        rp_callModule aptpackages
        # force installation of our sdl1 packages as wheezy package may already be installed, and so we always get the latest
        # version. This can be solved later by adding version number checking to the dependency checking
        rp_callModule sdl1 install_bin

        # and force sdl2 - so that any updates will be installed.
        rp_callModule sdl2 install_bin

        # install needed dependencies for all modules with a binary distribution (except for experimental packages)
        for idx in "${__mod_idx[@]}"; do
            if [[ ! "${__mod_menus[$idx]}" =~ 4 ]] && [[ ! "${__mod_flags[$idx]}" =~ nobin ]]; then
                rp_callModule $idx depends
                rp_callModule $idx install_bin
                [[ "${__mod_id[$idx]}" != "snesdev" ]] && rp_callModule $idx configure
            fi
        done

        # modules that have another binary distribution method (deb etc)
        rp_callModule stella
        rp_callModule zmachine
        rp_callModule fuse
        rp_callModule eduke32
        rp_callModule esthemesimple

        # required supplementary modules 
        rp_callModule retroarchautoconf
        rp_callModule runcommand

        # some additional supplementary modules
        rp_callModule disabletimeouts
        rp_callModule modules
        rp_callModule usbromservice
        rp_callModule bashwelcometweak
        rp_callModule sambashares

    } &> >(tee >(gzip --stdout > "$logfilename"))

    chown -R $user:$user "$logfilename"

    rps_printInfo "$logfilename"
    printMsgs "dialog" "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!"
}

function rps_main_updatescript()
{
    printHeading "Fetching latest version of the RetroPie Setup Script."
    pushd $scriptdir
    if [[ ! -d ".git" ]]; then
        printMsgs "dialog" "Cannot find directory '.git'. Please clone the RetroPie Setup script via 'git clone git://github.com/petrockblog/RetroPie-Setup.git'"
        popd
        return
    fi
    local error
    if ! error=$(git pull 2>&1 >/dev/null); then
        printMsgs "dialog" "Update failed:\n\n$error"
        popd
        return
    fi
    popd
    printHeading "Updating ESConfigEdit script."
    updateESConfigEdit
    printMsgs "dialog" "Fetched the latest version of the RetroPie Setup script. You need to restart the script."
}

function rps_main_options()
{
    rps_buildMenu 2 "bool"
    cmd=(dialog --separate-output --backtitle "$__backtitle" --checklist "Select options with 'space' and arrow keys. The default selection installs a complete set of packages and configures basic settings. The entries marked as (C) denote the configuration steps. For an update of an installation you would deselect these to keep all your settings untouched." 22 76 16)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    if [[ -n "$choices" ]]; then
        local logfilename
        rps_setLogFilename
        choices=($choices)
        total=${#choices[@]}
        count=1
        {
            for choice in ${choices[@]}
            do
                rp_callModule $choice ${command[$choice]}
                printHeading "Module $count of $total processed."
                ((count++))
            done
        } &> >(tee >(gzip --stdout > "$logfilename"))
        chown -R $user:$user "$logfilename"

        rps_printInfo "$logfilename"
        printMsgs "dialog" "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!"
    fi
}

function rps_main_setup()
{
    local logfilename
    rps_setLogFilename
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose task." 22 76 16)
        rps_buildMenu 3
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            rp_callModule $choices ${command[$choices]} &> >(tee >(gzip --stdout >$logfilename))
        else
            break
        fi
    done

    rps_printInfo "$logfilename"
    chown -R $user:$user "$logfilename"
}

function rps_main_experimental()
{
    local logfilename
    while true; do
        rps_setLogFilename
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose task." 22 76 16)
        rps_buildMenu 4
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            rp_callModule $choices ${command[$choices]} &> >(tee >(gzip --stdout >$logfilename))
        else
            break
        fi
    done

    rps_printInfo "$logfilename"
    chown -R $user:$user $logfilename
}

function rps_install_individual()
{
    local logfilename
    local options=()
    for idx in "${__mod_idx[@]}"; do
        if [[ ! "${__mod_menus[$idx]}" =~ 4 ]] && [[ ! "${__mod_flags[$idx]}" =~ nobin ]]; then
            options+=($idx "${__mod_id[$idx]} - ${__mod_desc[$idx]}")
        fi
    done
    while true; do
        local md_idx=$(dialog --backtitle "$__backtitle" --menu "Select Emulator/Port." 22 76 16 "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$md_idx" ]]; then
            rps_setLogFilename
            local choice
            if [[ $__has_binaries -eq 1 ]]; then
                choice=$(dialog --backtitle "$__backtitle" --menu "Install ${__mod_id[$md_idx]} - ${__mod_desc[$md_idx]}\nFrom binary or source?" 12 60 10 b Binary s Source 2>&1 >/dev/tty)
            else
                choice=s
            fi
            clear
            __ERRMSGS=()
            __INFMSGS=()
            {
                case $choice in
                    b)
                        rp_callModule "$md_idx" depends && rp_callModule "$md_idx" install_bin && rp_callModule "$md_idx" configure
                        ;;
                    s)
                        rp_callModule "$md_idx"
                        ;;
                esac
            } &> >(tee >(gzip --stdout > "$logfilename"))
            rps_printInfo $logfilename
        else
            break
        fi
    done
}

function rps_main_reboot()
{
    clear
    reboot
}
