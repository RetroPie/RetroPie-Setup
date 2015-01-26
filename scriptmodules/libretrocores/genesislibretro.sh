rp_module_id="genesislibretro"
rp_module_desc="GameGear LibretroCore"
rp_module_menus="2+"

function sources_genesislibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/Genesis-Plus-GX.git
}

function build_genesislibretro() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/genesis_plus_gx_libretro.so"
}

function install_genesislibretro() {
    md_ret_files=(
        'genesis_plus_gx_libretro.so'
        'HISTORY.txt'
        'LICENSE.txt'
        'README.md'
    )
}

function configure_genesislibretro() {
    mkRomDir "gamegear"
    ensureSystemretroconfig "gamegear"

    setESSystem "Sega Game Gear" "gamegear" "~/RetroPie/roms/gamegear" ".gg .GG .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/genesis_plus_gx_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gamegear/retroarch.cfg  %ROM%\" \"$md_id\"" "gamegear" "gamegear"
}
