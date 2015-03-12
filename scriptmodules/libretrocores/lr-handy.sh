rp_module_id="lr-handy"
rp_module_desc="Atari Lynx emulator - Handy port for libretro"
rp_module_menus="2+"

function sources_lr-handy() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-handy.git
}

function build_lr-handy() {
    make clean
    make
    md_ret_require="$md_build/handy_libretro.so"
}

function install_lr-handy() {
    md_ret_files=(
        'handy_libretro.so'
        'README.md'
    )
}

function configure_lr-handy() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/libretro-handy"

    mkRomDir "atarilynx"
    ensureSystemretroconfig "atarilynx"

    setESSystem "Atari Lynx" "atarilynx" "~/RetroPie/roms/atarilynx" ".lnx .LNX .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/handy_libretro.so --config $configdir/atarilynx/retroarch.cfg %ROM%\" \"$md_id\"" "atarilynx" "atarilynx"
}
