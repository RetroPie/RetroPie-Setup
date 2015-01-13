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
    if [[ ! -f "$configdir/all/dgenrc" ]]; then
        mkdir -p "$configdir/all/"
        cp "sample.dgenrc" "$configdir/all/dgenrc"
        chown $user:$user "$configdir/all/dgenrc"
    fi

    iniConfig " = " "" "$configdir/all/dgenrc"
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

    # we don't have opengl (or build dgen with it)
    iniSet "bool_opengl" "no"

    # lower sample rate
    iniSet "int_soundrate" "22050"

    # if the framebuffer is not the requires resolution dgen seems to give a black screen
    iniConfig "=" "" "/boot/config.txt"
    iniSet "overscan_scale" 1

    configure_dispmanx_on_dgen

    setDispmanx "$md_id" 1

    mkRomDir "megadrive-dgen"
    mkRomDir "segacd-dgen"
    mkRomDir "sega32x-dgen"

    setESSystem "Sega Mega Drive / Genesis" "megadrive-dgen" "~/RetroPie/roms/megadrive-dgen" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/dgen -f -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "genesis,megadrive" "megadrive"
    setESSystem "Sega CD" "segacd-dgen" "~/RetroPie/roms/segacd-dgen" ".smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/dgen -f -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "segacd" "segacd"
    setESSystem "Sega 32X" "sega32x-dgen" "~/RetroPie/roms/sega32x-dgen" ".32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/dgen -f -r $configdir/all/dgenrc %ROM%\" \"$md_id\"" "sega32x" "sega32x"
}

function configure_dispmanx_off_dgen() {
    iniConfig " = " "" "$configdir/all/dgenrc"
    # doublebuffer is disabled on framebuffer by default anyway
    iniSet "bool_doublebuffer" "no"
    iniSet "bool_screen_thread" "no"
    # full screen width/height by default
    iniSet "int_width" "-1"
    iniSet "int_height" "-1"
    # without dispmanx, scale seems to run the fastest
    iniSet "scaling_startup" "scale"
}

function configure_dispmanx_on_dgen() {
    iniConfig " = " "" "$configdir/all/dgenrc"
    # turn on double buffer
    iniSet "bool_doublebuffer" "yes"
    iniSet "bool_screen_thread" "yes"
    # set rendering resolution to 320x240
    iniSet "int_width" "320"
    iniSet "int_height" "240"
    # no scaling needed
    iniSet "scaling_startup" "none" "$configdir/all/dgenrc"
}
