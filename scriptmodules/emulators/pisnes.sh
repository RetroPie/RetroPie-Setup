rp_module_id="pisnes"
rp_module_desc="SNES emulator PiSNES"
rp_module_menus="2+"

function sources_pisnes() {
    gitPullOrClone "$md_build" https://github.com/joolswills/pisnes.git
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
    mkRomDir "snes-pisnes"

    setESSystem "Super Nintendo" "snes-pisnes" "~/RetroPie/roms/snes-pisnes" ".smc .sfc .fig .swc .mgd .SMC .SFC .FIG .SWC .MGD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/snes9x %ROM%\" \"$md_id\"" "snes" "snes"
}
