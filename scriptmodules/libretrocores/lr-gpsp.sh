rp_module_id="lr-gpsp"
rp_module_desc="GBA emu - gpSP port for libretro"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_lr-gpsp() {
    gitPullOrClone "$md_build" https://github.com/libretro/gpsp.git
}

function build_lr-gpsp() {
    make clean
    make -j2 platform=armv
    md_ret_require="$md_build/gpsp_libretro.so"
}

function install_lr-gpsp() {
    md_ret_files=(
        'gpsp_libretro.so'
        'COPYING'
        'readme.txt'
        'game_config.txt'
    )
}

function configure_lr-gpsp() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/gpsp-libretro"

    mkdir -p $romdir/gba-gpsp-libretro
    ensureSystemretroconfig "gba"

    # system-specific shaders, gpsp
    iniConfig " = " "" "$configdir/gba/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/gba/"

    setESSystem "Game Boy Advance" "gba-gpsp-libretro" "~/RetroPie/roms/gba-gpsp-libretro" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/gpsp_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gba/retroarch.cfg %ROM%\" \"$md_id\""  "gba" "gba"
}
