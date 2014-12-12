rp_module_id="pisnes"
rp_module_desc="SNES emulator PiSNES"
rp_module_menus="2+"

function sources_pisnes() {
    gitPullOrClone "$md_build" https://code.google.com/p/pisnes/ NS
    sed -i "s/-lglib-2.0$/-lglib-2.0 -lbcm_host -lrt -lasound -lm/g" Makefile
    sed -i "s/armv6 /armv6j /g" Makefile
}

function build_pisnes() {
    make clean
    make
    md_ret_require="$md_build/snes9x"
}

function install_pisnes() {
    md_ret_files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'readme_snes9x.txt'
        'readme.txt'
        'roms'
        'skins'
        'snes9x'
        'snes9x.cfg'
        'snes9x.gui'
    )
}

function configure_pisnes() {
    mkdir -p "$romdir/snes-pisnes"

    if [[ -z `grep "mode \"320x240\"" /etc/fb.modes` ]]; then
        echo -e "mode \"320x240\"\ngeometry 320 240 656 512 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" | cat - /etc/fb.modes > temp && mv temp /etc/fb.modes
    fi

    setESSystem "Super Nintendo" "snes-pisnes" "~/RetroPie/roms/snes-pisnes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$md_inst/snes9x %ROM%" "snes" "snes"
}
