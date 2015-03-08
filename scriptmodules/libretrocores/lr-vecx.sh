rp_module_id="lr-vecx"
rp_module_desc="Vectrex emulator - vecx port for libretro"
rp_module_menus="2+"

function sources_lr-vecx() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-vecx
}

function build_lr-vecx() {
    make clean
    make -f Makefile.libretro
    md_ret_require="$md_build/vecx_libretro.so"
}

function install_lr-vecx() {
    md_ret_files=(
        'vecx_libretro.so'
        'bios/fast.bin'
        'bios/skip.bin'
        'bios/system.bin'
    )
}

function configure_lr-vecx() {
    mkRomDir "vectrex"
    ensureSystemretroconfig "vectrex"

    # system-specific shaders, Vectrex
    iniConfig " = " "" "$configdir/vectrex/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/vectrex/"

    # Copy bios files
    cp "$md_inst/"{fast.bin,skip.bin,system.bin} "$biosdir/"
    chown $user:$user "$biosdir/"{fast.bin,skip.bin,system.bin}

    setESSystem "Vectrex" "vectrex" "~/RetroPie/roms/vectrex" ".vec .VEC .gam .GAM .bin .BIN" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$emudir/retroarch/bin/retroarch -L $md_inst/vecx_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/vectrex/retroarch.cfg %ROM%\" \"$md_id\"" "vectrex" "vectrex"
}
