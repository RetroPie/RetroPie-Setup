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
rp_module_desc="Megadrive/Genesis emulat. DGEN"
rp_module_menus="2+"
rp_module_flags="dispmanx !mali"

function depends_dgen() {
    getDepends libsdl1.2-dev libarchive-dev
}

function sources_dgen() {
    wget -O- -q $__archive_url/dgen-sdl-1.33.tar.gz | tar -xvz --strip-components=1
}

function build_dgen() {
    local params=()
    isPlatform "rpi" && params+=(--disable-opengl --disable-hqx)
    ./configure  --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/dgen"
}

function install_dgen() {
    make install
    cp "sample.dgenrc" "$md_inst/"
    md_ret_require="$md_inst/bin/dgen"
}

function configure_dgen()
{
    mkRomDir "megadrive"
    mkRomDir "segacd"
    mkRomDir "sega32x"

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

    addSystem 0 "$md_id" "megadrive" "$md_inst/bin/dgen -r $md_conf_root/megadrive/dgenrc %ROM%"
    addSystem 0 "$md_id" "segacd" "$md_inst/bin/dgen -r $md_conf_root/megadrive/dgenrc %ROM%"
    addSystem 0 "$md_id" "sega32x" "$md_inst/bin/dgen -r $md_conf_root/megadrive/dgenrc %ROM%"
}
