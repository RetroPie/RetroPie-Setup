#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="atari800"
rp_module_desc="Atari 8-bit/800/5200 emulator"
rp_module_help="ROM Extensions: .a52 .bas .bin .car .xex .atr .xfd .dcm .atr.gz .xfd.gz\n\nCopy your Atari800 games to $romdir/atari800\n\nCopy your Atari 5200 roms to $romdir/atari5200 You need to copy the Atari 800/5200 BIOS files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to the folder $biosdir and then on first launch configure it to scan that folder for roms (F1 -> Emulator Configuration -> System Rom Settings)"
rp_module_licence="GPL2 https://sourceforge.net/p/atari800/source/ci/master/tree/COPYING"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_atari800() {
    local depends=(libsdl1.2-dev autoconf zlib1g-dev libpng12-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_atari800() {
    downloadAndExtract "$__archive_url/atari800-3.1.0.tar.gz" "$md_build" 1
    if isPlatform "rpi"; then
        applyPatch rpi_fixes.diff <<\_EOF_
--- a/src/configure.ac
+++ b/src/configure.ac
@@ -136,7 +136,8 @@ if [[ "$a8_target" = "ps2" ]]; then
     LDFLAGS="$LDFLAGS -L${PS2SDK}/ports/lib"
 fi
 if [[ "$a8_target" = "rpi" ]]; then
-    CC="${RPI_SDK}/bin/arm-linux-gnueabihf-gcc"
+    [[ -z "$RPI_SDK" ]] && RPI_SDK="/opt/vc"
+    CC="gcc"
     CFLAGS="$CFLAGS -I${RPI_SDK}/include -I${RPI_SDK}/include/SDL -I${RPI_SDK}/include/interface/vmcs_host/linux -I${RPI_SDK}/include/interface/vcos/pthreads"
     LDFLAGS="$LDFLAGS -Wl,--unresolved-symbols=ignore-in-shared-libs -L${RPI_SDK}/lib"
 fi
@@ -309,8 +310,9 @@ dnl BeOS has a real issue with redundant-decls
         AC_DEFINE(SUPPORTS_PLATFORM_CONFIGURE,1,[Additional config file options.])
         AC_DEFINE(SUPPORTS_PLATFORM_CONFIGSAVE,1,[Save additional config file options.])
         AC_DEFINE(SUPPORTS_PLATFORM_PALETTEUPDATE,1,[Update the Palette if it changed.])
-        A8_NEED_LIB(GLESv2)
-        A8_NEED_LIB(EGL)
+        AC_DEFINE(PLATFORM_MAP_PALETTE,1,[Platform-specific mapping of RGB palette to display surface.])
+        A8_NEED_LIB(brcmGLESv2)
+        A8_NEED_LIB(brcmEGL)
         A8_NEED_LIB(SDL)
         A8_NEED_LIB(bcm_host)
         OBJS="atari_rpi.o gles2/video.o sdl/main.o sdl/input.o"
_EOF_
    fi
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

    mkUserDir "$md_conf_root/atari800"

    # move old config if exists to new location
    if [[ -f "$md_conf_root/atari800.cfg" ]]; then
        mv "$md_conf_root/atari800.cfg" "$md_conf_root/atari800/atari800.cfg"
    fi
    moveConfigFile "$home/.atari800.cfg" "$md_conf_root/atari800/atari800.cfg"

    addEmulator 1 "atari800" "atari800" "$md_inst/bin/atari800 %ROM%"
    addEmulator 1 "atari800" "atari5200" "$md_inst/bin/atari800 %ROM%"
    addSystem "atari800"
    addSystem "atari5200"
}
