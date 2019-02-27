#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uae4all"
rp_module_desc="Amiga emulator UAE4All"
rp_module_help="ROM Extension: .adf\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/uae4all2/retropie/copying"
rp_module_section="opt"
rp_module_flags="dispmanx !x86 !mali !kms"

function depends_uae4all() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libsdl-ttf2.0-dev
}

function sources_uae4all() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/uae4all2.git retropie
    mkdir guichan
    downloadAndExtract "$__archive_url/guichan-0.8.2.tar.gz" "$md_build/guichan" --strip-components 1
    cd guichan
    # fix from https://github.com/sphaero/guichan
    applyPatch "$md_data/01_guichan.diff"
}

function build_uae4all() {
    pushd guichan
    make clean
    ./configure --enable-sdlimage --enable-sdl --disable-allegro --disable-opengl --disable-shared
    make
    popd
    make -f Makefile.pi clean
    if isPlatform "neon"; then
        make -f Makefile.pi NEON=1 DEFS="-DUSE_ARMV7 -DUSE_ARMNEON"
    else
        make -f Makefile.pi
    fi
    md_ret_require="$md_build/uae4all"
}

function install_uae4all() {
    unzip -o "AndroidData/guichan26032014.zip" -d "$md_inst" "data/*"
    unzip -o "AndroidData/data.zip" -d "$md_inst" "data/*"
    md_ret_files=(
        'copying'
        'uae4all'
        'Readme.txt'
        'AndroidData/aros20140110.zip'
    )
    rm -rf "$md_inst/"{blankdisks,roms,conf,customconf,saves}
}

function configure_uae4all() {
    mkRomDir "amiga"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/$md_id"

    # move config / save folders to $md_conf_root/amiga/$md_id
    local dir
    for dir in blankdisks conf customconf saves screenshots; do
        moveConfigDir "$md_inst/$dir" "$md_conf_root/amiga/$md_id/$dir"
    done

    # symlink rom dir
    moveConfigDir "$md_inst/roms" "$romdir/amiga"

    # and kickstart dir (removing old symlinks first)
    if [[ ! -h "$md_inst/kickstarts" ]]; then
        rm -f "$md_inst/kickstarts/"{kick12.rom,kick13.rom,kick20.rom,kick31.rom}
    fi
    moveConfigDir "$md_inst/kickstarts" "$biosdir"

    rm -f "$romdir/amiga/+Start UAE4All.sh"
    if [[ "$md_mode" == "install" ]]; then
        if [[ ! -f "$biosdir/aros-amiga-m68k-ext.bin" ]]; then
            # unpack aros kickstart
            unzip -j "aros20140110.zip" -d "$biosdir"
        fi

        cat > "$romdir/amiga/+Start UAE4All.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./uae4all
popd
_EOF_
        chmod a+x "$romdir/amiga/+Start UAE4All.sh"
        chown $user:$user "$romdir/amiga/+Start UAE4All.sh"

        setDispmanx "$md_id" 1
    else
        rm -f "$biosdir/aros-amiga-m68k"*
    fi

    addEmulator 1 "$md_id" "amiga" "bash $romdir/amiga/+Start\ UAE4All.sh"
    addSystem "amiga"
}
