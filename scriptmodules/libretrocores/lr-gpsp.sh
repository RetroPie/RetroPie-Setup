rp_module_id="lr-gpsp"
rp_module_desc="GBA emu - gpSP port for libretro"
rp_module_menus="2+"

function sources_lr-gpsp() {
    gitPullOrClone "$md_build" https://github.com/libretro/gpsp.git
}

function build_lr-gpsp() {
    make clean
    rpSwap on 512
    CFLAGS="$CFLAGS -DARM_MEMORY_DYNAREC" make platform=armv HAVE_DYNAREC=1
    rpSwap off
    md_ret_require="$md_build/gpsp_libretro.so"
}

function install_lr-gpsp() {
    md_ret_files=(
        'gpsp_libretro.so'
        'COPYING'
        'readme.txt'
        'game_config.txt'
    )
}

function configure_lr-gpsp() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/gpsp-libretro"

    mkRomDir "gba"
    ensureSystemretroconfig "gba"

    delSystem "$md_id" "gba-gpsp-libretro"
    addSystem 0 "$md_id" "gba" "$md_inst/gpsp_libretro.so"
}
