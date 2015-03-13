rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"
rp_module_flags=""

function depends_gpsp() {
    getDepends libsdl1.2-dev
}

function sources_gpsp() {
    gitPullOrClone "$md_build" git://github.com/gizmo98/gpsp.git
    sed -i 's/-mfpu=vfp -mfloat-abi=hard -march=armv6j//' raspberrypi/Makefile
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

    # symlink the rom so so it can be installed with the other bios files
    ln -snf "$biosdir/gba_bios.bin" "$md_inst"

    addSystem 1 "$md_id" "gba" "$md_inst/gpsp %ROM%"
}
