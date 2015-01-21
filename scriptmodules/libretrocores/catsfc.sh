rp_module_id="catsfc"
rp_module_desc="SNES LibretroCore CATSFC"
rp_module_menus="4+"

function sources_catsfc() {
    gitPullOrClone "$md_build" git://github.com/libretro/CATSFC-libretro.git
}

function build_catsfc() {
    make clean
    make
    md_ret_require="$md_build/catsfc_libretro.so"
}

function install_catsfc() {
    md_ret_files=(
        'catsfc_libretro.so'
    )
}

function configure_catsfc() {
    mkdir -p $romdir/snes-catsfc

    setESSystem "Super Nintendo" "snes-catsfc" "~/RetroPie/roms/snes-catsfc" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/catsfc_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/snes/retroarch.cfg %ROM%\" \"$md_id\"" "snes" "snes"
}
