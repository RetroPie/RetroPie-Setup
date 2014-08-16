rp_module_id="pocketsnes"
rp_module_desc="SNES LibretroCore PocketSNES"
rp_module_menus="2+"

function sources_pocketsnes() {
    gitPullOrClone "$rootdir/emulatorcores/pocketsnes-libretro" git://github.com/ToadKing/pocketsnes-libretro.git
    pushd "$rootdir/emulatorcores/pocketsnes-libretro"
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch $rootdir/emulatorcores/pocketsnes-libretro/src/ppu.cpp
    popd
}

function build_pocketsnes() {
    pushd "$rootdir/emulatorcores/pocketsnes-libretro"
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES core."
    fi
    popd
}

function configure_pocketsnes() {
    mkdir -p $romdir/snes

    rps_retronet_prepareConfig
    setESSystem "Super Nintendo" "snes" "~/RetroPie/roms/snes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/pocketsnes-libretro/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/snes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\"" "snes" "snes"
    # <!-- alternatively: <command>$rootdir/emulators/snes9x-rpi/snes9x %ROM%</command> -->
    # <!-- alternatively: <command>$rootdir/emulators/pisnes/snes9x %ROM%</command> -->
}