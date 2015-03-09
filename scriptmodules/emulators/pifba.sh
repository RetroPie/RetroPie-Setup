rp_module_id="pifba"
rp_module_desc="FBA emulator PiFBA"
rp_module_menus="2+"

function depends_pifba() {
    getDepends libasound2-dev
}

function sources_pifba() {
    gitPullOrClone "$md_build" https://github.com/joolswills/pifba.git
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

    addSystem 1 "$md_id" "neogeo" "$md_inst/fba2x %ROM%"
    addSystem 1 "$md_id" "fba arcade" "$md_inst/fba2x %ROM%"
}
