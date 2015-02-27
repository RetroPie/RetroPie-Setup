rp_module_id="fuse"
rp_module_desc="ZX Spectrum emulator Fuse"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_fuse() {
    getDepends libsdl1.2-dev libpng12-dev zlib1g-dev libbz2-dev libaudiofile-dev bison flex 
}

function sources_fuse() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/fuse-1.1.1.tar.gz | tar -xvz --strip-components=1  
    mkdir libspectrum
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/libspectrum-1.1.1.tar.gz | tar -xvz --strip-components=1 -C libspectrum
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
}

function build_fuse() {
    pushd libspectrum
    ./configure --disable-shared
    make clean
    make
    popd
    CFLAGS+="-I$md_build/libspectrum" LDFLAGS+="-L$md_build/libspectrum/.libs" ./configure --prefix="$md_inst"  --without-libao --without-gpm --without-gtk --without-libxml2 --with-sdl
    make clean
    make
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

    mkdir -p "$configdir/zxspectrum"
    if [[ -f "$home/.fuserc" && ! -h "$home/.fuserc" ]]; then
        mv "$home/.fuserc" "$configdir/zxspectrum/"
    fi
    rm -f "$home/.fuserc"
    ln -sf "$configdir/zxspectrum/.fuserc" "$home/.fuserc"
    chown -R $user:$user "$configdir/zxspectrum"

    setDispmanx "$md_id" 1

    setESSystem "ZX Spectrum" "zxspectrum" "~/RetroPie/roms/zxspectrum" ".sna .SNA .szx .SZX .z80 .Z80 .ipf .IPF .tap .TAP .tzx .TZX .gz .bz2 .udi .UDI .mgt .MGT .img .IMG .trd .TRD .scl .SCL .dsk .DSK" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/fuse --machine 128 %ROM%\" \"$md_id\"" "zxspectrum" "zxspectrum"
}
