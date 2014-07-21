rp_module_id="genesislibretro"
rp_module_desc="Genesis/Megadrive LibretroCore"
rp_module_menus="2+"

function sources_genesislibretro() {
    gitPullOrClone "$rootdir/emulatorcores/Genesis-Plus-GX" git://github.com/libretro/Genesis-Plus-GX.git
}

function build_genesislibretro() {
    pushd "$rootdir/emulatorcores/Genesis-Plus-GX"
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    if [[ ! -f `find $rootdir/emulatorcores/Genesis-Plus-GX/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Genesis core."
    fi
    popd
}

function configure_genesislibretro() {
    mkdir -p $romdir/megadrive
}