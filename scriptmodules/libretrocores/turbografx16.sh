rp_module_id="turbografx16"
rp_module_desc="TurboGrafx 16 LibretroCore"
rp_module_menus="2+"

function sources_turbografx16() {
    gitPullOrClone "$md_build" https://github.com/petrockblog/mednafen-pce-libretro.git
}

function build_turbografx16() {
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_turbografx16() {
    md_ret_files=(
        'README.md'
        'libretro.so'
    )
}

function configure_turbografx16() {
    mkRomDir "pcengine-libretro"
    ensureSystemretroconfig "pcengine"

    # system-specific shaders, PC Engine
    iniConfig " = " "" "$configdir/pcengine/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/pcengine/"
    
    setESSystem "TurboGrafx 16 (PC Engine)" "pcengine-libretro" "~/RetroPie/roms/pcengine-libretro" ".pce .PCE .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/pcengine/retroarch.cfg %ROM%\" \"$md_id\"" "pcengine" "pcengine"
}
