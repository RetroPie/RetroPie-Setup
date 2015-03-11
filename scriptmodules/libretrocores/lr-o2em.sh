rp_module_id="lr-o2em"
rp_module_desc="Odyssey 2 emulator - O2EM port for libretro"
rp_module_menus="4+"

function sources_lr-o2em() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-o2em
}

function build_lr-o2em() {
    make clean
    make
    md_ret_require="$md_build/o2em_libretro.so"
}

function install_lr-o2em() {
    md_ret_files=(
        'o2em_libretro.so'
        'README.md'
    )
}

function configure_lr-o2em() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/o2em"

    mkRomDir "videopac"
    ensureSystemretroconfig "videopac"

    # copy o2rom.bin to RetroPie/BIOS path
    setESSystem "VideoPac" "videopac" "~/RetroPie/roms/videopac" ".bin .BIN" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/o2em_libretro.so --config $configdir/all/retroarch.cfg %ROM%\" \"$md_id\"" "videopac" "videopac"
}
