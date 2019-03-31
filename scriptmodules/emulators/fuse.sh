#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="fuse"
rp_module_desc="ZX Spectrum emulator Fuse"
rp_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
rp_module_licence="GPL2 https://sourceforge.net/p/fuse-emulator/fuse/ci/master/tree/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali"

function depends_fuse() {
    getDepends libsdl1.2-dev libpng-dev zlib1g-dev libbz2-dev libaudiofile-dev bison flex
}

function sources_fuse() {
    downloadAndExtract "$__archive_url/fuse-1.5.7.tar.gz" "$md_build" --strip-components 1
    mkdir libspectrum
    downloadAndExtract "$__archive_url/libspectrum-1.4.4.tar.gz" "$md_build/libspectrum" --strip-components 1
    if ! isPlatform "x11"; then
        applyPatch "$md_data/01_disable_cursor.diff"
    fi
    applyPatch "$md_data/02_sdl_fix.diff"
}

function build_fuse() {
    pushd libspectrum
    ./configure --disable-shared
    make clean
    make
    popd
    ./configure --prefix="$md_inst" --without-libao --without-gpm --without-gtk --without-libxml2 --with-sdl LIBSPECTRUM_CFLAGS="-I$md_build/libspectrum" LIBSPECTRUM_LIBS="-L$md_build/libspectrum/.libs -lspectrum"
    make clean
    make
    md_ret_require="$md_build/fuse"
}

function install_fuse() {
    make install
}

function configure_fuse() {
    mkRomDir "zxspectrum"

    mkUserDir "$md_conf_root/zxspectrum"

    moveConfigFile "$home/.fuserc" "$md_conf_root/zxspectrum/.fuserc"

    setDispmanx "$md_id" 1
    configure_dispmanx_on_fuse

        cat > "$romdir/zxspectrum/+Start Fuse.sh" << _EOF_
#!/bin/bash
$md_inst/bin/fuse --machine 128 --full-screen
_EOF_

    addEmulator 0 "$md_id-48k" "zxspectrum" "$md_inst/bin/fuse --machine 48 --full-screen %ROM%"
    addEmulator 0 "$md_id-128k" "zxspectrum" "$md_inst/bin/fuse --machine 128 --full-screen %ROM%"
    addSystem "zxspectrum"
}

function configure_dispmanx_on_fuse() {
    setDispmanx "$md_id-48k" 1
    setDispmanx "$md_id-128k" 1
}

function configure_dispmanx_off_fuse() {
    setDispmanx "$md_id-48k" 0
    setDispmanx "$md_id-128k" 0
}
