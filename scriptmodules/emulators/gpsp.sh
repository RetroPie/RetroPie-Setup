rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"

function depends_gpsp() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_gpsp() {
    gitPullOrClone "$md_build" git://github.com/gizmo98/gpsp.git
}

function build_gpsp() {
    cd raspberrypi
    rpSwap on 256 240
    make clean
    make
    rpSwap off
    require="$md_build/raspberrypi/gpsp"
}

function install_gpsp() {
    files=(
        'COPYING.DOC'
        'game_config.txt'
        'readme.txt'
        'raspberrypi/gpsp'
    )
}

function configure_gpsp() {
    mkdir -p "$romdir/gba"
    chown $user:$user -R "$md_inst"

    setESSystem "Game Boy Advance" "gba" "~/RetroPie/roms/gba" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$md_inst/gpsp %ROM%\"" "gba" "gba"
}
