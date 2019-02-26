#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dgen"
rp_module_desc="Megadrive/Genesis emulator DGEN"
rp_module_help="ROM Extensions: .32x .iso .cue .smd .bin .gen .md .sg .zip\n\nCopy your  Megadrive / Genesis roms to $romdir/megadrive\nSega 32X roms to $romdir/sega32x\nand SegaCD roms to $romdir/segacd\nThe Sega CD requires the BIOS files bios_CD_U.bin, bios_CD_E.bin, and bios_CD_J.bin copied to $biosdir"
rp_module_licence="GPL2 https://sourceforge.net/p/dgen/dgen/ci/master/tree/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !kms"

function depends_dgen() {
    getDepends libsdl1.2-dev libarchive-dev
}

function sources_dgen() {
    downloadAndExtract "$__archive_url/dgen-sdl-1.33.tar.gz" "$md_build" --strip-components 1
}

function build_dgen() {
    local params=()
    isPlatform "rpi" && params+=(--disable-opengl --disable-hqx)
    # dgen contains obsoleted arm assembler that gcc/as will not like for armv8 cpu targets
    if isPlatform "armv8"; then
        CFLAGS="-O2 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" ./configure --prefix="$md_inst"
    else
        ./configure --prefix="$md_inst"
    fi
    make clean
    make
    md_ret_require="$md_build/dgen"
}

function install_dgen() {
    make install
    cp "sample.dgenrc" "$md_inst/"
    md_ret_require="$md_inst/bin/dgen"
}

function configure_dgen() {
    local system
    for system in megadrive segacd sega32x; do
        mkRomDir "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/bin/dgen -r $md_conf_root/megadrive/dgenrc %ROM%"
        addSystem "$system"
    done

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$md_conf_root/megadrive"

    # move config from previous location
    if [[ -f "$configdir/all/dgenrc" ]]; then
        mv -v "$configdir/all/dgenrc" "$md_conf_root/megadrive/dgenrc"
    fi

    if [[ ! -f "$md_conf_root/megadrive/dgenrc" ]]; then
        cp "sample.dgenrc" "$md_conf_root/megadrive/dgenrc"
        chown $user:$user "$md_conf_root/megadrive/dgenrc"
    fi

    iniConfig " = " "" "$md_conf_root/megadrive/dgenrc"

    if isPlatform "rpi"; then
        iniSet "int_width" "320"
        iniSet "int_height" "240"
        iniSet "bool_doublebuffer" "no"
        iniSet "bool_screen_thread" "yes"
        iniSet "scaling_startup" "none"

        # we don't have opengl (or build dgen with it)
        iniSet "bool_opengl" "no"

        # lower sample rate
        iniSet "int_soundrate" "22050"

        iniSet "emu_z80_startup" "drz80"
        iniSet "emu_m68k_startup" "cyclone"
    fi

    iniSet "joy_pad1_a" "joystick0-button0"
    iniSet "joy_pad1_b" "joystick0-button1"
    iniSet "joy_pad1_c" "joystick0-button2"
    iniSet "joy_pad1_x" "joystick0-button3"
    iniSet "joy_pad1_y" "joystick0-button4"
    iniSet "joy_pad1_z" "joystick0-button5"
    iniSet "joy_pad1_mode" "joystick0-button6"
    iniSet "joy_pad1_start" "joystick0-button7"

    iniSet "joy_pad2_a" "joystick1-button0"
    iniSet "joy_pad2_b" "joystick1-button1"
    iniSet "joy_pad2_c" "joystick1-button2"
    iniSet "joy_pad2_x" "joystick1-button3"
    iniSet "joy_pad2_y" "joystick1-button4"
    iniSet "joy_pad2_z" "joystick1-button5"
    iniSet "joy_pad2_mode" "joystick1-button6"
    iniSet "joy_pad2_start" "joystick1-button7"

    setDispmanx "$md_id" 1
}
