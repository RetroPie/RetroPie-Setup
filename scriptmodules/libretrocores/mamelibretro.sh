rp_module_id="mamelibretro"
rp_module_desc="MAME LibretroCore"
rp_module_menus="2+"

function sources_mamelibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/imame4all-libretro.git
    sed -i "s/@mkdir/@mkdir -p/g" makefile.libretro
}

function build_mamelibretro() {
    make -f makefile.libretro clean
    make -f makefile.libretro ARM=1
    md_ret_require="$md_build/libretro.so"
}

function install_mamelibretro() {
    md_ret_files=(
        'libretro.so'
        'Readme.txt'
    )
}

function configure_mamelibretro() {
    mkRomDir "mame-libretro"
    ensureSystemretroconfig "mame"

    # system-specific shaders, Mame
    iniConfig " = " "" "$configdir/mame/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/mame/"

    setESSystem "MAME" "mame-libretro" "~/RetroPie/roms/mame-libretro" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$emudir/retroarch/bin/retroarch -L $md_inst/libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/mame/retroarch.cfg %ROM%\" \"$md_id\"" "arcade" "mame"
}
