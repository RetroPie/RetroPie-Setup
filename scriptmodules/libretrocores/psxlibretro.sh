rp_module_id="psxlibretro"
rp_module_desc="Playstation 1 LibretroCore"
rp_module_menus="2+"

function sources_psxlibretro() {
    gitPullOrClone "$rootdir/emulatorcores/pcsx_rearmed" git://github.com/libretro/pcsx_rearmed.git
}

function build_psxlibretro() {
    pushd "$rootdir/emulatorcores/pcsx_rearmed"
    ./configure --platform=libretro
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Playstation core."
    fi
    popd
}

function configure_psxlibretro() {
    mkdir -p $romdir/psx
}