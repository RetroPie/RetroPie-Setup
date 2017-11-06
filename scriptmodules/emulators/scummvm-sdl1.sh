#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="scummvm-sdl1"
rp_module_desc="ScummVM - built with legacy SDL1 support."
rp_module_help="Copy your ScummVM games to $romdir/scummvm"
rp_module_licence="GPL2 https://raw.githubusercontent.com/scummvm/scummvm/master/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !x11 !kms"

function depends_scummvm-sdl1() {
    depends_scummvm
}

function sources_scummvm-sdl1() {
    sources_scummvm
    gitPullOrClone "$md_build" https://github.com/scummvm/scummvm.git "branch-1-9"
    if isPlatform "rpi"; then
        applyPatch rpi-sdl1.diff <<\_EOF_
--- a/configure
+++ b/configure
@@ -2807,7 +2807,7 @@ if test -n "$_host"; then
 			# We prefer SDL2 on the Raspberry Pi: acceleration now depends on it
 			# since SDL2 manages dispmanx/GLES2 very well internally.
 			# SDL1 is bit-rotten on this platform.
-			_sdlconfig=sdl2-config
+			_sdlconfig=sdl-config
 			# OpenGL ES support is mature enough as to be the best option on
 			# the Raspberry Pi, so it's enabled by default.
 			# The Raspberry Pi always supports OpenGL ES 2.0 contexts, thus we
_EOF_
    fi
}

function build_scummvm-sdl1() {
    build_scummvm
}

function install_scummvm-sdl1() {
    install_scummvm
}

function configure_scummvm-sdl1() {
    configure_scummvm
}
