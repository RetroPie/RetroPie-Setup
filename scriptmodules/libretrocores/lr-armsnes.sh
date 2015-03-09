rp_module_id="lr-armsnes"
rp_module_desc="SNES emu - forked from pocketsnes focused on performance"
rp_module_menus="4+"

function sources_lr-armsnes() {
    gitPullOrClone "$md_build" git://github.com/rmaz/ARMSNES-libretro
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch src/ppu.cpp
}

function build_lr-armsnes() {
    make clean
    make
    md_ret_require="$md_build/libpocketsnes.so"
}

function install_lr-armsnes() {
    md_ret_files=(
        'libpocketsnes.so'
    )
}

function configure_lr-armsnes() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/armsnes"

    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    # system-specific shaders, SNES
    iniConfig " = " "" "$configdir/snes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/snes_phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"
    iniSet "input_remapping_directory" "$configdir/snes/"

    addSystem "$md_id" "snes" "$md_inst/libpocketsnes.so"
}
