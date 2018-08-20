#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="skyscraper"
rp_module_desc="Scraper for multiple frontends by Lars Muldjord"
rp_module_help="IMPORTANT! In order for Skyscraper to work properly you need to exit your frontend. For EmulationStation you can do so by pressing F4.\nTo run Skyscraper in Simple Mode, exit your frontend and simply type 'Skyscraper' and press enter. Then answer the questions you are given and let Skyscraper do the work.\nIf you want better control check the available options with 'Skyscraper --help'.\n\nBe sure to check the elaborate documentation at github: https://github.com/muldjord/skyscraper"
rp_module_licence="GPL3 https://raw.githubusercontent.com/muldjord/skyscraper/master/LICENSE"
rp_module_section="opt"

skysource="/home/$user/skysource"
skyconfig="/home/$user/.skyscraper"

function depends_skyscraper() {
    local depends=(qt5-default)
}

function sources_skyscraper() {
    if [[ -f "$skysource/Skyscraper" ]]; then
        cd $skysource
	./update_skyscraper.sh
	sleep 5
    else
        mkdir $skysource
        cd $skysource
        curl https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
    fi

    cp Skyscraper $md_build
    chown -R $user:$user "$skysource"
}

function install_skyscraper() {
    md_ret_files=(
        'Skyscraper'
    )
}

function remove_skyscraper() {
    if [[ -f "$skysource/Skyscraper" ]]; then
	cd $skysource
	make uninstall
	rm -Rf $skysource
    fi

    clear

    if [[ -d "$skyconfig" ]]; then
	read -n1 -p "Do you wish to delete the $skyconfig cache and config folder (y/n)? " purgeall
	echo \n
	case $purgeall in  
	    y|Y) echo "Deleting $skyconfig folder..."
		 rm -Rf $skyconfig
		 ;; 
	esac
    fi
}
