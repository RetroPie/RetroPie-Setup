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
rp_module_licence="GPL2 http://svn.eduke32.com/eduke32/package/common/gpl-2.0.txt"
rp_module_section="opt"

function depends_eduke32() {
    local depends=(
        subversion flac libflac-dev libvorbis-dev libpng-dev libvpx-dev freepats
        libsdl2-dev libsdl2-mixer-dev
    )

    isPlatform "x86" && depends+=(nasm)
    isPlatform "x11" && depends+=(libgl1-mesa-dev libglu1-mesa-dev libgtk2.0-dev)
    getDepends "${depends[@]}"
}

function sources_eduke32() {
    svn checkout -r7077 http://svn.eduke32.com/eduke32 "$md_build"
}

function build_eduke32() {
    local params=(LTO=0 SDL_TARGET=2)
    ! isPlatform "x86" && params+=(NOASM=1)
    ! isPlatform "x11" && params+=(USE_OPENGL=0)
    make veryclean
    CFLAGS+=" -DSDL_USEFOLDER" make "${params[@]}"
    md_ret_require="$md_build/eduke32"
}

function install_eduke32() {
    md_ret_files=(
        'eduke32'
        'mapster32'
    )
}

function game_data_eduke32() {
    cd "$_tmpdir"
    if [[ ! -f "$romdir/ports/duke3d/duke3d.grp" ]]; then
        wget -O 3dduke13.zip "$__archive_url/3dduke13.zip"
        unzip -L -o 3dduke13.zip dn3dsw13.shr
        unzip -L -o dn3dsw13.shr -d "$romdir/ports/duke3d" duke3d.grp duke.rts
        rm 3dduke13.zip dn3dsw13.shr
        chown -R $user:$user "$romdir/ports/duke3d"
    fi
}

function configure_eduke32() {
    addPort "$md_id" "duke3d" "Duke Nukem 3D" "$md_inst/eduke32 -j$romdir/ports/duke3d"

    mkRomDir "ports/duke3d"

    moveConfigDir "$home/.config/eduke32" "$md_conf_root/duke3d"

    # remove old launch script
    rm -f "$romdir/ports/Duke3D Shareware.sh"

    [[ "$md_mode" == "install" ]] && game_data_eduke32
}
