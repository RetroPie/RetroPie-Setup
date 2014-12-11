rp_module_id="pifba"
rp_module_desc="FBA emulator PiFBA"
rp_module_menus="2+"

function depends_pifba() {
    rps_checkNeededPackages libasound2-dev
}

function sources_pifba() {
    gitPullOrClone "$builddir/$1" https://code.google.com/p/pifba/ NS
    sed -i "s/-lglib-2.0$/-lglib-2.0 -lasound -lrt/g" Makefile
}

function build_pifba() {
    mkdir ".obj"
    make clean
    make
    require="$builddir/$1/pifba"
}

function install_pifba() {
    mkdir "$emudir/$1/"{roms,skin,preview}
    files=(
        'fba2x'
        'capex.cfg'
        'fba2x.cfg'
        'zipname.fba'
        'rominfo.fba'
        'FBACache_windows.zip'
        'fba_029671_clrmame_dat.zip'
    )
}

function configure_pifba() {
    chown -R $user:$user "$emudir/$1"
    mkdir -p "$romdir/fba"
    mkdir -p "$romdir/neogeo"

    setESSystem "Final Burn Alpha" "fba" "~/RetroPie/roms/fba" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/pifba/fba2x %ROM%\"" "arcade" ""
    setESSystem "NeoGeo" "neogeo" "~/RetroPie/roms/neogeo" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/pifba/fba2x %ROM%\"" "neogeo" "neogeo"

}
