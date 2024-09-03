#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="px68k"
rp_module_desc="SHARP X68000 Emulator"
rp_module_help="You need to copy a X68000 bios file (iplrom30.dat, iplromco.dat, iplrom.dat, or iplromxv.dat), and the font file (cgrom.dat or cgrom.tmp) to $biosdir/keropi. Use F12 to access the in emulator menu."
rp_module_repo="git https://github.com/TurtleBazooka/px68k.git master"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_px68k() {
    local depends=(cmake libsdl2-dev)
    # MIDI support is through Fluidsynth, but it needs version 2 of the library
    [[ "$__os_debian_ver" -gt 10 ]] && depends+=(libfluidsynth-dev timgm6mb-soundfont)
    getDepends "${depends[@]}"
}

function sources_px68k() {
    gitPullOrClone
}

function build_px68k() {
    local has_fluid
    [[ "$__os_debian_ver" -gt 10 ]] && has_fluid="FLUID=1"
    make clean
    make CDEBUGFLAGS="$CFLAGS -DNO_MERCURY -DSDL2" SDL2=1 $has_fluid
    md_ret_require="$md_build/px68k.sdl2"
}

function install_px68k() {
    md_ret_files=(
        'px68k.sdl2'
        'readme.txt'
        'README.md'
        'version.txt'
    )
}

function configure_px68k() {
    mkRomDir "x68000"

    moveConfigDir "$home/.keropi" "$md_conf_root/x68000"
    mkUserDir "$biosdir/keropi"

    local bios
    for bios in cgrom.dat iplrom30.dat iplromco.dat iplrom.dat iplromxv.dat; do
        if [[ -f "$biosdir/$bios" ]]; then
            mv "$biosdir/$bios" "$biosdir/keropi/$bios"
        fi
        ln -sf "$biosdir/keropi/$bios" "$md_conf_root/x68000/$bios"
    done

    addEmulator 1 "$md_id" "x68000" "$md_inst/px68k.sdl2 %ROM%"
    addSystem "x68000"

    [[ "$md_mode"  == "remove" ]] && return

    # generate a minimal config file when no configuration is present
    local conf="$md_conf_root/x68000/config"
    if [[ ! -f "$conf" ]]; then
        echo "[WinX68k]" > "$conf"
        echo "StartDir=$romdir/x68000" >> "$conf"
        echo "MenuLanguage=1" >> "$conf" # anything non-zero means US
        # when fluidsynth is enabled, add the soundfont path
        [[ "$__os_debian_ver" -gt 10 ]] && echo "SoundFontFile=/usr/share/sounds/sf2/TimGM6mb.sf2" >> "$conf"
    fi
    chown "$__user":"$__group" "$conf"
}
