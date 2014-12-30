rp_module_id="gbclibretro"
rp_module_desc="Gameboy Color LibretroCore"
rp_module_menus="2+"

function sources_gbclibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/gambatte-libretro.git
}

function build_gbclibretro() {
    make -C libgambatte -f Makefile.libretro clean
    make -C libgambatte -f Makefile.libretro
    md_ret_require="$md_build/libgambatte/gambatte_libretro.so"
}

function install_gbclibretro() {
    md_ret_files=(
        'COPYING'
        'changelog'
        'README'
        'libgambatte/gambatte_libretro.so'
    )
}

function configure_gbclibretro() {
    mkRomDir "gbc"
    mkRomDir "gb"

    setESSystem "Game Boy" "gb" "~/RetroPie/roms/gb" ".gb .GB .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/gambatte_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gb/retroarch.cfg %ROM%\" \"$md_id\"" "gb" "gb"
    setESSystem "Game Boy Color" "gbc" "~/RetroPie/roms/gbc" ".gbc .GBC .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/gambatte_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gbc/retroarch.cfg %ROM%\" \"$md_id\"" "gbc" "gbc"
}