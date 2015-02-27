rp_module_id="stellalibretro"
rp_module_desc="Atari 2600 LibretroCore Stella"
rp_module_menus="2+"

function sources_stellalibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/stella-libretro.git
}

function build_stellalibretro() {
    make clean
    make
    md_ret_require="$md_build/stella_libretro.so"
}

function install_stellalibretro() {
    md_ret_files=(
        'README.md'
        'stella_libretro.so'
    )
}

function configure_stellalibretro() {
    mkRomDir "atari2600-libretro"
    ensureSystemretroconfig "atari2600"

    # system-specific shaders, Atari2600
    iniConfig " = " "" "$configdir/atari2600/retroarch.cfg"
    iniSet "savefile_directory" "~/RetroPie/roms/atari2600-libretro"
    iniSet "savestate_directory" "~/RetroPie/roms/atari2600-libretro"
    iniSet "input_remapping_directory" "$configdir/atari2600/"

    setESSystem "Atari 2600" "atari2600-libretro" "~/RetroPie/roms/atari2600-libretro" ".a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/stella_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/atari2600/retroarch.cfg %ROM%\" \"$md_id\"" "atari2600" "atari2600"
}
