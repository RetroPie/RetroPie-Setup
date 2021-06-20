#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pc6001vx"
rp_module_desc="NEC PC-6001 series emulator"
rp_module_help="ROM Extensions: .d88 .cmt .cas\n\nCopy your PC-6001 games to to $romdir/pc6001vx\n\nCopy bios files BASICROM.60, BASICROM.62, BASICROM.66, BASICROM.68, CGROM60.60, CGROM60.62, CGROM60.66, CGROM60.68, CGROM60m.62, CGROM66.66, CGROM66.68, CGROM68.64, CGROM68.68, KANJIROM.62, KANJIROM.66, KANJIROM.68, SYSROM2.68, SYSTEMROM1.64, SYSTEMROM1.68, SYSTEMROM2.64, SYSTEMROM2.68, VOICEROM.62, VOICEROM.66, and VOICEROM.68 to $biosdir/pc60"
rp_module_section="exp"
rp_module_flags="dispmanx !mali"

function depends_pc6001vx() {
    getDepends fontconfig libfontconfig1-dev ttf-dejavu libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
}

function sources_pc6001vx() {
    wget http://download.qt.io/official_releases/qt/5.7/5.7.1/submodules/qtbase-opensource-src-5.7.1.tar.xz
    wget http://download.qt.io/official_releases/qt/5.7/5.7.1/submodules/qtmultimedia-opensource-src-5.7.1.tar.xz
    wget -q -O- "http://eighttails.up.seesaa.net/bin/PC6001VX_2.30.0_src.tar.gz" | tar -xvz --strip-components=1
    applyPatch disable_avi.diff <<\_EOF_
--- pc6001vx/PC6001VX.pro_org	2017-02-19 12:19:39.928548542 +0000
+++ pc6001vx/PC6001VX.pro	2017-02-19 12:21:27.258153563 +0000
@@ -23,7 +23,7 @@
 #DEFINES += NOSINGLEAPP
 #DEFINES += NOOPENGL
 #DEFINES += NOSOUND
-#DEFINES += NOAVI
+DEFINES += NOAVI
 #DEFINES += REPLAYDEBUG
 #DEFINES += AUTOSUSPEND
 

_EOF_
	if ! isPlatform "x11"; then
        applyPatch disable_x11.diff <<\_EOF_
--- pc6001vx/PC6001VX.pro_org	2017-02-19 12:19:39.928548542 +0000
+++ pc6001vx/PC6001VX.pro	2017-02-19 12:21:27.258153563 +0000
@@ -54,9 +54,9 @@
 }
 !android:!pandora {
 #Configuration for X11(XCB)
-DEFINES += USE_X11
-QT += x11extras
-LIBS += -lX11
+DEFINES += #USE_X11
+QT += #x11extras
+LIBS += #-lX11
 }
 }
 
_EOF_
        fi
}

function build_pc6001vx() {
    mkdir qt
    cd qt
    tar xvfJ ../qtbase-opensource-src-5.7.1.tar.xz
    tar xvfJ ../qtmultimedia-opensource-src-5.7.1.tar.xz
    cp "$md_data/qmake.conf" qtbase-opensource-src-5.7.1/mkspecs/linux-g++ 
    cd qtbase-opensource-src-5.7.1
    #CFLAGS="-O2 -march=armv8-a -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations -pipe" CXXFLAGS="-O2 -march=armv8-a -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations -pipe" ./configure -eglfs -no-xcb -no-xcb-xlib -no-pulseaudio -alsa -opensource -confirm-license -no-qml-debug -no-linuxfb -no-gif -opengl es2 -no-pch --prefix=/opt/QT5.7.1-eglfs -I/opt/vc/include
    CFLAGS="-O2 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations -pipe" CXXFLAGS="-O2 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations -pipe" ./configure -eglfs -no-xcb -no-xcb-xlib -no-pulseaudio -alsa -opensource -confirm-license -no-qml-debug -no-linuxfb -no-gif -opengl es2 -no-pch --prefix=/opt/QT5.7.1-eglfs -I/opt/vc/include
    make
    make install
    cd ..   
    export PATH=/opt/QT5.7.1-eglfs/bin:$PATH
    cd qtmultimedia-opensource-src-5.7.1
    qmake qtmultimedia.pro
    make
    make install
    cd ../..
    qmake PC6001VX.pro
    make
}

function install_pc6001vx() {
    md_ret_files=(
        'PC6001VX'
    )

}

function configure_pc6001vx() {
    mkRomDir "pc60"
    moveConfigDir "$home/.pc6001vx" "$md_conf_root/pc60"
    mkUserDir "$biosdir/pc60"
    local bios
    for bios in BASICROM.60 BASICROM.62 BASICROM.66 BASICROM.68 CGROM60.60 CGROM60.62 CGROM60.66 CGROM60.68 CGROM60m.62 CGROM66.66 CGROM66.68 CGROM68.64 CGROM68.68 KANJIROM.62 KANJIROM.66 KANJIROM.68 SYSROM2.68 SYSTEMROM1.64 SYSTEMROM1.68 SYSTEMROM2.64 SYSTEMROM2.68 VOICEROM.62 VOICEROM.66 VOICEROM.68; do
        ln -sf "$biosdir/pc60/$bios" "$md_conf_root/pc60/rom/$bios"
    done
    if isPlatform "dispmanx"; then
    addEmulator 1 "$md_id" "pc60" "$md_inst/bin/pc6001vx -platform eglfs %ROM%"
    fi
    if isPlatform "x11"; then
    addEmulator 1 "$md_id" "pc60" "$md_inst/bin/pc6001vx -platform xcb %ROM%"
    fi 
    addSystem "pc60"
}
