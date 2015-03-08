rp_module_id="lr-catsfc"
rp_module_desc="SNES emu - CATSFC based on Snes9x / NDSSFC / BAGSFC"
rp_module_menus="4+"

function sources_lr-catsfc() {
    gitPullOrClone "$md_build" git://github.com/libretro/CATSFC-libretro.git
}

function build_lr-catsfc() {
    make clean
    make
    md_ret_require="$md_build/catsfc_libretro.so"
}

function install_lr-catsfc() {
    md_ret_files=(
        'catsfc_libretro.so'
    )
}

function configure_lr-catsfc() {
    mkRomDir "snes-catsfc"
    ensureSystemretroconfig "snes"

    # system-specific shaders, SNES
    iniConfig " = " "" "$configdir/snes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/snes_phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"
    iniSet "input_remapping_directory" "$configdir/snes/"

    setESSystem "Super Nintendo" "snes-catsfc" "~/RetroPie/roms/snes-catsfc" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/catsfc_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/snes/retroarch.cfg %ROM%\" \"$md_id\"" "snes" "snes"
}
