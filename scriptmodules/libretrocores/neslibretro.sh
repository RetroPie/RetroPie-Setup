rp_module_id="neslibretro"
rp_module_desc="NES LibretroCore fceu-next"
rp_module_menus="2+"

function sources_neslibretro() {
    gitPullOrClone "$rootdir/emulatorcores/fceu-next" git://github.com/libretro/fceu-next.git
}

function build_neslibretro() {
    pushd "$rootdir/emulatorcores/fceu-next/fceumm-code"
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    popd
    if [[ -z `find $rootdir/emulatorcores/fceu-next/fceumm-code/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NES core."
    fi
    popd
}

function configure_neslibretro() {
    mkdir -p $romdir/nes

    setESSystem "Nintendo Entertainment System" "nes" "~/RetroPie/roms/nes" ".nes .NES" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/fceu-next/fceumm-code/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/nes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "nes" "nes"
}