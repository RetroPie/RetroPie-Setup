rp_module_id="o2em"
rp_module_desc="Odyssey 2 / VideoPac LibretroCore O2EM"
rp_module_menus="4+"

function sources_o2em() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-o2em
}

function build_o2em() {
    make clean
    make
    md_ret_require="$md_build/o2em_libretro.so"
}

function install_o2em() {
    md_ret_files=(
        'o2em_libretro.so'
        'README.md'
    )
}

function configure_o2em() {
    mkRomDir "videopac"

    # copy o2rom.bin to RetroPie/BIOS path
    setESSystem "Super Nintendo" "videopac" "~/RetroPie/roms/videopac" ".bin .BIN" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/o2em_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/videopac/retroarch.cfg %ROM%\" \"$md_id\"" "videopac" "videopac"
}
