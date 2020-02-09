#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retro-stats"
rp_module_desc="Stats module for RetroPie"
rp_module_help="Webservice for the RetroPie system, go to <your-rpi-ip>:8080 to view your current stats"
rp_module_section="exp"

function depends_retro-stats() {
    getDepends python3-pip
}

function sources_retro-stats() {
    gitPullOrClone "$md_inst" "https://github.com/langest/RetroStats.git"
}

function build_retro-stats() {
    pip3 install "$md_inst"
}

function remove_retro-stats() {
    pip3 uninstall RetroStats -y
    sed -i "/# retro-stats logging/d" "${configdir}/all/runcommand-onstart.sh"
    sed -i "/# retro-stats logging/d" "${configdir}/all/runcommand-onend.sh"
    crontab -l | sed -e '/@reboot retro-stats-server &/d' | crontab -
}

function configure_retro-stats() {
    if [[ "$md_mode" == "remove" ]]; then
        return
    fi
    cat "${md_inst}/runcommand_hooks/runcommand-onstart.sh" | sed -e "s/$/ # retro-stats logging/" >> "${configdir}/all/runcommand-onstart.sh"
    cat "${md_inst}/runcommand_hooks/runcommand-onend.sh" | sed -e "s/$/ # retro-stats logging/" >> "${configdir}/all/runcommand-onend.sh"
    (crontab -l ; echo "@reboot retro-stats-server &") | crontab -
}
