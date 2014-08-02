rp_module_id="mamelibretro"
rp_module_desc="MAME LibretroCore"
rp_module_menus="2+"

function sources_mamelibretro() {
    gitPullOrClone "$rootdir/emulatorcores/imame4all-libretro" git://github.com/libretro/imame4all-libretro.git
}

function build_mamelibretro() {
    pushd "$rootdir/emulatorcores/imame4all-libretro"
    make -f makefile.libretro clean
    make -f makefile.libretro ARM=1
    if [[ -z `find $rootdir/emulatorcores/imame4all-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile MAME core."
    fi
    popd
}

function configure_mamelibretro() {
    mkdir -p $romdir/mame-libretro

    setESSystem "MAME" "mame-libretro" "~/RetroPie/roms/mame-libretro" ".zip .ZIP" "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/imame4all-libretro/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/mame/retroarch.cfg %ROM%" "arcade" "mame"
}