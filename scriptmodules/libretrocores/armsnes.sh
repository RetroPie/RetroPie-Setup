rp_module_id="armsnes"
rp_module_desc="SNES LibretroCore ARMSNES"
rp_module_menus="4+"

function sources_armsnes() {
    gitPullOrClone "$md_build" git://github.com/rmaz/ARMSNES-libretro
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch src/ppu.cpp
}

function build_armsnes() {
    make clean
    make
    md_ret_require="$md_build/libpocketsnes.so"
}

function install_armsnes() {
    md_ret_files=(
        'libpocketsnes.so'
    )
}

function configure_armsnes() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    # system-specific shaders, SNES
    iniConfig " = " "" "$configdir/snes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/snes_phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"
    iniSet "input_remapping_directory" "$configdir/snes/"

    setESSystem "Super Nintendo" "snes" "~/RetroPie/roms/snes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/libpocketsnes.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/snes/retroarch.cfg %ROM%\" \"$md_id\"" "snes" "snes"
    # <!-- alternatively: <command>$emudir/snes9x-rpi/snes9x %ROM%</command> -->
    # <!-- alternatively: <command>$emudir/pisnes/snes9x %ROM%</command> -->
}
