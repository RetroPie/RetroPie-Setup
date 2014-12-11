rp_module_id="gngeopi"
rp_module_desc="NeoGeo emulator GnGeoPi"
rp_module_menus="2+"

function depends_gngeopi() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_gngeopi() {
    gitPullOrClone "$builddir/$1" https://github.com/ymartel06/GnGeo-Pi.git
}

function build_gngeopi() {
    cd gngeo
    chmod +x configure
    ./configure --disable-i386asm --prefix="$emudir/$1"
    make clean
    make
}

function install_gngeopi() {
    cd gngeo
    make install
    mkdir -p "$emudir/$1/neogeobios"
    require="$emudir/$1/bin/gngeo"
}

function configure_gngeopi() {
    mkdir -p "$romdir/neogeo-gngeopi"

    setESSystem "NeoGeo" "neogeo-gngeopi" "~/RetroPie/roms/neogeo-gngeopi" ".zip .ZIP .fba .FBA" "$emudir/$1/bin/gngeo -i $romdir/neogeo-gngeopi -B $rootdir/emulators/gngeo-pi-0.85/neogeobios %ROM%" "neogeo" "neogeo"
}
