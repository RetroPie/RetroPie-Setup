rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"
rp_module_flags=""

function depends_gpsp() {
    checkNeededPackages libsdl1.2-dev
}

function sources_gpsp() {
    gitPullOrClone "$md_build" git://github.com/gizmo98/gpsp.git
}

function build_gpsp() {
    cd raspberrypi
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/raspberrypi/gpsp"
}

function install_gpsp() {
    md_ret_files=(
        'COPYING.DOC'
        'game_config.txt'
        'readme.txt'
        'raspberrypi/gpsp'
    )
}

function configure_gpsp() {
    mkRomDir "gba"
    chown $user:$user -R "$md_inst"

    setESSystem "Game Boy Advance" "gba" "~/RetroPie/roms/gba" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/gpsp %ROM%\" \"$md_id\"" "gba" "gba"
}
