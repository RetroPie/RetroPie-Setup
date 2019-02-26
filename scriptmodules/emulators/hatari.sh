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
rp_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr\n\nCopy your Atari ST games to $romdir/atarist"
rp_module_licence="GPL2 https://hg.tuxfamily.org/mercurialroot/hatari/hatari/file/9ee1235233e9/gpl.txt"
rp_module_section="opt"
rp_module_flags=""

function depends_hatari() {
    getDepends libsdl2-dev zlib1g-dev libpng-dev cmake libreadline-dev portaudio19-dev
}

function _sources_libcapsimage_hatari() {
    downloadAndExtract "$__archive_url/spsdeclib_5.1_source.zip" "$md_build"
    unzip -o capsimg_source_linux_macosx.zip
    chmod u+x capsimg_source_linux_macosx/CAPSImg/configure
}

function sources_hatari() {
    downloadAndExtract "$__archive_url/hatari-1.9.0.tar.bz2" "$md_build" --strip-components 1
    # we need to use capsimage 5, as there is no source for 4.2
    sed -i "s/CAPSIMAGE_VERSION 4/CAPSIMAGE_VERSION 5/" cmake/FindCapsImage.cmake
    # capsimage 5.1 misses these types that were defined in 4.2
    sed -i "s/CapsLong/Sint32/g" src/floppy_ipf.c
    sed -i "s/CapsULong/Uint32/g" src/floppy_ipf.c
    _sources_libcapsimage_hatari
}

function _build_libcapsimage_hatari() {
    # build libcapsimage
    cd capsimg_source_linux_macosx/CAPSImg
    ./configure --prefix="$md_build"
    make clean
    make
    make install
    mkdir -p "$md_build/src/includes/caps5/"
    cp -R "../LibIPF/"*.h "$md_build/src/includes/caps5/"
    cp "../Core/CommonTypes.h" "$md_build/src/includes/caps5/"
}

function build_hatari() {
    _build_libcapsimage_hatari

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

function _install_libcapsimage_hatari() {
    cp "$md_build/lib/libcapsimage.so.5.1" "$md_inst"
    cd "$md_inst"
    ln -sf libcapsimage.so.5.1 libcapsimage.so.5
}

function install_hatari() {
    make install
    _install_libcapsimage_hatari
}

function configure_hatari() {
    mkRomDir "atarist"

    # move any old configs to new location
    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    local common_config=("--confirm-quit 0" "--statusbar 0")
    if ! isPlatform "x11"; then
        common_config+=("--zoom 1" "-w")
    else
        common_config+=("-f")
    fi

    addEmulator 1 "$md_id-fast" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 0 --timer-d 1 --borders 0 %ROM%"
    addEmulator 0 "$md_id-fast-borders" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 0 --timer-d 1 --borders 1 %ROM%"
    addEmulator 0 "$md_id-compatible" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 1 --timer-d 0 --borders 0 %ROM%"
    addEmulator 0 "$md_id-compatible-borders" "atarist" "$md_inst/bin/hatari ${common_config[*]} --compatible 1 --timer-d 0 --borders 1 %ROM%"
    addSystem "atarist"
}
