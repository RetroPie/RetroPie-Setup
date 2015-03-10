rp_module_id="lr-gambatte"
rp_module_desc="Gameboy Color emu - libgambatte port for libretro"
rp_module_menus="2+"

function sources_lr-gambatte() {
    gitPullOrClone "$md_build" git://github.com/libretro/gambatte-libretro.git
}

function build_lr-gambatte() {
    make -C libgambatte -f Makefile.libretro clean
    make -C libgambatte -f Makefile.libretro
    md_ret_require="$md_build/libgambatte/gambatte_libretro.so"
}

function install_lr-gambatte() {
    md_ret_files=(
        'COPYING'
        'changelog'
        'README'
        'libgambatte/gambatte_libretro.so'
    )
}

function configure_lr-gambatte() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/gbclibretro"

    mkRomDir "gbc"
    mkRomDir "gb"
    ensureSystemretroconfig "gb" "hq4x.glslp"
    ensureSystemretroconfig "gbc" "hq4x.glslp"

    setESSystem "Game Boy" "gb" "~/RetroPie/roms/gb" ".gb .GB .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/gambatte_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gb/retroarch.cfg %ROM%\" \"$md_id\"" "gb" "gb"
    setESSystem "Game Boy Color" "gbc" "~/RetroPie/roms/gbc" ".gbc .GBC .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/gambatte_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gbc/retroarch.cfg %ROM%\" \"$md_id\"" "gbc" "gbc"
}
