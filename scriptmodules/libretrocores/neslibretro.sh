rp_module_id="neslibretro"
rp_module_desc="NES LibretroCore fceu-next"
rp_module_menus="2+"

function sources_neslibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/fceu-next.git
}

function build_neslibretro() {
    cd fceumm-code
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/fceumm-code/fceumm_libretro.so"
}

function install_neslibretro() {
    md_ret_files=(
        'fceumm-code/Authors'
        'fceumm-code/changelog.txt'
        'fceumm-code/Copying'
        'fceumm-code/fceumm_libretro.so'
        'fceumm-code/whatsnew.txt'
        'fceumm-code/zzz_todo.txt'
    )
}

function configure_neslibretro() {
    mkRomDir "nes"
    ensureSystemretroconfig "nes"

    # system-specific shaders, NES
    iniConfig " = " "" "$configdir/nes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"
    iniSet "input_remapping_directory" "$configdir/nes/"

    setESSystem "Nintendo Entertainment System" "nes" "~/RetroPie/roms/nes" ".nes .NES .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/fceumm_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/nes/retroarch.cfg %ROM%\" \"$md_id\"" "nes" "nes"
}
