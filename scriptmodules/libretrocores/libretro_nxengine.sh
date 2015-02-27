rp_module_id="cavestory"
rp_module_desc="Cave Story LibretroCore"
rp_module_menus="4+"

function sources_cavestory() {
    gitPullOrClone "$md_build" git://github.com/libretro/nxengine-libretro.git
}

function build_cavestory() {
    make clean
    make
    md_ret_require="$md_build/nxengine_libretro.so"
}

function install_cavestory() {
    md_ret_files=(
        'nxengine_libretro.so'
    )
}

function configure_cavestory() {
    mkRomDir "ports"
    ensureSystemretroconfig "cavestory"

    # system-specific shaders, cavestory
    iniConfig " = " "" "$configdir/cavestory/retroarch.cfg"
    iniSet "savefile_directory" "~/RetroPie/roms/ports"
    iniSet "savestate_directory" "~/RetroPie/roms/ports"
    iniSet "input_remapping_directory" "$configdir/cavestory/"

    cat > "$romdir/ports/Cave Story.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 1 "$emudir/retroarch/bin/retroarch -L $md_inst/nxengine_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/cavestory/retroarch.cfg $md_inst/datafiles/Doukutsu.exe" "$md_id"
_EOF_
    chmod +x "$romdir/ports/Cave Story.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
