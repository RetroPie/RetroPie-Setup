rp_module_id="genesislibretro"
rp_module_desc="GameGear LibretroCore"
rp_module_menus="2+"

function sources_genesislibretro() {
    gitPullOrClone "$rootdir/libretrocores/Genesis-Plus-GX" git://github.com/libretro/Genesis-Plus-GX.git
}

function build_genesislibretro() {
    pushd "$rootdir/libretrocores/Genesis-Plus-GX"
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    if [[ ! -f `find $rootdir/libretrocores/Genesis-Plus-GX/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Genesis core."
    fi
    popd
}

function configure_genesislibretro() {
    mkdir -p $romdir/gamegear
    ensureSystemretroconfig "gamegear"
    setESSystem "Sega Game Gear" "gamegear" "~/RetroPie/roms/gamegear" ".gg .GG" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/libretrocores/Genesis-Plus-GX/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gamegear/retroarch.cfg  %ROM%\"" "gamegear" "gamegear"
}
