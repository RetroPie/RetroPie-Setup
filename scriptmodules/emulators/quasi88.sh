#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="quasi88"
rp_module_desc="NEC PC-8801 emulator"
rp_module_help="ROM Extensions: .d88 .D88 .cmt .CMT .t88 .T88."
rp_module_section="exp"
version="0.6.4"

function depends_quasi88() {
    local depends=(libsdl1.2-dev)
    getDepends "${depends[@]}"
}

function sources_quasi88() {
    wget -q -O- "http://www.eonet.ne.jp/~showtime/quasi88/release/quasi88-${version}.tgz" | tar -xvz --strip-components=1
    cat > retropie_fixes.diff <<\_EOF_
19,20c19,20
< X11_VERSION	= 1
< # SDL_VERSION	= 1
---
> # X11_VERSION	= 1
> SDL_VERSION	= 1
35c35
< ROMDIR	= ~/quasi88/rom/
---
> ROMDIR	= /home/pi/RetroPie/BIOS/quasi88
45c45
< DISKDIR	= ~/quasi88/disk/
---
> DISKDIR	= /home/pi/RetroPie/roms/pc88
54c54
< TAPEDIR	= ~/quasi88/tape/
---
> TAPEDIR	= /home/pi/RetroPie/roms/pc88
191c191
< ARCH = freebsd
---
> # ARCH = freebsd
193c193
< # ARCH = linux
---
> ARCH = linux
228c228
< # SOUND_SDL		= 1
---
> SOUND_SDL		= 1
237c237
< # USE_OLD_MAME_SOUND	= 1
---
> USE_OLD_MAME_SOUND	= 1
248c248
< USE_FMGEN	= 1
---
> # USE_FMGEN	= 1
370c370
< BINDIR = /usr/local/bin
---
> BINDIR = /opt/retropie/emulators/quasi88
515c515
< LIBS   +=                       `$(SDL_CONFIG) --libs`
---
> LIBS   += -lm                   `$(SDL_CONFIG) --libs`
940c940
< 		-mkdir $@
---
> 		mkdir -p $@
_EOF_
    cp Makefile Makefile_org
    patch Makefile < retropie_fixes.diff
}

function build_quasi88() {
    make clean
    make
}

function install_quasi88() {
    make install
}

function configure_quasi88() {
    mkRomDir "quasi88"
    mkUserDir "$md_conf_root/quasi88"
    
    setDispmanx "$md_id" 0
    addEmulator 1 "quasi88" "quasi88" "$md_inst/bin/quasi88.sdl -f6 IMAGE-NEXT1 -f7 IMAGE-NEXT2 -f8 NOWAI -f9 ROMAJI -f10 NUMLOCK %ROM%"
    addSystem "quasi88"
}
