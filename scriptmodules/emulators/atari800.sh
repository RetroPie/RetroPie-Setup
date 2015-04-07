#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="atari800"
rp_module_desc="Atari 8-bit/800/5200 emulator"
rp_module_menus="2+"

function depends_atari800() {
    getDepends libsdl1.2-dev autoconf
}

function sources_atari800() {
    wget -q -O- "http://downloads.petrockblock.com/retropiearchives/atari800-3.1.0.tar.gz" | tar -xvz --strip-components=1
patch -p1 <<\_EOF_
--- a/src/configure.ac	2014-04-12 13:58:16.000000000 +0000
+++ b/src/configure.ac	2015-02-14 22:39:42.000000000 +0000
@@ -136,7 +136,8 @@
     LDFLAGS="$LDFLAGS -L${PS2SDK}/ports/lib"
 fi
 if [[ "$a8_target" = "rpi" ]]; then
-    CC="${RPI_SDK}/bin/arm-linux-gnueabihf-gcc"
+    [[ -z "$RPI_SDK" ]] && RPI_SDK="/opt/vc"
+    CC="gcc"
     CFLAGS="$CFLAGS -I${RPI_SDK}/include -I${RPI_SDK}/include/SDL -I${RPI_SDK}/include/interface/vmcs_host/linux -I${RPI_SDK}/include/interface/vcos/pthreads"
     LDFLAGS="$LDFLAGS -Wl,--unresolved-symbols=ignore-in-shared-libs -L${RPI_SDK}/lib"
 fi
@@ -309,6 +310,7 @@
         AC_DEFINE(SUPPORTS_PLATFORM_CONFIGURE,1,[Additional config file options.])
         AC_DEFINE(SUPPORTS_PLATFORM_CONFIGSAVE,1,[Save additional config file options.])
         AC_DEFINE(SUPPORTS_PLATFORM_PALETTEUPDATE,1,[Update the Palette if it changed.])
+        AC_DEFINE(PLATFORM_MAP_PALETTE,1,[Platform-specific mapping of RGB palette to display surface.])
         A8_NEED_LIB(GLESv2)
         A8_NEED_LIB(EGL)
         A8_NEED_LIB(SDL)
_EOF_
}

function build_atari800() {
    cd src
    autoreconf -v
    params=()
    isPlatform "rpi" && params+=(--target=rpi)
    ./configure --prefix="$md_inst" ${params[@]}
    make clean
    make
    md_ret_require="$md_build/src/atari800"
}

function install_atari800() {
    cd src
    make install
}

function configure_atari800() {
    mkRomDir "atari800"
    mkRomDir "atari5200"

    mkUserDir "$configdir/atari800"

    # move old config if exists to new location
    if [[ -f "$home/.atari800.cfg" && ! -h "$home/.atari800.cfg" ]]; then
        mv -v "$home/.atari800.cfg" "$configdir/atari800.cfg"
    fi
    ln -sf "$configdir/atari800/atari800.cfg" "$home/.atari800.cfg"
    chown -R $user:$user  "$configdir/atari800"

    addSystem 1 "$md_id" "atari800" "$md_inst/bin/atari800 %ROM%"
    addSystem 1 "$md_id" "atari5200" "$md_inst/bin/atari800 %ROM%"
    
    __INFMSGS+=("You need to copy the Atari 800/5200 BIOS files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to the folder $biosdir and then on first launch configure it to scan that folder for roms (F1 -> Emulator Configuration -> System Rom Settings)")
}
