rp_module_id="mednafenpcefast"
rp_module_desc="Mednafen PCE Fast LibretroCore"
rp_module_menus="2+"

function sources_mednafenpcefast() {
    gitPullOrClone "$rootdir/emulatorcores/mednafenpcefast" https://github.com/libretro/beetle-pce-fast-libretro.git
}

function build_mednafenpcefast() {
    pushd "$rootdir/emulatorcores/mednafenpcefast"
    make
     if [[ -z `find $rootdir/emulatorcores/mednafenpcefast/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Mednafen PCE Fast core."
    fi
    popd
}

function configure_mednafenpcefast() {
    mkdir -p $romdir/pcengine
}