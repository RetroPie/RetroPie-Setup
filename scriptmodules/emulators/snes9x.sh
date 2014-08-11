rp_module_id="snes9x"
rp_module_desc="SNES emulator SNES9X-RPi"
rp_module_menus="2+"

function depends_snes9x() {
    rps_checkNeededPackages libsdl1.2-dev libboost-thread-dev libboost-system-dev libsdl-ttf2.0-dev
}

function sources_snes9x() {
    gitPullOrClone "$rootdir/emulators/snes9x-rpi" https://github.com/chep/snes9x-rpi.git
}

function build_snes9x() {
    pushd "$rootdir/emulators/snes9x-rpi"
    make clean
    make
    if [[ ! -f "$rootdir/emulators/snes9x-rpi/snes9x" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES9X."
    fi
    popd
}

function configure_snes9x() {
    if [[ -z `grep "mode \"320x240\"" /etc/fb.modes` ]]; then
        echo -e "mode \"320x240\"\ngeometry 320 240 656 512 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" | cat - /etc/fb.modes > temp && mv temp /etc/fb.modes
    fi

    mkdir -p "$romdir/snes-snes9xrpi"

    setESSystem "Super Nintendo" "snes-snes9xrpi" "~/RetroPie/roms/snes-snes9xrpi" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$rootdir/emulators/snes9x-rpi/snes9x %ROM%" "snes" "snes"
}