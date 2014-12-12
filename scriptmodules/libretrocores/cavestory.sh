rp_module_id="cavestory"
rp_module_desc="Cave Story LibretroCore"
rp_module_menus="2+"

function sources_cavestory() {
    gitPullOrClone "$md_build" git://github.com/libretro/nxengine-libretro.git
}

function build_cavestory() {
    make clean
    make
    md_ret_require="nxengine_libretro.so"
}

function install_cavestory() {
    md_ret_files=(
        'nxengine_libretro.so'
    )
}

function configure_cavestory() {
    mkdir -p $romdir/ports

    cat > "$romdir/ports/Cave Story.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 1 "$emudir/$1/bin/retroarch -L $md_inst/nxengine_libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/cavestory/retroarch.cfg $rootdir/libretrocores/nxengine-libretro/datafiles/Doukutsu.exe"
_EOF_
    chmod +x "$romdir/ports/Cave Story.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}