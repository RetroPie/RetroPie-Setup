rp_module_id="neslibretro"
rp_module_desc="NES LibretroCore fceu-next"
rp_module_menus="2+"

function sources_neslibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/fceu-next.git
}

function build_neslibretro() {
    cd fceumm-code
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/fceumm-code/fceumm_libretro.so"
}

function install_neslibretro() {
    md_ret_files=(
        'fceumm-code/Authors'
        'fceumm-code/changelog.txt'
        'fceumm-code/Copying'
        'fceumm-code/fceumm_libretro.so'
        'fceumm-code/whatsnew.txt'
        'fceumm-code/zzz_todo.txt'
    )
}

function configure_neslibretro() {
    mkRomDir "nes"

    rps_retronet_prepareConfig
    setESSystem "Nintendo Entertainment System" "nes" "~/RetroPie/roms/nes" ".nes .NES" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/bin/retroarch -L $md_inst/fceumm_libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/nes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "nes" "nes"
}