#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dxx-rebirth"
rp_module_desc="DXX-Rebirth (Descent & Descent 2) build from source"
rp_module_licence="NONCOM https://raw.githubusercontent.com/dxx-rebirth/dxx-rebirth/master/COPYING.txt"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function depends_dxx-rebirth() {
    local depends=(libphysfs1 libphysfs-dev libsdl1.2-dev libsdl-mixer1.2-dev scons)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_dxx-rebirth() {
    gitPullOrClone "$md_build" https://github.com/dxx-rebirth/dxx-rebirth "master"
}

function build_dxx-rebirth() {
    local params=()
    isPlatform "rpi" && params+=(raspberrypi=1)
    scons -c
    scons "${params[@]}"
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

function game_data_dxx-rebirth() {
    local D1X_SHARE_URL='http://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
    local D2X_SHARE_URL='http://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
    local D1X_HIGH_TEXTURE_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
    local D1X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
    local D2X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'

    cd "$__tmpdir"

    # Download / unpack / install Descent shareware files
    if [[ ! -f "$romdir/ports/descent1/descent.hog" ]]; then
        downloadAndExtract "$D1X_SHARE_URL" "$romdir/ports/descent1"
    fi

    # High Res Texture Pack
    if [[ ! -f "$romdir/ports/descent1/d1xr-hires.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent1" "$D1X_HIGH_TEXTURE_URL"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$romdir/ports/descent1/d1xr-sc55-music.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent1" "$D1X_OGG_URL"
    fi

    # Download / unpack / install Descent 2 shareware files
    if [[ ! -f "$romdir/ports/descent2/D2DEMO.HOG" ]]; then
        downloadAndExtract "$D2X_SHARE_URL" "$romdir/ports/descent2"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$romdir/ports/descent2/d2xr-sc55-music.dxa" ]]; then
        wget -nv -P "$romdir/ports/descent2" "$D2X_OGG_URL"
    fi

    chown -R $user:$user "$romdir/ports/descent1" "$romdir/ports/descent2"
}

function configure_dxx-rebirth() {
    local ver
    local name="Descent Rebirth"
    for ver in 1 2; do
        mkRomDir "ports/descent${ver}"
        [[ "$ver" -eq 2 ]] && name="Descent 2 Rebirth"
        addPort "$md_id" "descent${ver}" "$name" "$md_inst/d${ver}x-rebirth -hogdir $romdir/ports/descent${ver}"

        # copy any existing configs from ~/.d1x-rebirth and symlink the config folder to $md_conf_root/descent1/
        moveConfigDir "$home/.d${ver}x-rebirth" "$md_conf_root/descent${ver}/"
    done

    [[ "$md_mode" == "install" ]] && game_data_dxx-rebirth
}
