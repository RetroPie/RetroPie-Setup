rp_module_id="armsnes"
rp_module_desc="SNES LibretroCore ARMSNES"
rp_module_menus="4+"

function sources_armsnes() {
    gitPullOrClone "$rootdir/emulatorcores/armsnes-libretro" git://github.com/rmaz/ARMSNES-libretro
    pushd "$rootdir/emulatorcores/armsnes-libretro"
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch $rootdir/emulatorcores/armsnes-libretro/src/ppu.cpp
    popd
}

function build_armsnes() {
    pushd "$rootdir/emulatorcores/armsnes-libretro"
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/armsnes-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES core."
    fi
    popd
}

function configure_armsnes() {
    mkdir -p $romdir/snes

    rps_retronet_prepareConfig
    setESSystem "Super Nintendo" "snes" "~/RetroPie/roms/snes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/bin/retroarch -L `find $rootdir/emulatorcores/armsnes-libretro/ -name \"libpocketsnes.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/snes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\"" "snes" "snes"
    # <!-- alternatively: <command>$rootdir/emulators/snes9x-rpi/snes9x %ROM%</command> -->
    # <!-- alternatively: <command>$rootdir/emulators/pisnes/snes9x %ROM%</command> -->
}
