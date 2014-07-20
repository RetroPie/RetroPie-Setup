rp_module_id="gbclibretro"
rp_module_desc="Gameboy Color LibretroCore"
rp_module_menus="2+"

function sources_gbclibretro() {
    gitPullOrClone "$rootdir/emulatorcores/gambatte-libretro" git://github.com/libretro/gambatte-libretro.git
}

function build_gbclibretro() {
    pushd "$rootdir/emulatorcores/gambatte-libretro"
    make -f Makefile.libretro clean
    make -C libgambatte -f Makefile.libretro
    if [[ -z `find $rootdir/emulatorcores/gambatte-libretro/libgambatte/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Game Boy Color core."
    fi
    popd
}

function configure_gbclibretro() {
    mkdir -p $romdir/gbc
    mkdir -p $romdir/gb
}