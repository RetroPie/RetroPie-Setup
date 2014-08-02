rp_module_id="pisnes"
rp_module_desc="SNES emulator PiSNES"
rp_module_menus="2+"

function sources_pisnes() {
    gitPullOrClone "$rootdir/emulators/pisnes" https://code.google.com/p/pisnes/ NS
}

function build_pisnes() {
    pushd "$rootdir/emulators/pisnes"
    sed -i -e "s|-lglib-2.0|-lglib-2.0 -lbcm_host|g" Makefile
    make clean
    make
    if [[ ! -f "$rootdir/emulators/pisnes/snes9x" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile PiSNES."
    fi
    popd
}

function configure_pisnes() {
    if [[ -z `grep "mode \"320x240\"" /etc/fb.modes` ]]; then
        echo -e "mode \"320x240\"\ngeometry 320 240 656 512 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" | cat - /etc/fb.modes > temp && mv temp /etc/fb.modes
    fi

    mkdir -p "$romdir/snes-pisnes"

    setESSystem "Super Nintendo" "snes-pisnes" "~/RetroPie/roms/snes-pisnes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$rootdir/emulators/pisnes/snes9x %ROM%" "snes" "snes"
}