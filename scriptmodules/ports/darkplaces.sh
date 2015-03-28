#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="darkplaces"
rp_module_desc="Darkplaces Quake"
rp_module_menus="4+"

function depends_darkplaces() {
    getDepends lhasa libtxc-dxtn-s2tc0
}

function sources_darkplaces() {
    gitPullOrClone "$md_build" git://github.com/autonomous1/darkplacesrpi.git
}

function install_darkplaces() {
    dpkg -i darkplaces-rpi.deb
    rm darkplaces-rpi.deb
}

function configure_darkplaces() {
    mkRomDir "ports/quake"

    if [[ ! -f "$romdir/ports/quake/id1/pak0.pak" ]]; then
        # download / unpack / install quake shareware files
        wget "http://downloads.petrockblock.com/retropiearchives/quake106.zip" -O quake106.zip
        unzip -o quake106.zip -d "quake106"
        rm quake106.zip
        pushd quake106
        lhasa ef resource.1
        cp -rf id1 "$romdir/ports/quake/"
        popd
        rm -rf quake106
        chown -R $user:$user "$romdir/ports/quake"
    fi

    ensureSystemretroconfig "quake"

    # Create startup script
    cat > "$romdir/ports/Darkplaces Quake.sh" << _EOF_
#!/bin/bash
darkplaces-sdl -basedir "$romdir/ports/quake" -quake
_EOF_
    
    # Set startup script permissions
    chmod u+x "$romdir/ports/Darkplaces Quake.sh"
    chown $user:$user "$romdir/ports/Darkplaces Quake.sh"
    
    # Add darkplaces quake to emulationstation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
