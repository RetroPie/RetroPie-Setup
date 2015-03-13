rp_module_id="lr-nxengine"
rp_module_desc="Cave Story engine clone - NxEngine port for libretro"
rp_module_menus="4+"

function sources_lr-nxengine() {
    gitPullOrClone "$md_build" git://github.com/libretro/nxengine-libretro.git
}

function build_lr-nxengine() {
    make clean
    make
    md_ret_require="$md_build/nxengine_libretro.so"
}

function install_lr-nxengine() {
    md_ret_files=(
        'nxengine_libretro.so'
    )
}

function configure_lr-nxengine() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/cavestory"

    mkRomDir "ports"
    ensureSystemretroconfig "cavestory"

    cat > "$romdir/ports/Cave Story.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 1 "$emudir/retroarch/bin/retroarch -L $md_inst/nxengine_libretro.so --config $configdir/cavestory/retroarch.cfg $md_inst/datafiles/Doukutsu.exe" "$md_id"
_EOF_
    chmod +x "$romdir/ports/Cave Story.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
