#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="plex"
rp_module_desc="OpenPHT is a community driven fork of Plex Home Theater"
rp_module_section="opt"
rp_module_flags="!arm"

VERSION="1.6.2.123-e23a7eef"
APTVER=$(apt --version | cut -d' ' -f2) 
DISTRO=$(lsb_release -is)
CODENAME=$(lsb_release -cs)
RELEASE=$(lsb_release -rs)
PACKAGE="openpht_${VERSION}-${CODENAME}_amd64.deb"
GETDEB="https://github.com/RasPlex/OpenPHT/releases/download/v${VERSION}/${PACKAGE}"

function install_bin_plex() {
    if [[ "${DISTRO}" == "Debian" && "${RELEASE}" -lt "8" ]]; then
        md_ret_errors+=("The Debian package available is only for Jessie")
        return 1
    else
        wget -nv -O "$__tmpdir/${PACKAGE}" ${GETDEB}
        if [[ $(dpkg --compare-versions "${APTVER}" ge "1.1"; echo $?) -eq 0  ]]; then
            apt install -y --allow-downgrades $__tmpdir/${PACKAGE}
        else
            # I feel dirty
            dpkg -i $__tmpdir/${PACKAGE}
            apt-get -f -y install
        fi
    fi
}

function remove_plex() {
    aptRemove openpht
    rp_callModule plex depends remove
    apt-get autoremove --purge -y
}

function configure_plex() {
    # remove old directLaunch entry
    delSystem "$md_id" "plex"    
    rmDirExists "$romdir/plex"

    addPort "plex" "plex" "Plex" "pasuspender -- env AE_SINK=ALSA openpht"

    if [[ ! -f /etc/udev/rules.d/99-input.rules ]]; then
        echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules
    fi
}

## This method installs Plex as it's own system
#function configure_plex() {
#    if [[ ! -f /etc/udev/rules.d/99-input.rules ]]; then
#        echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules
#    fi
#    mkRomDir "plex"
#    # remove old port entry
#    rmDirExists "$configdir/ports/plex"
#    if [[ -f "$romdir/ports/Plex.sh" ]]; then
#        rm "$romdir/ports/Plex.sh"
#    fi
#    
#
#    cat > "$romdir/plex/Plex.sh" << 'EOF'
#!/bin/bash
#
#LOG_FILE=$HOME/.plexht/temp/plexhometheater.log
#
#rm $LOG_FILE 2> /dev/null
#
#pasuspender -- env AE_SINK=ALSA openpht &
#
#while [[ ! -f $LOG_FILE ]] ; do
#    sleep 1s
#done
#
#while read line ; do
#    if [[ ${line} =~ "application stopped" ]] ; then
#        echo "Killing PHT"
#        break
#    fi
#done < <(tail --pid=$$ -f -n0 $LOG_FILE)
#
#killall openpht
#EOF
#
#    chmod +x "$romdir/plex/Plex.sh"
#
#    setESSystem 'Plex' 'plex' '~/RetroPie/roms/plex' '.sh .SH' '%ROM%' 'plex' 'plex'
#}
