rp_module_id="pifba"
rp_module_desc="FBA emulator PiFBA"
rp_module_menus="2+"

function depends_pifba() {
    getDepends libasound2-dev
}

function sources_pifba() {
    gitPullOrClone "$md_build" https://code.google.com/p/pifba/
    sed -i "s/-lglib-2.0$/-lglib-2.0 -lasound -lrt/g" Makefile
}

function build_pifba() {
    mkdir ".obj"
    make clean
    make
    md_ret_require="$md_build/fba2x"
}

function install_pifba() {
    mkdir "$md_inst/"{roms,skin,preview}
    md_ret_files=(
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
    chown -R $user:$user "$md_inst"
    mkRomDir "fba"
    mkRomDir "neogeo"

    setESSystem "Final Burn Alpha" "fba" "~/RetroPie/roms/fba" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/fba2x %ROM%\" \"$md_id\"" "arcade" ""
    setESSystem "NeoGeo" "neogeo" "~/RetroPie/roms/neogeo" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/fba2x %ROM%\" \"$md_id\"" "neogeo" "neogeo"

}
