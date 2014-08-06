rp_module_id="dgen"
rp_module_desc="Megadrive/Genesis emulat. DGEN"
rp_module_menus="2+"

function depen_dgen() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_dgen() {
    rmDirExists "$rootdir/emulators/dgen"
    wget http://downloads.petrockblock.com/retropiearchives/dgen-sdl-1.32.tar.gz
    mkdir -p "$rootdir/emulators/"
    tar xvfz dgen-sdl-1.32.tar.gz -C "$rootdir/emulators/"
    rmDirExists "$rootdir/emulators/dgen-sdl"
    mv "$rootdir/emulators/dgen-sdl-1.32" "$rootdir/emulators/dgen-sdl"
    rm dgen-sdl-1.32.tar.gz
}

function build_dgen() {
    pushd "$rootdir/emulators/dgen-sdl"
    ./configure CC="gcc-4.6" CXX="g++-4.6" --disable-opengl --prefix="$rootdir/emulators/dgen-sdl/installdir"
    make
    popd
}

function install_dgen() {
    pushd "$rootdir/emulators/dgen-sdl"
    if [[ ! -d "$rootdir/emulators/dgen-sdl/installdir" ]]; then
        mkdir -p "$rootdir/emulators/dgen-sdl/installdir"
    fi
    make install
    if [[ ! -f "$rootdir/emulators/dgen-sdl/installdir/bin/dgen" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile DGEN emulator."
    fi
    popd
}

function configure_dgen()
{
    chmod 777 /dev/fb0

    if [[ ! -f "$rootdir/configs/all/dgenrc" ]]; then
        mkdir -p "$rootdir/configs/all/"
        cp $rootdir/emulators/dgen-sdl/sample.dgenrc $rootdir/configs/all/dgenrc
        chmod 666 $rootdir/configs/all/dgenrc
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

    setESSystem "Sega Mega Drive / Genesis" "megadrive-dgen" "~/RetroPie/roms/megadrive-dgen" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/dgen-sdl/installdir/bin/dgen -f -r $rootdir/configs/all/dgenrc %ROM%\"" "genesis,megadrive" "megadrive"
    setESSystem "Sega CD" "segacd-dgen" "~/RetroPie/roms/segacd-dgen" ".smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/dgen-sdl/dgen -f -r $rootdir/configs/all/dgenrc %ROM%\"" "segacd" "segacd"
    setESSystem "Sega 32X" "sega32x-dgen" "~/RetroPie/roms/sega32x-dgen" ".32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/dgen-sdl/dgen -f -r $rootdir/configs/all/dgenrc %ROM%\"" "sega32x" "sega32x"

}
