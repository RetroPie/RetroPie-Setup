#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="spacecadet3dpinball"
rp_module_desc="Space Cadet 3D Pinball"
rp_module_help=""
rp_module_licence="https://archive.org/details/pinballxp"
rp_module_section="exp"
rp_module_flags="rpi4 x86"

function depends_spacecadet3dpinball() {
    local dep_idx="$(rp_getIdxFromId "wine")"
    if [ "$dep_idx" == "" ] || ! rp_isInstalled "$dep_idx" ; then
        md_ret_errors+=("Sorry, you need to install the wine scriptmodule")
        return 1
    fi
}

function install_bin_spacecadet3dpinball() {
    #
    # Download and extract Space Cadet 3D Pinball ZIP file to Program Files.
    #
    mkdir -p /home/pi/.wine/drive_c/Program\ Files/SpaceCadet3DPinball/

    wget -nv -O "$__tmpdir/PinballXP.zip" https://archive.org/download/pinballxp/PinballXP.zip
    pushd /home/pi/.wine/drive_c/Program\ Files/SpaceCadet3DPinball/
    unzip "$__tmpdir/PinballXP.zip"
    popd
    
    chown -R pi:pi /home/pi/.wine/drive_c/Program\ Files/SpaceCadet3DPinball/
}

function configure_spacecadet3dpinball() {
    local system="spacecadet3dpinball"
    local spacecadet3dpinball="$md_inst/spacecadet3dpinball_xinit.sh"

    #
    # Add Space Cadet 3D Pinball entry to Ports in Emulation Station
    #
    cat > "$spacecadet3dpinball" << _EOFSP_
#!/bin/bash
xset -dpms s off s noblank
cd "/home/pi/.wine/drive_c/Program Files/SpaceCadet3DPinball/"
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" setarch linux32 -L /opt/retropie/ports/wine/bin/wine '/home/pi/.wine/drive_c/Program Files/SpaceCadet3DPinball/pinball.exe' -fullscreen
_EOFSP_
        chmod +x "$spacecadet3dpinball"

    addPort "$md_id" "spacecadet3dpinball" "Space Cadet 3D Pinball (WindowsXP)" "XINIT:$spacecadet3dpinball"
}
