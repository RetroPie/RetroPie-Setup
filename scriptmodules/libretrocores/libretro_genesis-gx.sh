rp_module_id="libretro_genesis-plus-gx"
rp_module_desc="GameGear/MasterSystem/Genesis LibretroCore genesis-plus-gx"
rp_module_menus="2+"

function sources_libretro_genesis-plus-gx() {
    gitPullOrClone "$md_build" git://github.com/libretro/Genesis-Plus-GX.git
}

function build_libretro_genesis-plus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/genesis_plus_gx_libretro.so"
}

function install_libretro_genesis-plus-gx() {
    md_ret_files=(
        'genesis_plus_gx_libretro.so'
        'HISTORY.txt'
        'LICENSE.txt'
        'README.md'
    )
}

function configure_libretro_genesis-plus-gx() {
    mkRomDir "gamegear"
    mkRomDir "mastersystem-genesis-plus-gx"
    mkRomDir "megadrive-genesis-plus-gx"
    
    ensureSystemretroconfig "gamegear"
    ensureSystemretroconfig "mastersystem-genesis-plus-gx"
    ensureSystemretroconfig "megadrive-genesis-plus-gx"
    
    # system-specific shaders, gamegear
    iniConfig " = " "" "$configdir/gamegear/retroarch.cfg"
    iniSet "savefile_directory" "~/RetroPie/roms/gamegear"
    iniSet "savestate_directory" "~/RetroPie/roms/gamegear"

    # system-specific shaders, mastersystem
    iniConfig " = " "" "$configdir/mastersystem-genesis/retroarch.cfg"
    iniSet "savefile_directory" "~/RetroPie/roms/mastersystem-genesis-plus-gx"
    iniSet "savestate_directory" "~/RetroPie/roms/mastersystem-genesis-plus-gx"
    
    # system-specific shaders, megadrive
    iniConfig " = " "" "$configdir/megadrive-genesis-plus-gx/retroarch.cfg"
    iniSet "savefile_directory" "~/RetroPie/roms/megadrive-genesis-plus-gx"
    iniSet "savestate_directory" "~/RetroPie/roms/megadrive-genesis-plus-gx"
    
    setESSystem "Sega Master System / Mark III" "mastersystem-genesis" "~/RetroPie/roms/mastersystem-genesis" ".sms .SMS .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/genesis_plus_gx_libretro.so --config $configdir/mastersystem/retroarch.cfg %ROM%\" \"$md_id\"" "mastersystem" "mastersystem"
    setESSystem "Sega Game Gear" "gamegear" "~/RetroPie/roms/gamegear" ".gg .GG .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/genesis_plus_gx_libretro.so --config $configdir/gamegear/retroarch.cfg  %ROM%\" \"$md_id\"" "gamegear" "gamegear"
	setESSystem "Sega Mega Drive / Genesis" "megadrive-genesis-plus-gx" "~/RetroPie/roms/megadrive-genesis-plus-gx" ".smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/genesis_plus_gx_libretro.so --config $configdir/megadrive-genesis-plus-gx/retroarch.cfg %ROM%\" \"$md_id\"" "genesis,megadrive" "megadrive"
}