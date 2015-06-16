#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dxx-rebirth"
rp_module_desc="DXX-Rebirth (Descent & Descent 2) build from source"
rp_module_menus="4+"

D1X_SHARE_URL='http://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
D2X_SHARE_URL='http://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
D1X_HIGH_TEXTURE_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
D1X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
D2X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'

function depends_dxx-rebirth() {
    getDepends libphysfs1 libphysfs-dev libsdl1.2-dev libsdl-mixer1.2-dev scons
    if [ "$CXX" = "g++" ]; then sudo apt-get install -qq g++-4.8; fi
    if [ "$CXX" = "g++" ]; then export CXX="g++-4.8" CC="gcc-4.8"; fi
}

function sources_dxx-rebirth() {
    gitPullOrClone "$md_build" https://github.com/dxx-rebirth/dxx-rebirth "unification/master"
}

function build_dxx-rebirth() {
    scons -c
    scons raspberrypi=1 debug=1
    
    md_ret_require=(
        "$md_build/d1x-rebirth/d1x-rebirth"
        "$md_build/d2x-rebirth/d2x-rebirth"
    )
}

function install_dxx-rebirth() {
    # Rename generic files
    mv -f "$md_build/d1x-rebirth/INSTALL.txt" "$md_build/d1x-rebirth/D1X-INSTALL.txt"
    mv -f "$md_build/d1x-rebirth/README.txt" "$md_build/d1x-rebirth/D1X-README.txt"
    mv -f "$md_build/d1x-rebirth/RELEASE-NOTES.txt" "$md_build/d1x-rebirth/D1X-RELEASE-NOTES.txt"
    mv -f "$md_build/d2x-rebirth/INSTALL.txt" "$md_build/d2x-rebirth/D2X-INSTALL.txt"
    mv -f "$md_build/d2x-rebirth/README.txt" "$md_build/d2x-rebirth/D2X-README.txt"
    mv -f "$md_build/d2x-rebirth/RELEASE-NOTES.txt" "$md_build/d2x-rebirth/D2X-RELEASE-NOTES.txt"

    md_ret_files=(
        'COPYING.txt'
        'GPL-3.txt'
        'd1x-rebirth/README.RPi'
        'd1x-rebirth/d1x-rebirth'
        'd1x-rebirth/d1x.ini'
        'd1x-rebirth/D1X-INSTALL.txt'
        'd1x-rebirth/D1X-README.txt'
        'd1x-rebirth/D1X-RELEASE-NOTES.txt'
        'd2x-rebirth/d2x-rebirth'
        'd2x-rebirth/d2x.ini'
        'd2x-rebirth/D2X-INSTALL.txt'
        'd2x-rebirth/D2X-README.txt'
        'd2x-rebirth/D2X-RELEASE-NOTES.txt'
    )
}

function configure_dxx-rebirth() {
    # Descent 1
    mkRomDir "ports/descent1"
    mkUserDir "$configdir/descent1"
    
    # copy any existing configs from ~/.d1x-rebirth and symlink the config folder to $configdir/descent1/
    if [[ -d "$home/.d1x-rebirth" && ! -h "$home/.d1x-rebirth" ]]; then
        mv -v "$home/.d1x-rebirth/"* "$configdir/descent1/"
        rm -rf "$home/.d1x-rebirth"
    fi
    
    ln -snf "$configdir/descent1" "$home/.d1x-rebirth"
    
    # Download / unpack / install Descent shareware files
    if [[ ! -f "$romdir/ports/descent1/descent.hog" ]]; then
        wget -nv "$D1X_SHARE_URL"
        unzip -o descent-pc-shareware.zip -d "$romdir/ports/descent1"
        rm descent-pc-shareware.zip
    fi

    # High Res Texture Pack
    if [[ ! -f "$romdir/ports/descent1/d1xr-hires.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent1" "$D1X_HIGH_TEXTURE_URL"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$romdir/ports/descent1/d1xr-sc55-music.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent1" "$D1X_OGG_URL"
    fi

    chown -R $user:$user "$romdir/ports/descent1"

    # Create startup script
    cat > "$romdir/ports/Descent Rebirth.sh" << _EOF_
#!/bin/bash
$md_inst/d1x-rebirth -hogdir $romdir/ports/descent1
_EOF_
    
    # Set startup script permissions
    chmod u+x "$romdir/ports/Descent Rebirth.sh"
    chown $user:$user "$romdir/ports/Descent Rebirth.sh"
    
    # Descent 2
    mkRomDir "ports/descent2"
    mkUserDir "$configdir/descent2"
    
    # copy any existing configs from ~/.d2x-rebirth and symlink the config folder to $configdir/descent2/
    if [[ -d "$home/.d2x-rebirth" && ! -h "$home/.d2x-rebirth" ]]; then
        mv -v "$home/.d2x-rebirth/"* "$configdir/descent2/"
        rm -rf "$home/.d2x-rebirth"
    fi
    
    ln -snf "$configdir/descent2" "$home/.d2x-rebirth"
    
    # Download / unpack / install Descent 2 shareware files
    if [[ ! -f "$romdir/ports/descent2/D2DEMO.HOG" ]]; then
        wget -nv "$D2X_SHARE_URL"
        unzip -o descent2-pc-demo.zip -d "$romdir/ports/descent2"
        rm descent2-pc-demo.zip
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$romdir/ports/descent2/d2xr-sc55-music.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent2" "$D2X_OGG_URL"
    fi

    chown -R $user:$user "$romdir/ports/descent2"

    # Create startup script
    cat > "$romdir/ports/Descent 2 Rebirth.sh" << _EOF_
#!/bin/bash
$md_inst/d2x-rebirth -hogdir $romdir/ports/descent2
_EOF_

    # Set startup script permissions
    chmod u+x "$romdir/ports/Descent 2 Rebirth.sh"
    chown $user:$user "$romdir/ports/Descent 2 Rebirth.sh"
    
    # Add descent1 to emulationstation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}