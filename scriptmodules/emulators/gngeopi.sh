rp_module_id="gngeopi"
rp_module_desc="NeoGeo emulator GnGeoPi"
rp_module_menus="2+"

function depends_gngeopi() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_gngeopi() {
    gitPullOrClone "$rootdir/emulators/gngeo-pi-0.85" https://github.com/ymartel06/GnGeo-Pi.git
}

function build_gngeopi() {
    pushd "$rootdir/emulators/gngeo-pi-0.85/gngeo"
    chmod +x configure
    ./configure --disable-i386asm --prefix="$rootdir/emulators/gngeo-pi-0.85/installdir"
    make
    popd
}

function install_gngeopi() {
    pushd "$rootdir/emulators/gngeo-pi-0.85/gngeo"
    make install
    if [[ ! -f "$rootdir/emulators/gngeo-pi-0.85/installdir/bin/gngeo" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile GnGeo-Pi emulator."
    fi
    popd
    mkdir -p "$rootdir/emulators/gngeo-pi-0.85/neogeobios"
}

function configure_gngeopi() {
    mkdir -p "$romdir/neogeo-gngeopi"

    setESSystem "NeoGeo" "neogeo-gngeopi" "~/RetroPie/roms/neogeo-gngeopi" ".zip .ZIP .fba .FBA" "$rootdir/emulators/gngeo-pi-0.85/installdir/bin/gngeo -i $romdir/neogeo-gngeopi -B $rootdir/emulators/gngeo-pi-0.85/neogeobios %ROM%" "neogeo" "neogeo"
}
