rp_module_id="fmsx-libretro"
rp_module_desc="MSX LibretroCore fmsx"
rp_module_menus="2+"

function sources_fmsx-libretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/fmsx-libretro.git
}

function build_fmsx-libretro() {
    make clean
    make
    md_ret_require="$md_build/fmsx_libretro.so"
}

function install_fmsx-libretro() {
    md_ret_files=(
        'fmsx_libretro.so'
        'README.md'
        'fMSX/ROMs/CARTS.SHA'
        'fMSX/ROMs/CYRILLIC.FNT'
        'fMSX/ROMs/DISK.ROM'
        'fMSX/ROMs/FMPAC.ROM'
        'fMSX/ROMs/FMPAC16.ROM'
        'fMSX/ROMs/ITALIC.FNT'
        'fMSX/ROMs/KANJI.ROM'
        'fMSX/ROMs/MSX.ROM'
        'fMSX/ROMs/MSX2.ROM'
        'fMSX/ROMs/MSX2EXT.ROM'
        'fMSX/ROMs/MSX2P.ROM'
        'fMSX/ROMs/MSX2PEXT.ROM'
        'fMSX/ROMs/MSXDOS2.ROM'
        'fMSX/ROMs/PAINTER.ROM'
        'fMSX/ROMs/RS232.ROM'
    )
}

function configure_fmsx-libretro() {
    mkRomDir "msx"
    ensureSystemretroconfig "msx"
    
    # system-specific shaders, fmsx
    iniConfig " = " "" "$configdir/msx/retroarch.cfg"
    iniSet "savefile_directory" "~/RetroPie/roms/msx"
    iniSet "savestate_directory" "~/RetroPie/roms/msx"
    iniSet "input_remapping_directory" "$configdir/msx/"   
    
    # Copy bios files
    cp "$md_inst/"{*.ROM,*.FNT,*.SHA} "$biosdir/"
    chown $user:$user "$biosdir/"{*.ROM,*.FNT,*.SHA}

    setESSystem "MSX" "msx" "~/RetroPie/roms/msx" ".rom .ROM .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/fmsx_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/msx/retroarch.cfg %ROM%\" \"$md_id\"" "msx" "msx"
}
