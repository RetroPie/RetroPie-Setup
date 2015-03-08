rp_module_id="lr-stella"
rp_module_desc="Atari 2600 emulator - Stella port for libretro"
rp_module_menus="2+"

function sources_lr-stella() {
    gitPullOrClone "$md_build" git://github.com/libretro/stella-libretro.git
}

function build_lr-stella() {
    make clean
    make
    md_ret_require="$md_build/stella_libretro.so"
}

function install_lr-stella() {
    md_ret_files=(
        'README.md'
        'stella_libretro.so'
    )
}

function configure_lr-stella() {
    mkRomDir "atari2600-libretro"
    ensureSystemretroconfig "atari2600"

    # system-specific shaders, Atari2600
    iniConfig " = " "" "$configdir/atari2600/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/atari2600/"

    setESSystem "Atari 2600" "atari2600-libretro" "~/RetroPie/roms/atari2600-libretro" ".a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/stella_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/atari2600/retroarch.cfg %ROM%\" \"$md_id\"" "atari2600" "atari2600"
}
