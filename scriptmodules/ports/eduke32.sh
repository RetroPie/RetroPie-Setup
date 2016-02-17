#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="eduke32"
rp_module_desc="Duke3D Port"
rp_module_menus="2+"
rp_module_flags="dispmanx !mali"

function depends_eduke32() {
    getDepends build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libpng12-dev libvpx-dev libgtk2.0-dev freepats
    # remove old eduke packages
    hasPackage eduke32 && apt-get remove -y eduke32 duke3d-shareware
}

function sources_eduke32() {
    svn checkout http://svn.eduke32.com/eduke32/polymer/ $md_build
}

function build_eduke32() {
    cd $md_build/eduke32
    make veryclean
    make NOASM=1 LTO=0 USE_OPENGL=0 SDL_TARGET=2
    md_ret_require="$md_build/eduke32"
}

function install_eduke32() {
    wget $__archive_url/3dduke13.zip -O 3dduke13.zip
    unzip -L -o 3dduke13.zip dn3dsw13.shr
    mkdir -p "$md_inst/shareware"
    unzip -L -o dn3dsw13.shr -d "$md_inst/shareware" duke3d.grp duke.rts
    md_ret_files=(
        '/eduke32/eduke32'
        '/eduke32/mapster32'
    )
}

function configure_eduke32() {
    mkRomDir "ports"
    mkRomDir "ports/duke3d"

    moveConfigDir "$home/.eduke32" "$configdir/duke3d"

    local file
    local file_bn
    for file in "$md_inst/shareware/"*; do
        file_bn=${file##*/}
        rm -f "$romdir/ports/duke3d/$file_bn"
        ln -snv "$file" "$romdir/ports/duke3d/$file_bn"
    done

    # remove old launch script
    rm -f "$romdir/ports/Duke3D Shareware.sh"

    addPort "$md_id" "duke3d" "Duke Nukem 3D" "$md_inst/eduke32 -j$romdir/ports/duke3d"
}
