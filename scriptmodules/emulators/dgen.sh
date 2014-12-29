rp_module_id="dgen"
rp_module_desc="Megadrive/Genesis emulat. DGEN"
rp_module_menus="2+"

function depends_dgen() {
    checkNeededPackages libsdl1.2-dev libarchive-dev
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
    if [[ ! -f "$configdir/all/dgenrc" ]]; then
        mkdir -p "$configdir/all/"
        cp "sample.dgenrc" "$configdir/all/dgenrc"
        chown $user:$user "$configdir/all/dgenrc"
    fi

    ensureKeyValue "joy_pad1_a" "joystick0-button0" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_b" "joystick0-button1" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_c" "joystick0-button2" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_x" "joystick0-button3" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_y" "joystick0-button4" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_z" "joystick0-button5" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_mode" "joystick0-button6" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad1_start" "joystick0-button7" "$configdir/all/dgenrc"

    ensureKeyValue "joy_pad2_a" "joystick1-button0" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_b" "joystick1-button1" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_c" "joystick1-button2" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_x" "joystick1-button3" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_y" "joystick1-button4" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_z" "joystick1-button5" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_mode" "joystick1-button6" "$configdir/all/dgenrc"
    ensureKeyValue "joy_pad2_start" "joystick1-button7" "$configdir/all/dgenrc"

    ensureKeyValue "emu_z80_startup" "drz80" "$configdir/all/dgenrc"
    ensureKeyValue "emu_m68k_startup" "cyclone" "$configdir/all/dgenrc"

    # we don't have opengl (or build dgen with it)
    ensureKeyValue "bool_opengl" "no" "$configdir/all/dgenrc"

    # lower sample rate
    ensureKeyValue "int_soundrate" "22050" "$configdir/all/dgenrc"

    # if the framebuffer is not the requires resolution dgen seems to give a black screen
    ensureKeyValueBootconfig "overscan_scale" 1 "/boot/config.txt"

    configure_dispmanx_off_dgen

    mkRomDir "megadrive-dgen"
    mkRomDir "segacd-dgen"
    mkRomDir "sega32x-dgen"

    setESSystem "Sega Mega Drive / Genesis" "megadrive-dgen" "~/RetroPie/roms/megadrive-dgen" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/dgen -f -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "genesis,megadrive" "megadrive"
    setESSystem "Sega CD" "segacd-dgen" "~/RetroPie/roms/segacd-dgen" ".smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/dgen -f -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "segacd" "segacd"
    setESSystem "Sega 32X" "sega32x-dgen" "~/RetroPie/roms/sega32x-dgen" ".32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/dgen -f -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "sega32x" "sega32x"
}

function configure_dispmanx_off_dgen() {
    # turn off dispmanx
    ensureKeyValueShort "dgen" "0" "$configdir/all/dispmanx.cfg"
    # doublebuffer is disabled on framebuffer by default anyway
    ensureKeyValue "bool_doublebuffer" "no" "$configdir/all/dgenrc"
    ensureKeyValue "bool_screen_thread" "no" "$configdir/all/dgenrc"
    # full screen width/height by default
    ensureKeyValue "int_width" "-1" "$configdir/all/dgenrc"
    ensureKeyValue "int_height" "-1" "$configdir/all/dgenrc"
    # without dispmanx, scale seems to run the fastest
    ensureKeyValue "scaling_startup" "scale" "$configdir/all/dgenrc"
}

function configure_dispmanx_on_dgen() {
    # turn on dispmanx
    ensureKeyValueShort "dgen" "1" "$configdir/all/dispmanx.cfg"
    # turn on double buffer
    ensureKeyValue "bool_doublebuffer" "yes" "$configdir/all/dgenrc"
    ensureKeyValue "bool_screen_thread" "yes" "$configdir/all/dgenrc"
    # set rendering resolution to 320x240
    ensureKeyValue "int_width" "320" "$configdir/all/dgenrc"
    ensureKeyValue "int_height" "240" "$configdir/all/dgenrc"
    # no scaling needed
    ensureKeyValue "scaling_startup" "none" "$configdir/all/dgenrc"
}
