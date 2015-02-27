rp_module_id="dgen"
rp_module_desc="Megadrive/Genesis emulat. DGEN"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_dgen() {
    getDepends libsdl1.2-dev libarchive-dev
}

function sources_dgen() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/dgen-sdl-1.33.tar.gz | tar -xvz --strip-components=1
}

function build_dgen() {
    ./configure --disable-opengl --disable-hqx --prefix="$md_inst"
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
    mkRomDir "megadrive-dgen"
    mkRomDir "segacd-dgen"
    mkRomDir "sega32x-dgen"

    mkdir -p "$configdir/megadrive"
    chown $user:$user "$configdir/megadrive"

    # move config from previous location
    if [[ -f "$configdir/all/dgenrc" ]]; then
        mv -v "$configdir/all/dgenrc" "$configdir/megadrive/dgenrc"
    fi

    if [[ ! -f "$configdir/megadrive/dgenrc" ]]; then
        mkdir -p "$configdir/megadrive"
        cp "sample.dgenrc" "$configdir/megadrive/dgenrc"
        chown $user:$user "$configdir/megadrive/dgenrc"
    fi

    iniConfig " = " "" "$configdir/megadrive/dgenrc"

    iniSet "int_width" "320"
    iniSet "int_height" "240"
    iniSet "bool_doublebuffer" "no"
    iniSet "bool_screen_thread" "yes"
    iniSet "scaling_startup" "none"

    # we don't have opengl (or build dgen with it)
    iniSet "bool_opengl" "no"

    # lower sample rate
    iniSet "int_soundrate" "22050"

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

    iniSet "emu_z80_startup" "drz80"
    iniSet "emu_m68k_startup" "cyclone"

    setDispmanx "$md_id" 1

    setESSystem "Sega Mega Drive / Genesis" "megadrive-dgen" "~/RetroPie/roms/megadrive-dgen" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/dgen -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "genesis,megadrive" "megadrive"
    setESSystem "Sega CD" "segacd-dgen" "~/RetroPie/roms/segacd-dgen" ".smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/dgen -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "segacd" "segacd"
    setESSystem "Sega 32X" "sega32x-dgen" "~/RetroPie/roms/sega32x-dgen" ".32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/dgen -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "sega32x" "sega32x"
}
