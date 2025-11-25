#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retropiemenu"
rp_module_desc="RetroPie configuration menu for EmulationStation"
rp_module_section="core"
rp_module_flags="nonet"

function _update_hook_retropiemenu() {
    # to show as installed when upgrading to retropie-setup 4.x
    if ! rp_isInstalled "$md_id" && [[ -f "$home/.emulationstation/gamelists/retropie/gamelist.xml" ]]; then
        mkdir -p "$md_inst"
        # to stop older scripts removing when launching from retropie menu in ES due to not using exec or exiting after running retropie-setup from this module
        touch "$md_inst/.retropie"
    fi
}

function depends_retropiemenu() {
    getDepends mc p7zip
}

function install_bin_retropiemenu() {
    return
}

function configure_retropiemenu()
{
    [[ "$md_mode" == "remove" ]] && return

    local rpdir="$home/RetroPie/retropiemenu"
    mkdir -p "$rpdir"
    cp -Rv "$md_data/icons" "$rpdir/"
    chown -R "$__user":"$__group" "$rpdir"

    isPlatform "rpi" && rm -f "$rpdir/dispmanx.rp"

    # add the gameslist / icons
    local files=(
        'audiosettings'
        'bluetooth'
        'configedit'
        'esthemes'
        'filemanager'
        'raspiconfig'
        'diagnostics'
        'retroarch'
        'retronetplay'
        'rpsetup'
        'runcommand'
        'showip'
        'splashscreen'
        'wifi'
    )

    local names=(
        'Audio'
        'Bluetooth'
        'Configuration Editor'
        'ES Themes'
        'File Manager'
        'Raspi-Config'
        'Collect Diagnostic Info'
        'Retroarch'
        'RetroArch Net Play'
        'RetroPie Setup'
        'Run Command Configuration'
        'Show IP'
        'Splash Screens'
        'WiFi'
    )

    local descs=(
        'Configure audio settings. Choose default of auto, 3.5mm jack, or HDMI. Mixer controls, and apply default settings.'
        'Register and connect to Bluetooth devices. Unregister and remove devices, and display registered and connected devices.'
        'Change common RetroArch options, and manually edit RetroArch configs, global configs, and non-RetroArch configs.'
        'Install, uninstall, or update EmulationStation themes. Most themes can be previewed at https://retropie.org.uk/docs/Themes/.'
        'Basic ASCII file manager for Linux allowing you to browse, copy, delete, and move files.'
        'Change user password, boot options, internationalization, camera, add your Pi to Rastrack, overclock, overscan, memory split, SSH and more.'
        'Collects diagnostic info from the system to help diagnose problems. Information can be automatically uploaded to RetroPie support servers.'
        'Launches the RetroArch GUI so you can change RetroArch options. Note: Changes will not be saved unless you have enabled the "Save Configuration On Exit" option.'
        'Set up RetroArch Netplay options, choose host or client, port, host IP, delay frames, and your nickname.'
        'Install RetroPie from binary or source, install experimental packages, additional drivers, edit Samba shares, custom scraper, as well as other RetroPie-related configurations.'
        'Change what appears on the runcommand screen. Enable or disable the menu, enable or disable box art, and change CPU configuration.'
        'Displays your current IP address, as well as other information provided by the command "ip addr show."'
        'Enable or disable the splashscreen on RetroPie boot. Choose a splashscreen, download new splashscreens, and return splashscreen to default.'
        'Connect to or disconnect from a WiFi network and configure WiFi settings.'
    )

    # 'legacy' joy2key uses direct tty I/O and needs the extra redirection arguments
    iniConfig " = " '"' "$configdir/all/runcommand.cfg"
    iniGet "legacy_joy2key"
    local tty_args
    [[ "$ini_value" == "1" ]] && tty_args=" </dev/tty >/dev/tty"
    setESSystem "RetroPie" "retropie" "$rpdir" ".rp .sh" "sudo $scriptdir/retropie_packages.sh retropiemenu launch %ROM% $tty_args" "" "retropie"

    local file
    local name
    local desc
    local image
    local i
    for i in "${!files[@]}"; do
        case "${files[i]}" in
            audiosettings|raspiconfig|splashscreen)
                ! isPlatform "rpi" && continue
                ;;
            wifi)
                [[ "$__os_id" != "Raspbian" ]] && continue
        esac

        file="${files[i]}"
        name="${names[i]}"
        desc="${descs[i]}"
        image="$home/RetroPie/retropiemenu/icons/${files[i]}.png"

        touch "$rpdir/$file.rp"

        local function
        for function in $(compgen -A function _add_rom_); do
            "$function" "retropie" "RetroPie" "$file.rp" "$name" "$desc" "$image"
        done
    done
}

function remove_retropiemenu() {
    rm -rf "$home/RetroPie/retropiemenu"
    rm -rf "$home/.emulationstation/gamelists/retropie"
    delSystem retropie
}

function launch_retropiemenu() {
    clear
    local command="$1"
    local basename="${command##*/}"
    local no_ext="${basename%.rp}"
    joy2keyStart
    case "$basename" in
        retroarch.rp)
            joy2keyStop
            cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
            chown "$__user":"$__group" "$configdir/all/retroarch.cfg.bak"
            su "$__user" -c "XDG_RUNTIME_DIR=/run/user/$SUDO_UID \"$emudir/retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
            iniConfig " = " '"' "$configdir/all/retroarch.cfg"
            iniSet "config_save_on_exit" "false"
            ;;
        rpsetup.rp)
            rp_callModule setup gui
            ;;
        raspiconfig.rp)
            raspi-config
            ;;
        filemanager.rp)
            mc
            ;;
        showip.rp)
            local ip="$(getIPAddress)"
            printMsgs "dialog" "Your IP is: ${ip:-(unknown)}\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
            ;;
        *.rp)
            rp_callModule $no_ext depends
            if fnExists gui_$no_ext; then
                rp_callModule $no_ext gui
            else
                rp_callModule $no_ext configure
            fi
            ;;
        *.sh)
            cd "$home/RetroPie/retropiemenu"
            sudo -u "$__user" bash "$command"
            ;;
    esac
    joy2keyStop
    clear
}
