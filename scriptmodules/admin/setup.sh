#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="setup"
rp_module_desc="GUI based setup for RetroPie"
rp_module_menus=""
rp_module_flags="nobin"

function rps_logInit() {
    if [[ ! -d "$__logdir" ]]; then
        if mkdir -p "$__logdir"; then
            chown $user:$user "$__logdir"
        else
            fatalError "Couldn't make directory $__logdir"
        fi
    fi
    local now=$(date +'%Y-%m-%d_%H%M%S')
    logfilename="$__logdir/rps_$now.log.gz"
    touch "$logfilename"
    chown $user:$user "$logfilename"
    time_start=$(date +"%s")
}

function rps_logStart() {
    echo "Log started at: $(date -d @$time_start)"
}

function rps_logEnd() {
    time_end=$(date +"%s")
    echo
    echo "Log ended at: $(date -d @$time_end)"
    date_total=$((time_end-time_start))
    local hours=$((date_total / 60 / 60 % 24))
    local mins=$((date_total / 60 % 60))
    local secs=$((date_total % 60))
    echo "Total running time: $hours hours, $mins mins, $secs secs"
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
            if [[ "${menu:0:1}" == "$1" ]]; then
                command[$id]="${menu:2}"
                if [[ "$1" == "3" ]]; then
                    options=("${options[@]}" "$id" "${__mod_desc[$id]}")
                else
                    options=("${options[@]}" "$id" "${__mod_id[$id]} - ${__mod_desc[$id]}")
                fi
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

    if [[ "$__avail" -lt "$__required" ]]; then
        dialog --yesno "Minimum recommended disk space ($required_MB MB) not available.\n\nTry 'raspi-config' to resize partition to full size. Only $available_MB MB available at $rootdir.\n\nContinue anyway?" 22 76 2>&1 >/dev/tty || exit 0
    fi
}

function depends_setup() {
    rps_availFreeDiskSpace 500000
    if [[ "$__raspbian_ver" -eq 7 ]]; then
        printMsgs "dialog" "Raspbian Wheezy is no longer supported. Binaries are no longer updated and new emulators may fail to build, install or run.\n\nPlease backup your system and start from the latest image."
    fi
}

# download, extract, and install binaries
function binaries_setup()
{
    local idx

    clear
    printHeading "Binaries-based installation"

    ensureRootdirExists
    local logfilename
    rps_logInit
    {
        rps_logStart
        rp_callModule raspbiantools apt_upgrade
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
                rp_callModule $idx configure
            fi
        done

        # modules that have another binary distribution method (deb etc)
        rp_callModule stella
        rp_callModule frotz
        rp_callModule rpix86

        # required supplementary modules 
        rp_callModule raspbiantools enable_modules
        rp_callModule esthemes install_theme carbon HerbFargus
        rp_callModule runcommand install

        # some additional supplementary modules
        rp_callModule retropiemenu

        rps_logEnd
    } &> >(tee >(gzip --stdout > "$logfilename"))

    rps_printInfo "$logfilename"

    printMsgs "dialog" "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!"
}

function updatescript_setup()
{
    chown -R $user:$user "$scriptdir"
    printHeading "Fetching latest version of the RetroPie Setup Script."
    pushd "$scriptdir" >/dev/null
    if [[ ! -d ".git" ]]; then
        printMsgs "dialog" "Cannot find directory '.git'. Please clone the RetroPie Setup script via 'git clone https://github.com/RetroPie/RetroPie-Setup.git'"
        popd
        return
    fi
    local error
    if ! error=$(su $user -c "git pull 2>&1 >/dev/null"); then
        printMsgs "dialog" "Update failed:\n\n$error"
        popd
        return
    fi
    popd >/dev/null
    "$scriptdir/retropie_packages.sh" runcommand install
    printMsgs "dialog" "Fetched the latest version of the RetroPie Setup script."
    exec "$scriptdir/retropie_setup.sh"
}

function source_setup()
{
    rps_buildMenu 2 "bool"
    cmd=(dialog --separate-output --backtitle "$__backtitle" --checklist "Select options with 'space' and arrow keys. The default selection installs a complete set of packages and configures basic settings." 22 76 16)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    if [[ -n "$choices" ]]; then
        local logfilename
        rps_logInit
        choices=($choices)
        total=${#choices[@]}
        count=1
        {
            rps_logStart
            for choice in ${choices[@]}
            do
                rp_callModule $choice ${command[$choice]}
                printHeading "Module $count of $total processed."
                ((count++))
            done
            rp_callModule runcommand install
            rps_logEnd
        } &> >(tee >(gzip --stdout > "$logfilename"))

        rps_printInfo "$logfilename"

        printMsgs "dialog" "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!"
    fi
}

function supplementary_setup()
{
    local logfilename
    rps_logInit
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose task." 22 76 16)
        rps_buildMenu 3
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            {
                rps_logStart
                rp_callModule $choices ${command[$choices]}
                rps_logEnd
            } &> >(tee >(gzip --stdout >$logfilename))
        else
            break
        fi
    done

    rps_printInfo "$logfilename"
}

function experimental_setup()
{
    local logfilename
    while true; do
        rps_logInit
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose task." 22 76 16)
        rps_buildMenu 4
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            {
                rps_logStart
                rp_callModule $choices ${command[$choices]}
                rps_logEnd
            } &> >(tee >(gzip --stdout >$logfilename))
        else
            break
        fi
    done

    rps_printInfo "$logfilename"
}

function individual_setup()
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
            rps_logInit
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
                rps_logStart
                case $choice in
                    b)
                        rp_callModule "$md_idx" depends && rp_callModule "$md_idx" install_bin && rp_callModule "$md_idx" configure
                        ;;
                    s)
                        rp_callModule "$md_idx"
                        ;;
                esac
                rp_callModule runcommand install
                rps_logEnd
            } &> >(tee >(gzip --stdout > "$logfilename"))

            rps_printInfo "$logfilename"
        else
            break
        fi
    done
}

function uninstall_setup()
{
    dialog --defaultno --yesno "Are you sure you want to uninstall RetroPie?" 22 76 2>&1 >/dev/tty || return 0
    printMsgs "dialog" "This feature is new, and you still may need to remove some files manually, such as symlinks for some emulators created in $home"
    dialog --defaultno --yesno "Are you REALLY sure you want to uninstall RetroPie?\n\n$rootdir and $datadir will be removed - this includes your RetroPie configurations and ROMs." 22 76 2>&1 >/dev/tty || return 0
    clear
    printHeading "Uninstalling RetroPie"
    for idx in "${__mod_idx[@]}"; do
        rp_callModule $idx remove
    done
    rm -rfv "/opt/retropie"
    rm -rfv "$home/RetroPie"
    if dialog --defaultno --yesno "Do you want to remove all the system packages that RetroPie depends on? \n\nWARNING: this will remove packages like SDL even if they were installed before you installed RetroPie - it will also remove any package configurations - such as those in /etc/samba for Samba.\n\nIf unsure choose No (selected by default)." 22 76 2>&1 >/dev/tty; then
        clear
        # remove all dependencies
        for idx in "${__mod_idx[@]}"; do
            rp_callModule $idx depends remove
        done
    fi
    exit 0
}

function reboot_setup()
{
    clear
    reboot
}

# retropie-setup main menu
function configure_setup() {
    while true; do
        pushd "$scriptdir" >/dev/null
        local ver=$(git describe --abbrev=0 --tags --first-parent)
        local commit=$(git log -1 --pretty=format:"%cr (%h)")
        popd >/dev/null
        __ERRMSGS=()
        __INFMSGS=()

        cmd=(dialog --backtitle "$__backtitle" --title "Choose an option" --menu "Script Version: $ver\nLast Commit: $commit" 22 76 16)
        options=()
        if [[ $__has_binaries -eq 1 ]]; then
            options+=(
            1 "Binary-based installation (recommended)")
        fi
        options+=(
            2 "Source-based installation (bleeding edge - 24h+ build time on rpi1)"
            3 "Setup / Configuration (to be used post install)"
            4 "Experimental packages (these are potentially unstable)"
        )
        if [[ $__has_binaries -eq 1 ]]; then
            options+=(
                5 "Install individual emulators from binary or source"
            )
        else
            options+=(5 "Install individual emulators from source")
        fi
        options+=(
            6 "Uninstall RetroPie"
            U "Update RetroPie-Setup script"
            R "Perform Reboot"
        )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            clear
            case $choices in
                1) binaries_setup ;;
                2)
                    printMsgs "dialog" "Please note - Building from source will pull in the very latest releases of many of the emulators. Building could fail or resulting binaries could not work. Only choose this option if you are comfortable in working with the linux console and debugging any issues. The binary option is recommended for most users, as it provides mostly up to date - but more importantly - tested versions of the emulators.\n\nYou can also install from binary and then update any emulators individually later from option 5 on the main menu."
                    source_setup ;;
                3) supplementary_setup ;;
                4) experimental_setup ;;
                5) individual_setup ;;
                6) uninstall_setup;;
                U) updatescript_setup ;;
                R) reboot_setup ;;
            esac
        else
            break
        fi
    done
    clear
}
