rp_module_id="snes9x"
rp_module_desc="SNES emulator SNES9X-RPi"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_snes9x() {
    getDepends libsdl1.2-dev libboost-thread-dev libboost-system-dev libsdl-ttf2.0-dev libasound2-dev
}

function sources_snes9x() {
    gitPullOrClone "$md_build" https://github.com/joolswills/snes9x-rpi.git retropie
}

function build_snes9x() {
    make clean
    make
    md_ret_require="$md_build/snes9x"
}

function install_snes9x() {
    md_ret_files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'readme.txt'
        'README.md'
        'snes9x'
    )
}

function configure_snes9x() {
    mkRomDir "snes-snes9xrpi"

    setDispmanx "$md_id" 1

    setESSystem "Super Nintendo" "snes-snes9xrpi" "~/RetroPie/roms/snes-snes9xrpi" ".smc .sfc .fig .swc .mgd .SMC .SFC .FIG .SWC .MGD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/snes9x %ROM%\" \"$md_id\"" "snes" "snes"
}
