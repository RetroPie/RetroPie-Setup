#!/usr/bin/env bash

# This file is part of the microplay-hub
# Designs by Liontek1985
# for RetroPie and offshoot
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
# tekcommandscript v1.2 - 2023-02-20

rp_module_id="tekcommand"
rp_module_desc="Runcommand Launchscreens"
rp_module_repo="git https://github.com/Liontek1985/tekcommand.git master"
rp_module_section="main"
rp_module_flags="noinstclean"

function depends_tekcommand() {
    local depends=(cmake)
     getDepends "${depends[@]}"
}


function sources_tekcommand() {
    if [[ -d "$md_inst" ]]; then
        git -C "$md_inst" reset --hard  # ensure that no local changes exist
    fi
    gitPullOrClone "$md_inst"
}

function install_tekcommand() {
    local teksetup="$scriptdir/scriptmodules/supplementary"
	
    cd "$md_inst"

	cp -rvf "configs" "$rootdir"	
    chown -R $user:$user "$rootdir/configs"
	
#	cp -r -u "tekcommand.sh" "$teksetup/tekcommand.sh"
    chown -R $user:$user "$teksetup/tekcommand.sh"
	chmod 755 "$teksetup/tekcommand.sh"
	rm -r "tekcommand.sh"

    if [[ ! -f "$configdir/all/$md_id.cfg" ]]; then
        iniConfig "=" '"' "$configdir/all/$md_id.cfg"
        iniSet "TEKSTATUS" "active"		
    fi
    chown $user:$user "$configdir/all/$md_id.cfg"
	chmod 755 "$configdir/all/$md_id.cfg"
	
}


function remove_tekcommand() {

	rm -rf "$md_inst"
	cd "$rootdir/configs"
	find . -name "*launching.png" | sed -e "p;s/g.png/g.bkpng/" | xargs -n2 mv
	find . -name "*launching.bkpng" -exec rm {} \;
    rm-r "$configdir/all/$md_id.cfg"
}


function configtek_tekcommand() {
	chown $user:$user "$configdir/all/$md_id.cfg"	
    iniConfig "=" '"' "$configdir/all/$md_id.cfg"	
}

function changestatus_tekcommand() {
    options=(
        ON "Activate Tekcommand Launchimages"
        OF "Deactivate Tekcommand Launchimages"
		XX "[current setting: $tekstatus]"
    )
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case "$choice" in
        ON)
            iniSet "TEKSTATUS" "active"
            cd "$rootdir/configs"
			find . -name "*launching.bkpng" | sed -e "p;s/g.bkpng/g.png/" | xargs -n2 mv
			printMsgs "dialog" "Tekcommand turn on."
            ;;
        OF)
            iniSet "TEKSTATUS" "non-active"
            cd "$rootdir/configs"
			find . -name "*launching.png" | sed -e "p;s/g.png/g.bkpng/" | xargs -n2 mv
			printMsgs "dialog" "Tekcommand turn off."
            ;;
    esac
}

function gui_tekcommand() {

    local cmd=(dialog --default-item "$default" --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
	
        iniConfig "=" '"' "$configdir/all/$md_id.cfg"
		
        iniGet "TEKSTATUS"
        local tekstatus=${ini_value}
	
    local options=(
    )
        options+=(	
            T "Tekcommand Launchimages (Switch On/Off)"
            X "[Status: $tekstatus]"
            TEK "### Script by Liontek1985 ###"
        )
		
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		
        iniConfig "=" '"' "$configdir/all/$md_id.cfg"
		
        iniGet "TEKSTATUS"
        local tekstatus=${ini_value}
		
    if [[ -n "$choice" ]]; then
        case "$choice" in
            T)
				configtek_tekcommand
				changestatus_tekcommand
                ;;
            X)
				configtek_tekcommand
				changestatus_tekcommand
                ;;				
        esac
    fi
}
