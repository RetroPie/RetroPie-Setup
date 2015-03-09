rp_module_id="lr-mednafen-pce"
rp_module_desc="PCEngine emu - Mednafen PCE core port for libretro"
rp_module_menus="2+"

function sources_lr-mednafen-pce() {
    gitPullOrClone "$md_build" https://github.com/petrockblog/mednafen-pce-libretro.git
}

function build_lr-mednafen-pce() {
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_lr-mednafen-pce() {
    md_ret_files=(
        'README.md'
        'libretro.so'
    )
}

function configure_lr-mednafen-pce() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/turbografx16"

    mkRomDir "pcengine"
    ensureSystemretroconfig "pcengine"

    # system-specific shaders, PC Engine
    iniConfig " = " "" "$configdir/pcengine/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/pcengine/"
    
    delSystem "$md_id" "pcengine-libretro"
    addSystem 1 "$md_id" "pcengine" "$md_inst/libretro.so"
}
