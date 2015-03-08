rp_module_id="doom"
rp_module_desc="Doom LibretroCore"
rp_module_menus="2+"

function sources_doom() {
    gitPullOrClone "$md_build" git://github.com/libretro/libretro-prboom.git
}

function build_doom() {
    make clean
    make
    md_ret_require="$md_build/prboom_libretro.so"
}

function install_doom() {
    md_ret_files=(
        'prboom_libretro.so'
        'prboom.wad'
    )
}

function configure_doom() {
    mkRomDir "ports/doom"
    ensureSystemretroconfig "doom"

    # system-specific shaders, doom
    iniConfig " = " "" "$configdir/doom/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/doom/"

    cp prboom.wad "$romdir/ports/doom/"

    # download doom 1 shareware
    wget "http://downloads.petrockblock.com/retropiearchives/doom1.wad" -O "$romdir/ports/doom/doom1.wad"

    chown $user:$user "$romdir/ports/doom/"*

    cat > "$romdir/ports/Doom 1 Shareware.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 1 "$emudir/retroarch/bin/retroarch -L $md_inst/prboom_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/doom/retroarch.cfg $romdir/ports/doom/doom1.wad" "$md_id"
_EOF_
    chmod +x "$romdir/ports/Doom 1 Shareware.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'    
}
