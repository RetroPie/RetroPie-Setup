rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"

function depends_gpsp() {
    rps_checkNeededPackages libsdl1.2-dev
}

# install Game Boy Advance emulator gpSP
function sources_gpsp() {
    gitPullOrClone "$rootdir/emulators/gpsp" git://github.com/gizmo98/gpsp.git
}

function build_gpsp() {
    rpSwap on 512

    pushd "$rootdir/emulators/gpsp"
    cd raspberrypi
    make clean
    make
    cp "$rootdir/emulators/gpsp/game_config.txt" "$rootdir/emulators/gpsp/raspberrypi/"
    # TODO copy gpsp into /opt/retropie/emulators/gpsp directory
    if [[ -z `find $rootdir/emulators/gpsp/ -name "gpsp"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Game Boy Advance emulator."
    fi
    popd

    rpSwap off
}

function configure_gpsp() {
    mkdir -p "$romdir/gba"
    chown $user:$user -R "$rootdir/emulators/gpsp/raspberrypi/"

    setESSystem "Game Boy Advance" "gba" "~/RetroPie/roms/gba" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/gpsp/raspberrypi/gpsp %ROM%\"" "gba" "gba"
}
