rp_module_id="gpsp-libretro"
rp_module_desc="GBA LibretroCore gpsp"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_gpsp-libretro() {
    gitPullOrClone "$md_build" https://github.com/libretro/gpsp.git
}

function build_gpsp-libretro() {
    make clean
    make -j2 platform=armv
    md_ret_require="$md_build/gpsp_libretro.so"
}

function install_gpsp-libretro() {
    md_ret_files=(
        'gpsp_libretro.so'
        'COPYING'
        'readme.txt'
        'game_config.txt'
    )
}

function configure_gpsp-libretro() {
    mkdir -p $romdir/gba-gpsp-libretro
    ensureSystemretroconfig "gba"

    setESSystem "Game Boy Advance" "gba-gpsp-libretro" "~/RetroPie/roms/gba-gpsp-libretro" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/gpsp_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gba/retroarch.cfg %ROM%\" \"$md_id\""  "gba" "gba"
}
