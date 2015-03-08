rp_module_id="lr-snes9x-next"
rp_module_desc="SNES emulator - Snes9x 1.52+ (optimised) port for libretro"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_lr-snes9x-next() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x-next
}

function build_lr-snes9x-next() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro platform=armvneon
    md_ret_require="$md_build/snes9x_next_libretro.so"
}

function install_lr-snes9x-next() {
    md_ret_files=(
        'snes9x_next_libretro.so'
        'docs/changes.txt'  
        'docs/control-inputs.txt'  
        'docs/controls.txt'  
        'docs/gpl-2.0.txt'  
        'docs/lgpl-2.1.txt'  
        'docs/porting.html' 
        'docs/snapshots.txt' 
        'docs/snes9x-license.txt'
    )
}

function configure_lr-snes9x-next() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    # system-specific shaders, SNES
    iniConfig " = " "" "$configdir/snes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/snes_phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"
    
    setESSystem "Super Nintendo" "snes" "~/RetroPie/roms/snes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/snes9x_next_libretro.so --config $configdir/snes/retroarch.cfg %ROM%\" \"$md_id\"" "snes" "snes"
}
