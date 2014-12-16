rp_module_id="pocketsnes"
rp_module_desc="SNES LibretroCore PocketSNES"
rp_module_menus="2+"

function sources_pocketsnes() {
    gitPullOrClone "$md_build" git://github.com/ToadKing/pocketsnes-libretro.git
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch $rootdir/libretrocores/pocketsnes-libretro/src/ppu.cpp
}

function build_pocketsnes() {
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_pocketsnes() {
    md_ret_files=(
        'libretro.so'
        'README.txt'
    )
}

function configure_pocketsnes() {
    mkRomDir "snes"

    rps_retronet_prepareConfig
    setESSystem "Super Nintendo" "snes" "~/RetroPie/roms/snes" ".smc .sfc .fig .swc .SMC .SFC .FIG .SWC" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/bin/retroarch -L $md_instlibretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/snes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\"" "snes" "snes"
    # <!-- alternatively: <command>$emudir/snes9x-rpi/snes9x %ROM%</command> -->
    # <!-- alternatively: <command>$emudir/pisnes/snes9x %ROM%</command> -->
}