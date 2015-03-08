rp_module_id="lr-vba-next"
rp_module_desc="GBA emulator - VBA-M (optimised) port for libretro"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_lr-vba-next() {
    gitPullOrClone "$md_build" git://github.com/libretro/vba-next.git
}

function build_lr-vba-next() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j2 platform=armvhardfloatunix TILED_RENDERING=1 HAVE_NEON=1
    md_ret_require="$md_build/vba_next_libretro.so"
}

function install_lr-vba-next() {
    md_ret_files=(
        'vba_next_libretro.so'
    )
}

function configure_lr-vba-next() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/vba-next"

    mkdir -p $romdir/gba-vba-next
    ensureSystemretroconfig "gba"

    setESSystem "Game Boy Advance" "gba-vba-next" "~/RetroPie/roms/gba-vba-next" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/vba_next_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/gba/retroarch.cfg %ROM%\" \"$md_id\""  "gba" "gba"
}
