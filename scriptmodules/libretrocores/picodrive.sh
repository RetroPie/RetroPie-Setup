rp_module_id="picodrive"
rp_module_desc="Genesis LibretroCore Picodrive"
rp_module_menus="2+"

function sources_picodrive() {
    gitPullOrClone "$md_build" https://github.com/libretro/picodrive.git
    git submodule init
    git submodule update
}

function build_picodrive() {
    make clean
    make -f Makefile.libretro platform=armv6
    md_ret_require="$md_build/picodrive_libretro.so"
}

function install_picodrive() {
    md_ret_files=(
        'AUTHORS'
        'COPYING'
        'picodrive_libretro.so'
        'README'
    )
}

function configure_picodrive() {
    mkRomDir "megadrive"
    mkRomDir "mastersystem"
    mkRomDir "segacd"
    mkRomDir "sega32x"

    rps_retronet_prepareConfig
    setESSystem "Sega Master System / Mark III" "mastersystem" "~/RetroPie/roms/mastersystem" ".sms .SMS .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/picodrive_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/mastersystem/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\" \"$md_id\"" "mastersystem" "mastersystem"

    setESSystem "Sega Mega Drive / Genesis" "megadrive" "~/RetroPie/roms/megadrive" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/picodrive_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/megadrive/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\" \"$md_id\"" "genesis,megadrive" "megadrive"

    setESSystem "Sega CD" "segacd" "~/RetroPie/roms/segacd" ".smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/picodrive_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/segacd/retroarch.cfg  %ROM%\" \"$md_id\"" "segacd" "segacd"

    setESSystem "Sega 32X" "sega32x" "~/RetroPie/roms/sega32x" ".32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/picodrive_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/sega32x/retroarch.cfg  %ROM%\" \"$md_id\"" "sega32x" "sega32x"
}