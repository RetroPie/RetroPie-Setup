#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="runcommand"
rp_module_desc="Configure the 'runcommand' - Launch script"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_runcommand() {
    getDepends python
}

function install_runcommand() {
	cp -dpR "$scriptdir/scriptmodules/$md_type/$md_id/*" "$md_inst"
    chmod a+x "$md_inst/runcommand.sh"
    chmod a+x "$md_inst/console-config.sh"
    chmod a+x "$md_inst/joy2key.py"
    ln -s "$md_inst/console-config.sh" "/usr/bin/console-config"
}

function configure_runcommand() {
    mkUserDir "$configdir/all"

    cmd=(dialog --backtitle "$__backtitle" --menu "Configure CPU Governor on command launch" 22 86 16)
    local governors
    local governor
    local options=("1" "Default (don't change)")
    local i=2
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]]; then
        for governor in $(</sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors); do
            governors[$i]="$governor"
            options+=("$i" "Force $governor")
            ((i++))
        done
    fi
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        iniConfig "=" '"' "$configdir/all/runcommand.cfg"
        governor="${governors[$choices]}"
        iniSet "governor" "$governor"
        chown $user:$user "$configdir/all/runcommand.cfg"
    fi
}
