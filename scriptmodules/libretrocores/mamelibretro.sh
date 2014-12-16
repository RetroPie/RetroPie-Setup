rp_module_id="mamelibretro"
rp_module_desc="MAME LibretroCore"
rp_module_menus="2+"

function sources_mamelibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/imame4all-libretro.git
}

function build_mamelibretro() {
    make -f makefile.libretro clean
    make -f makefile.libretro ARM=1
    md_ret_require="$md_build/libretro.so"
}

function install_mamelibretro() {
    md_ret_files=(
        'libretro.so'
        'Readme.txt'
    )
}

function configure_mamelibretro() {
    mkRomDir "mame-libretro"

    setESSystem "MAME" "mame-libretro" "~/RetroPie/roms/mame-libretro" ".zip .ZIP" "$emudir/$1/bin/retroarch -L $md_inst/libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/mame/retroarch.cfg %ROM%" "arcade" "mame"
}