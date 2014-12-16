rp_module_id="dgen"
rp_module_desc="Megadrive/Genesis emulat. DGEN"
rp_module_menus="2+"

function depends_dgen() {
    checkNeededPackages gcc-4.6 g++-4.6 libsdl1.2-dev libarchive-dev
}

function sources_dgen() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/dgen-sdl-1.32.tar.gz | tar -xvz --strip-components=1
}

function build_dgen() {
    ./configure CC="gcc-4.6" CXX="g++-4.6" --disable-opengl --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/dgen"
}

function install_dgen() {
    make install
    md_ret_require="$md_inst/bin/dgen"
}

function configure_dgen()
{
    if [[ ! -f "$rootdir/configs/all/dgenrc" ]]; then
        mkdir -p "$rootdir/configs/all/"
        cp "$md_inst/sample.dgenrc" "$rootdir/configs/all/dgenrc"
        chown $user:$user "$rootdir/configs/all/dgenrc"
    fi

    ensureKeyValue "joy_pad1_a" "joystick0-button0" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_b" "joystick0-button1" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_c" "joystick0-button2" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_x" "joystick0-button3" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_y" "joystick0-button4" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_z" "joystick0-button5" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_mode" "joystick0-button6" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_start" "joystick0-button7" $rootdir/configs/all/dgenrc

    ensureKeyValue "joy_pad2_a" "joystick1-button0" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_b" "joystick1-button1" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_c" "joystick1-button2" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_x" "joystick1-button3" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_y" "joystick1-button4" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_z" "joystick1-button5" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_mode" "joystick1-button6" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_start" "joystick1-button7" $rootdir/configs/all/dgenrc

    ensureKeyValue "emu_z80_startup" "drz80" $rootdir/configs/all/dgenrc
    ensureKeyValue "emu_m68k_startup" "cyclone" $rootdir/configs/all/dgenrc

    mkdir -p "$romdir/megadrive-dgen"
    mkdir -p "$romdir/segacd-dgen"
    mkdir -p "$romdir/sega32x-dgen"

    setESSystem "Sega Mega Drive / Genesis" "megadrive-dgen" "~/RetroPie/roms/megadrive-dgen" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/dgen -f -r $rootdir/configs/all/dgenrc %ROM%\"" "genesis,megadrive" "megadrive"
    setESSystem "Sega CD" "segacd-dgen" "~/RetroPie/roms/segacd-dgen" ".smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/dgen -f -r $rootdir/configs/all/dgenrc %ROM%\"" "segacd" "segacd"
    setESSystem "Sega 32X" "sega32x-dgen" "~/RetroPie/roms/sega32x-dgen" ".32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/dgen -f -r $rootdir/configs/all/dgenrc %ROM%\"" "sega32x" "sega32x"
}
