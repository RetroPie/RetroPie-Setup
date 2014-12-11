rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"

function depends_gpsp() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_gpsp() {
    gitPullOrClone "$builddir/$1" git://github.com/gizmo98/gpsp.git
}

function build_gpsp() {
    cd raspberrypi
    rpSwap on 256 240
    make clean
    make
    rpSwap off
    require="$builddir/$1/raspberrypi/gpsp"
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
    chown $user:$user -R "$emudir/$1"

    setESSystem "Game Boy Advance" "gba" "~/RetroPie/roms/gba" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/gpsp/gpsp %ROM%\"" "gba" "gba"
}
