rp_module_id="nestopia"
rp_module_desc="NES LibretroCore nestopia"
rp_module_menus="4+"

function sources_nestopia() {
    gitPullOrClone "$md_build" https://github.com/libretro/nestopia.git
}

function build_nestopia() {
    cd libretro
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/libretro/nestopia_libretro.so"
}

function install_nestopia() {
    md_ret_files=(
        'libretro/nestopia_libretro.so'
        'NstDatabase.xml'
        'README.md'
        'README.unix'
        'changelog.txt'
        'readme.html'
        'COPYING'
        'AUTHORS'
    )
}

function configure_nestopia() {
    mkRomDir "nes-nestopia"
    ensureSystemretroconfig "nes"

    # system-specific shaders, NES
    iniConfig " = " "" "$configdir/nes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"
    iniSet "input_remapping_directory" "$configdir/nes/"

    setESSystem "Nintendo Entertainment System" "nes-nestopia" "~/RetroPie/roms/nes-nestopia" ".nes .NES .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/nestopia_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/nes/retroarch.cfg %ROM%\" \"$md_id\"" "nes" "nes"
}
