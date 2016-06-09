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
rp_module_section=""

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
        printMsgs "dialog" "Please see $1 for more in depth information regarding the errors."
    fi
    printMsgs "dialog" "${__INFMSGS[@]}"
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
    printMsgs "dialog" "Fetched the latest version of the RetroPie Setup script."
}

function package_setup() {
    local idx="$1"
    local md_id="${__mod_id[$idx]}"

    while true; do
        local options=()
        rp_hasBinary "$idx" && options+=(B "Install/Update from binary")

        if fnExists "sources_${md_id}"; then
            options+=(S "Install/Update from source")
        fi

        if rp_isInstalled "$idx"; then
            if fnExists "gui_${md_id}"; then
                options+=(C "Configuration / Options")
            fi
            options+=(X "Remove")
        fi

        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose an option for ${__mod_id[$idx]}" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        local logfilename
        __ERRMSGS=()
        __INFMSGS=()

        case "$choice" in
            B|I)
                rps_logInit
                {
                    rp_installModule "$idx"
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;
            S)
                rps_logInit
                {
                    rp_callModule "$idx"
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;
            C)
                rps_logInit
                {
                    rp_callModule "$idx" gui
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;
            X)
                local text="Are you sure you want to remove $md_id?"
                [[ "${__mod_section[$idx]}" == "core" ]] && text+="\n\nWARNING - core packages are needed for RetroPie to function!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rp_callModule "$idx" remove
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;
            *)
                break
                ;;
        esac

    done
}

function section_gui_setup() {
    local section="$1"

    while true; do
        local options=()

        rp_hasBinaries && options+=(B "Install/Update all ${__sections[$section]} packages from binary" "This will install all $section packages from binary archives (if available). If a binary archive is missing a source install will be performed.")

        options+=(
            S "Install/Update all ${__sections[$section]} packages from source" "This will build and install all the packages from $section from source. Building from source will pull in the very latest releases of many of the emulators. Building could fail or resulting binaries could not work. Only choose this option if you are comfortable in working with the linux console and debugging any issues."
            X "Remove all ${__sections[$section]} packages" "This will remove all $section packages."
        )

        local idx
        for idx in $(rp_getSectionIds $section); do
            if rp_isInstalled "$idx"; then
                installed="(Installed)"
            else
                installed=""
            fi
            options+=("$idx" "${__mod_id[$idx]} $installed" "${__mod_desc[$idx]}")
        done

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --menu "Choose an option" 22 76 16)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            printMsgs "dialog" "${choice[@]:5}"
            continue
        fi

        local logfilename
        __ERRMSGS=()
        __INFMSGS=()
        case "$choice" in
            B)
                dialog --defaultno --yesno "Are you sure you want to install/update all $section packages from binary?" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    for idx in $(rp_getSectionIds $section); do
                        rp_installModule "$idx"
                    done
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;
            S)
                dialog --defaultno --yesno "Are you sure you want to install/update all $section packages from source?" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    for idx in $(rp_getSectionIds $section); do
                        rp_callModule "$idx"
                    done
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;

            X)
                local text="Are you sure you want to remove all $section packages?"
                [[ "$section" == "core" ]] && text+="\n\nWARNING - core packages are needed for RetroPie to function!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    for idx in $(rp_getSectionIds $section); do
                        rp_callModule "$idx" remove
                    done
                } &> >(tee >(gzip --stdout >"$logfilename"))
                rps_printInfo "$logfilename"
                ;;
            *)
                package_setup "$choice"
                ;;
        esac

    done
}

function settings_gui_setup() {
    while true; do
        local options=()
        local idx
        for idx in "${__mod_idx[@]}"; do
            # show all configuration modules and any installed packages with a gui function
            if [[ "${__mod_section[idx]}" == "config" ]] || rp_isInstalled "$idx" && fnExists "gui_${__mod_id[idx]}"; then
                options+=("$idx" "${__mod_id[$idx]}  - ${__mod_desc[$idx]}" "${__mod_desc[$idx]}")
            fi
        done

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --menu "Choose an option" 22 76 16)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            printMsgs "dialog" "${choice[@]:5}"
            continue
        fi

        [[ -z "$choice" ]] && break

        local logfilename
        __ERRMSGS=()
        __INFMSGS=()
        rps_logInit
        {
            if fnExists "gui_${__mod_id[choice]}"; then
                rp_callModule "$choice" gui
            else
                rp_callModule "$choice"
            fi
        } &> >(tee >(gzip --stdout >"$logfilename"))
        rps_printInfo "$logfilename"
    done
}

function update_packages_setup() {
    local idx
    for idx in ${__mod_idx[@]}; do
        if rp_isInstalled "$idx"; then
            rp_installModule "$idx"
        fi
    done
}

function update_packages_gui_setup() {
    local update="$1"
    if [[ "$update" != "update" ]]; then
        dialog --defaultno --yesno "Are you sure you want to update installed packages?" 22 76 2>&1 >/dev/tty || return 1
        if dialog --yesno "It is advisable to update the RetroPie-Setup script before updating packages - may I do this now ?" 22 76 2>&1 >/dev/tty; then
            updatescript_setup
            exec "$scriptdir/retropie_packages.sh" setup update_packages_gui update
        fi
    fi

    local logfilename
    __ERRMSGS=()
    __INFMSGS=()
    rps_logInit
    {
        update_packages_setup
    } &> >(tee >(gzip --stdout >"$logfilename"))

    rps_printInfo "$logfilename"
}

function packages_gui_setup() {
    local section
    local options=()

    for section in core main opt driver exp; do
        options+=($section "Manage ${__sections[$section]} packages")
    done

    options+=(U "Update all installed packages")

    local cmd
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose an option" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            U)
                update_packages_gui_setup
                ;;
            *)
                section_gui_setup "$choice"
                ;;
        esac

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
    rm -rfv "$rootdir"
    rm -rfv "$datadir"
    if dialog --defaultno --yesno "Do you want to remove all the system packages that RetroPie depends on? \n\nWARNING: this will remove packages like SDL even if they were installed before you installed RetroPie - it will also remove any package configurations - such as those in /etc/samba for Samba.\n\nIf unsure choose No (selected by default)." 22 76 2>&1 >/dev/tty; then
        clear
        # remove all dependencies
        for idx in "${__mod_idx[@]}"; do
            rp_callModule "$idx" depends remove
        done
    fi
}

function reboot_setup()
{
    clear
    reboot
}

# retropie-setup main menu
function gui_setup() {
    while true; do
        pushd "$scriptdir" >/dev/null
        local commit=$(git log -1 --pretty=format:"%cr (%h)")
        popd >/dev/null

        cmd=(dialog --backtitle "$__backtitle" --title "Choose an option" --cancel-label "Exit" --item-help --help-button --menu "Script Version: $__version\nLast Commit: $commit" 22 76 16)
        options=(
            P "Manage Packages"
            "Install/Remove and Configure the various components of RetroPie, including emulators, ports, and controller drivers."

            S "Setup / Tools"
            "Configuration Tools and additional setup. Any components of RetroPie that have configuration will also appear here after install."

            X "Uninstall RetroPie"
            "Uninstall RetroPie completely."

            U "Update RetroPie-Setup script"
            "Update this RetroPie-Setup script. Note that RetroPie-Setup is constantly updated - the version numbers were introduced primarily for the pre-made images we provided, but we now display a version in this menu as a guide. If you update the RetroPie-Setup script after downloading a pre-made image, you may get a higher version number or a -dev release. This does not mean the software is unstable, it just means we are working on changes for the next version, when we will create a new image."

            R "Perform Reboot"
            "Reboot your machine."
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            if [[ "${choice[@]:0:4}" == "HELP" ]]; then
                printMsgs "dialog" "${choice[@]:5}"
                continue
            fi
            clear
            case "$choice" in
                P)
                    packages_gui_setup
                    ;;
                S)
                    settings_gui_setup
                    ;;
                X)
                    uninstall_setup
                    ;;
                U)
                    updatescript_setup
                    exec "$scriptdir/retropie_packages.sh" setup gui
                    ;;
                R)
                    reboot_setup
                    ;;
            esac
        else
            break
        fi
    done
    clear
}
