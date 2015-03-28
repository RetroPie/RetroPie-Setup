#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="eduke32"
rp_module_desc="Duke3D Port"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_eduke32() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libflac-dev libvorbis-dev libpng12-dev libvpx-dev freepats
    # remove old eduke packages
    hasPackage eduke32 && apt-get remove -y eduke32 duke3d-shareware
}

function sources_eduke32() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/eduke32.tar.gz | tar -xvz --strip-components=1
}

function build_eduke32() {
    make veryclean
    make NOASM=1 LTO=0 USE_OPENGL=0 SDL_TARGET=1
    md_ret_require="$md_build/eduke32"
}

function install_eduke32() {
    wget http://downloads.petrockblock.com/retropiearchives/3dduke13.zip -O 3dduke13.zip
    unzip -L -o 3dduke13.zip dn3dsw13.shr
    mkdir -p "$md_inst/shareware"
    unzip -L -o dn3dsw13.shr -d "$md_inst/shareware" duke3d.grp duke.rts
    md_ret_files=(
        'eduke32'
        'mapster32'
    )
}

function configure_eduke32() {
    mkRomDir "ports/duke3d"

    local file
    local file_bn
    for file in "$md_inst/shareware/"*; do
        file_bn=${file##*/}
        rm -f "$romdir/ports/duke3d/$file_bn"
        ln -snv "$file" "$romdir/ports/duke3d/$file_bn"
    done

    cat > "$romdir/ports/Duke3D Shareware.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 0 "$md_inst/eduke32 -j$romdir/ports/duke3d" "$md_id"
_EOF_
    chmod +x "$romdir/ports/Duke3D Shareware.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports' 
}