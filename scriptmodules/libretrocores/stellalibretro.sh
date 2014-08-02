rp_module_id="stellalibretro"
rp_module_desc="Atari 2600 LibretroCore Stella"
rp_module_menus="2+"

function sources_stellalibretro() {
    gitPullOrClone "$rootdir/emulatorcores/stella-libretro" git://github.com/libretro/stella-libretro.git
}

function build_stellalibretro() {
    pushd "$rootdir/emulatorcores/stella-libretro"
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 2600 core."
    fi
    popd
}

function configure_stellalibretro() {
    mkdir -p $romdir/atari2600-libretro

    setESSystem "Atari 2600" "atari2600-libretro" "~/RetroPie/roms/atari2600-libretro" ".a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/stella-libretro/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/atari2600/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "atari2600" "atari2600"
}