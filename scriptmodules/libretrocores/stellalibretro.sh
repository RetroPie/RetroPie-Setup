rp_module_id="stellalibretro"
rp_module_desc="Atari 2600 LibretroCore Stella"
rp_module_menus="2+"

function sources_stellalibretro() {
    gitPullOrClone "$rootdir/emulatorcores/stella-libretro" git://github.com/libretro/stella-libretro.git
}

function build_stellalibretro() {
    pushd "$rootdir/emulatorcores/stella-libretro"
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 2600 core."
    fi
    popd
}

function configure_stellalibretro() {
    mkdir -p $romdir/atari2600
}