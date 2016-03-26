#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="hatari"
rp_module_desc="Atari emulator Hatari"
rp_module_menus="2+"
rp_module_flags="!mali"

function depends_hatari() {
    getDepends libsdl2-dev zlib1g-dev libpng12-dev cmake libreadline-dev portaudio19-dev
    apt-get remove -y hatari
}

function sources_hatari() {
    wget -q -O- "$__archive_url/hatari-1.9.0.tar.bz2" | tar -xvj --strip-components=1
    wget -q -O spsdeclib.zip "$__archive_url/spsdeclib_5.1_source.zip"
    unzip -o spsdeclib.zip
    unzip -o capsimg_source_linux_macosx.zip
    chmod u+x capsimg_source_linux_macosx/CAPSImg/configure
    # we need to use capsimage 5, as there is no source for 4.2
    sed -i "s/CAPSIMAGE_VERSION 4/CAPSIMAGE_VERSION 5/" cmake/FindCapsImage.cmake
    # capsimage 5.1 misses these types that were defined in 4.2
    sed -i "s/CapsLong/Sint32/g" src/floppy_ipf.c
    sed -i "s/CapsULong/Uint32/g" src/floppy_ipf.c
}

function build_hatari() {
    # build libcapsimage
    cd capsimg_source_linux_macosx/CAPSImg
    ./configure --prefix="$md_build"
    make clean
    make
    make install
    mkdir -p "$md_build/src/includes/caps5/"
    cp -R "../LibIPF/"*.h "$md_build/src/includes/caps5/"
    cp "../Core/CommonTypes.h" "$md_build/src/includes/caps5/"

    # build hatari
    cd "$md_build"
    rm -f CMakeCache.txt
    # capsimage headers includes contain __cdecl which we don't want
    # also add $md_inst to library search path for loading capsimage library
    CFLAGS+=" -D__cdecl=''" LDFLAGS+="-Wl,-rpath='$md_inst'" \
        cmake . \
        -DCMAKE_SKIP_RPATH=ON \
        -DCMAKE_INSTALL_PREFIX:PATH="$md_inst" \
        -DCAPSIMAGE_INCLUDE_DIR="$md_build/src/include" \
        -DCAPSIMAGE_LIBRARY="$md_build/lib/libcapsimage.so.5.1" \
        -DENABLE_SDL2:BOOL=1
    make clean
    make
    md_ret_require="$md_build/src/hatari"
}

function install_hatari() {
    make install
    cp "$md_build/lib/libcapsimage.so.5.1" "$md_inst"
    cd "$md_inst"
    ln -sf libcapsimage.so.5.1 libcapsimage.so.5
}

function configure_hatari() {
    mkRomDir "atarist"

    # move any old configs to new location
    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    delSystem "$md_id" "atariststefalcon"
    delSystem "$md_id" "atarist"

    addSystem 1 "$md_id-fast" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 0 --timer-d 1 -w --borders 0 %ROM%"
    addSystem 0 "$md_id-fast-borders" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 0 --timer-d 1 -w --borders 1 %ROM%"
    addSystem 0 "$md_id-compatible" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 1 --timer-d 0 -w --borders 0 %ROM%"
    addSystem 0 "$md_id-compatible-borders" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 1 --timer-d 0 -w --borders 1 %ROM%"
}
