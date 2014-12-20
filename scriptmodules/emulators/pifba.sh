rp_module_id="pifba"
rp_module_desc="FBA emulator PiFBA"
rp_module_menus="2+"

function depends_pifba() {
    rps_checkNeededPackages libasound2-dev
}

function sources_pifba() {
    gitPullOrClone "$rootdir/emulators/pifba" https://code.google.com/p/pifba/ NS
}

function build_pifba() {
    pushd "$rootdir/emulators/pifba"
    sed -i "s/-lglib-2.0$/-lglib-2.0 -lasound -lrt/g" Makefile
    mkdir ".obj"
    make clean
    make
    if [[ ! -d "$rootdir/emulators/pifba/" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile PiFBA."
    fi
    popd
}

function install_pifba() {
    mkdir -p "$rootdir/emulators/pifba/installdir"

    cp "$rootdir/emulators/pifba/fba2x" "$rootdir/emulators/pifba/installdir/"
    cp "$rootdir/emulators/pifba/capex.cfg" "$rootdir/emulators/pifba/installdir/"
    cp "$rootdir/emulators/pifba/fba2x.cfg" "$rootdir/emulators/pifba/installdir/"
    cp "$rootdir/emulators/pifba/zipname.fba" "$rootdir/emulators/pifba/installdir/"
    cp "$rootdir/emulators/pifba/rominfo.fba" "$rootdir/emulators/pifba/installdir/"
    cp "$rootdir/emulators/pifba/FBACache_windows.zip" "$rootdir/emulators/pifba/installdir/"
    cp "$rootdir/emulators/pifba/fba_029671_clrmame_dat.zip" "$rootdir/emulators/pifba/installdir/"
    chown -R $user:$user "$rootdir/emulators/pifba/installdir/"
    mkdir -p "$rootdir/emulators/pifba/roms"
    mkdir -p "$rootdir/emulators/pifba/skin"
    mkdir -p "$rootdir/emulators/pifba/preview"

}

function configure_pifba() {
    mkdir -p "$romdir/fba"
    mkdir -p "$romdir/neogeo"

    setESSystem "Final Burn Alpha" "fba" "~/RetroPie/roms/fba" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/pifba/fba2x %ROM%\"" "arcade" ""
    setESSystem "NeoGeo" "neogeo" "~/RetroPie/roms/neogeo" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/pifba/fba2x %ROM%\"" "neogeo" "neogeo"

}
