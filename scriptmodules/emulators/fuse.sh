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
rp_module_menus="2+"
rp_module_flags="dispmanx !mali"

function depends_fuse() {
    getDepends libsdl1.2-dev libpng12-dev zlib1g-dev libbz2-dev libaudiofile-dev bison flex
}

function sources_fuse() {
    wget -O- -q $__archive_url/fuse-1.1.1.tar.gz | tar -xvz --strip-components=1  
    mkdir libspectrum
    wget -O- -q $__archive_url/libspectrum-1.1.1.tar.gz | tar -xvz --strip-components=1 -C libspectrum
    if ! isPlatform "x11"; then
        patch -p1 <<\_EOF_
--- a/ui/sdl/sdldisplay.c	2015-02-18 22:39:05.631516602 +0000
+++ b/ui/sdl/sdldisplay.c	2015-02-18 22:39:08.407506296 +0000
@@ -411,7 +411,7 @@
     SDL_ShowCursor( SDL_DISABLE );
     SDL_WarpMouse( 128, 128 );
   } else {
-    SDL_ShowCursor( SDL_ENABLE );
+    SDL_ShowCursor( SDL_DISABLE );
   }
_EOF_
    fi
}

function build_fuse() {
    pushd libspectrum
    ./configure --disable-shared
    make clean
    make
    popd
    CFLAGS+=" -I$md_build/libspectrum" LDFLAGS+=" -L$md_build/libspectrum/.libs" ./configure --prefix="$md_inst" --without-libao --without-gpm --without-gtk --without-libxml2 --with-sdl
    make clean
    make
    md_ret_require="$md_build/fuse"
}

function install_fuse() {
    # remove old fuse packages
    if hasPackage "fuse-emulator-sdl"; then
        apt-get remove -y fuse-emulator-sdl fuse-emulator-utils fuse-emulator-common spectrum-roms
    fi

    make install
}

function configure_fuse() {
    mkRomDir "zxspectrum"

    mkUserDir "$md_conf_root/zxspectrum"

    moveConfigFile "$home/.fuserc" "$md_conf_root/zxspectrum/.fuserc"

    setDispmanx "$md_id" 1
    configure_dispmanx_on_fuse

    delSystem "$md_id" "zxspectrum"
    addSystem 0 "$md_id-48k" "zxspectrum" "$md_inst/bin/fuse --machine 48 %ROM%"
    addSystem 0 "$md_id-128k" "zxspectrum" "$md_inst/bin/fuse --machine 128 %ROM%"
}

function configure_dispmanx_on_fuse() {
    setDispmanx "$md_id-48k" 1
    setDispmanx "$md_id-128k" 1
}

function configure_dispmanx_off_fuse() {
    setDispmanx "$md_id-48k" 0
    setDispmanx "$md_id-128k" 0
}
