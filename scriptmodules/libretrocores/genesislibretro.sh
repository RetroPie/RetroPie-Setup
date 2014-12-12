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
        'Makefile.libretro'
        'README.md'
    )
}

function configure_genesislibretro() {
    mkdir -p "$romdir/gamegear"
    ensureSystemretroconfig "gamegear"
    setESSystem "Sega Game Gear" "gamegear" "~/RetroPie/roms/gamegear" ".gg .GG" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L $md_inst/genesis_plus_gx_libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gamegear/retroarch.cfg  %ROM%\"" "gamegear" "gamegear"
}
