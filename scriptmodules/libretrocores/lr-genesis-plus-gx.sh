rp_module_id="lr-genesis-plus-gx"
rp_module_desc="Sega 8/16 bit emu - Genesis Plus (enhanced) port for libretro"
rp_module_menus="2+"

function sources_lr-genesis-plus-gx() {
    gitPullOrClone "$md_build" git://github.com/libretro/Genesis-Plus-GX.git
}

function build_lr-genesis-plus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/genesis_plus_gx_libretro.so"
}

function install_lr-genesis-plus-gx() {
    md_ret_files=(
        'genesis_plus_gx_libretro.so'
        'HISTORY.txt'
        'LICENSE.txt'
        'README.md'
    )
}

function configure_lr-genesis-plus-gx() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/genesislibretro"

    mkRomDir "gamegear"
    mkRomDir "mastersystem"
    mkRomDir "megadrive"
    
    ensureSystemretroconfig "gamegear"
    ensureSystemretroconfig "mastersystem"
    ensureSystemretroconfig "megadrive"

    delSystem "$md_id" "mastersystem-genesis"
    delSystem "$md_id" "megadrive-genesis"
    
    addSystem 1 "$md_id" "gamegear" "$md_inst/genesis_plus_gx_libretro.so"
    addSystem 0 "$md_id" "mastersystem" "$md_inst/genesis_plus_gx_libretro.so"
    addSystem 0 "$md_id" "megadrive" "$md_inst/genesis_plus_gx_libretro.so"
}
