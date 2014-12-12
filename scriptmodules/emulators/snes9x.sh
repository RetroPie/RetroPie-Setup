rp_module_id="snes9x"
rp_module_desc="SNES emulator SNES9X-RPi"
rp_module_menus="2+"

function depends_snes9x() {
    rps_checkNeededPackages libsdl1.2-dev libboost-thread-dev libboost-system-dev libsdl-ttf2.0-dev libasound2-dev
}

function sources_snes9x() {
    gitPullOrClone "$md_build" https://github.com/chep/snes9x-rpi.git
}

function build_snes9x() {
    make clean
    make
    require="$md_build/snes9x"
}

function install_snes9x() {
    files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'readme.txt'
        'README.md'
        'snes9x'
    )
}

function configure_snes9x() {
    mkdir -p "$romdir/snes-snes9xrpi"

    if [[ -z `grep "mode \"320x240\"" /etc/fb.modes` ]]; then
        echo -e "mode \"320x240\"\ngeometry 320 240 656 512 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" | cat - /etc/fb.modes > temp && mv temp /etc/fb.modes
    fi

    setESSystem "Super Nintendo" "snes-snes9xrpi" "~/RetroPie/roms/snes-snes9xrpi" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$md_inst/snes9x %ROM%" "snes" "snes"
}
