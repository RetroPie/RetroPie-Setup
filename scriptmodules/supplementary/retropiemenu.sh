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
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_retropiemenu() {
    getDepends mc
}

function configure_retropiemenu()
{
    local rpdir="$home/RetroPie/retropiemenu"
    mkdir -p "$rpdir"

    files=(
        'rpsetup.rp'
        'configedit.rp'
        'retroarch.rp'
        'retronetplay.rp'
        'filemanager.rp'
        'showip.rp'
        'wifi.rp'
        'runcommand.rp'
        'bluetooth.rp'
        'esthemes.rp'
    )

    if isPlatform "rpi"; then
        files+=(
            'raspiconfig.rp'
            'audiosettings.rp'
            'splashscreen.rp'
        )
        # remove the dispmanx.rp menu entry
        rm -f "$rpdir/dispmanx.rp"
    fi

    for file in "${files[@]}"; do
        touch "$rpdir/$file"
    done

    # add the gameslist / icons
    mkdir -p "$home/.emulationstation/gamelists/retropie/"
    cp -v "$scriptdir/scriptmodules/$md_type/retropiemenu/gamelist.xml" "$home/.emulationstation/gamelists/retropie/gamelist.xml"
    cp -Rv "$scriptdir/scriptmodules/$md_type/retropiemenu/icons" "$rpdir/"

    chown -R $user:$user "$rpdir"
    chown -RL $user:$user "$home/.emulationstation"

    setESSystem "RetroPie" "retropie" "~/RetroPie/retropiemenu" ".rp .sh" "sudo $scriptdir/retropie_packages.sh retropiemenu launch %ROM% </dev/tty >/dev/tty" "" "retropie"
}

function launch_retropiemenu() {
    clear
    local command="$1"
    local basename="${command##*/}"
    local no_ext=${basename%.rp}
    case $basename in
        retroarch.rp)
            cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
            chown $user:$user "$configdir/all/retroarch.cfg.bak"
            su $user -c "\"$emudir/retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
            ;;
        rpsetup.rp)
            "$scriptdir/retropie_setup.sh"
            ;;
        raspiconfig.rp)
            raspi-config
            ;;
        filemanager.rp)
            mc
            ;;
        showip.rp)
            local ip="$(ip route get 8.8.8.8 2>/dev/null | head -1 | cut -d' ' -f8)"
            printMsgs "dialog" "Your IP is: $ip\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
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
            bash "$command"
            ;;
    esac
    clear
}
