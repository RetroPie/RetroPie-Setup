#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wine"
rp_module_desc="WINEHQ - Wine Is Not an Emulator"
rp_module_help="Use your app's Installer or place your x86 Windows binaries into $romdir/wine"
rp_module_licence="LGPL https://wiki.winehq.org/Licensing"
rp_module_section="exp"
rp_module_flags="rpi4"
# TODO: Currently only tested on RPI4 platform. Other RPI platforms should also work.
#       X86 platform requires some modification in the Ports scripts so that the custom Mesa path is removed.

function _latest_ver_wine() {
    echo "6.0~rc5"
}

function _release_type_wine() {
    echo devel
}

function depends_wine() {
    # On RPI systems, we need to make sure Box86 is installed.
    if isPlatform "rpi"; then
        local dep_idx="$(rp_getIdxFromId "box86")"
        if [ "$dep_idx" == "" ] || ! rp_isInstalled "$dep_idx" ; then
            md_ret_errors+=("Sorry, you need to install the Box86 scriptmodule")
            return 1
        fi
    fi
    
    # Timidity is to enable MIDI output from Wine
    getDepends timidity-daemon timidity fluid-soundfont-gm
}

function install_bin_wine() {
    local version="$(_latest_ver_wine)"
    local releaseType="$(_release_type_wine)"
    local baseURL="https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-i386/"

    local workingDir="$__tmpdir/wine-${releaseType}-${version}/"

    mkdir -p ${workingDir}
    pushd ${workingDir}

    for i in wine-${releaseType}-i386 wine-${releaseType}
    do
      local package="${i}_${version}~buster_i386.deb"
      local getdeb="${baseURL}${package}"
      
      wget -nv -O "${workingDir}/$package" $getdeb

      mkdir "$i"
      pushd "$i"
  
      ar x ../${i}_${version}~buster_i386.deb
      tar xvf data.tar.xz

      cp -R opt/wine-${releaseType}/* $md_inst
      popd
    done
    popd
}

function configure_wine() {
    local system="wine"
    
    local winedesktop_xinit="$md_inst/winedesktop_xinit.sh"
    local wineexplorer_xinit="$md_inst/wineexplorer_xinit.sh"
    local winecfg_xinit="$md_inst/winecfg_xinit.sh"
    
    #
    # Create a new Wine prefix directory
    #
    sudo -u pi WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" setarch linux32 -L /opt/retropie/ports/wine/bin/wine winecfg /v win7
    
    #
    # Install Emulation Station scripts for Wine
    #
    cat > "$winedesktop_xinit" << _EOFDESKTOP_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" setarch linux32 -L /opt/retropie/ports/wine/bin/wine explorer /desktop=shell,\`xrandr | grep current | sed 's/.*current //; s/,.*//; s/ //g'\`
_EOFDESKTOP_
        chmod +x "$winedesktop_xinit"

    cat > "$wineexplorer_xinit" << _EOFEXPLORER_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" setarch linux32 -L /opt/retropie/ports/wine/bin/wine explorer /desktop=shell,\`xrandr | grep current | sed 's/.*current //; s/,.*//; s/ //g'\` explorer
_EOFEXPLORER_
        chmod +x "$wineexplorer_xinit"

    cat > "$winecfg_xinit" << _EOFCONFIG_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" setarch linux32 -L /opt/retropie/ports/wine/bin/wine explorer /desktop=shell,\`xrandr | grep current | sed 's/.*current //; s/,.*//; s/ //g'\` winecfg
_EOFCONFIG_
        chmod +x "$winecfg_xinit"

    addPort "$md_id" "winedesktop" "Wine Desktop" "XINIT:$winedesktop_xinit"
    addPort "$md_id" "wineexplorer" "Wine Explorer" "XINIT:$wineexplorer_xinit"
    addPort "$md_id" "winecfg" "Wine Config" "XINIT:$winecfg_xinit"
}
