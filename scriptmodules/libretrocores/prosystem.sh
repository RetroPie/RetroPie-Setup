rp_module_id="prosystem"
rp_module_desc="Atari Prosystem 7800 LibretroCore"
rp_module_menus="4+"

function sources_prosystem() {
    gitPullOrClone "$md_build" https://github.com/libretro/prosystem-libretro.git
}

function build_prosystem() {
    make clean
    make
    md_ret_require="$md_build/prosystem_libretro.so"
}

function install_prosystem() {
    md_ret_files=(
        'prosystem_libretro.so'
        'ProSystem.dat'
        'README.md'
    )
}

function configure_prosystem() {
    mkRomDir "atari7800"
    ensureSystemretroconfig "atari7800"

    # Copy bios files
    cp "$md_inst/ProSystem.dat" "$home/RetroPie/BIOS/"
    chown -R $user:$user "$home/RetroPie/BIOS/"
    
    # Copy optional bios file "7800 BIOS (U).rom" to BIOS folder.
    
    setESSystem "Atari Prosystem 7800" "atari7800" "~/RetroPie/roms/atari7800" ".A78 .a78 .BIN .bin" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/retroarch/bin/retroarch -L $md_inst/prosystem_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/atari7800/retroarch.cfg %ROM%\"" "atari7800" "atari7800"
}
