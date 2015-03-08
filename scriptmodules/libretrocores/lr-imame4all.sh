rp_module_id="lr-imame4all"
rp_module_desc="Arcade emu - iMAME4all (based on MAME 0.37b5) port for libretro"
rp_module_menus="2+"

function sources_lr-imame4all() {
    gitPullOrClone "$md_build" git://github.com/libretro/imame4all-libretro.git
    sed -i "s/@mkdir/@mkdir -p/g" makefile.libretro
}

function build_lr-imame4all() {
    make -f makefile.libretro clean
    make -f makefile.libretro ARM=1
    md_ret_require="$md_build/libretro.so"
}

function install_lr-imame4all() {
    md_ret_files=(
        'libretro.so'
        'Readme.txt'
    )
}

function configure_lr-imame4all() {
    mkRomDir "mame-libretro"
    ensureSystemretroconfig "mame"

    # system-specific shaders, Mame
    iniConfig " = " "" "$configdir/mame/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/mame/"

    setESSystem "MAME" "mame-libretro" "~/RetroPie/roms/mame-libretro" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$emudir/retroarch/bin/retroarch -L $md_inst/libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/mame/retroarch.cfg %ROM%\" \"$md_id\"" "arcade" "mame"
}
