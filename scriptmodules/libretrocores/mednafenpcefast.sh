rp_module_id="mednafenpcefast"
rp_module_desc="Mednafen PCE Fast LibretroCore"
rp_module_menus="2+"

function sources_mednafenpcefast() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-pce-fast-libretro.git
}

function build_mednafenpcefast() {
    make clean
    make
    md_ret_require="$md_build/mednafen_pce_fast_libretro.so"
}

function install_mednafenpcefast() {
    md_ret_files=(
        'mednafen_pce_fast_libretro.so'
        'README.md'
    )
}

function configure_mednafenpcefast() {
    mkRomDir "pcengine"

    setESSystem "TurboGrafx 16 (PC Engine)" "pcengine" "~/RetroPie/roms/pcengine" ".pce .PCE .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/mednafen_pce_fast_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/pcengine/retroarch.cfg %ROM%\" \"$md_id\"" "pcengine" "pcengine"
}