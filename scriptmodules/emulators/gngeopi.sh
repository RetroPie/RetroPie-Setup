rp_module_id="gngeopi"
rp_module_desc="NeoGeo emulator GnGeoPi"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_gngeopi() {
    getDepends libsdl1.2-dev
}

function sources_gngeopi() {
    gitPullOrClone "$md_build" https://github.com/ymartel06/GnGeo-Pi.git
}

function build_gngeopi() {
    cd gngeo
    chmod +x configure
    ./configure --disable-i386asm --prefix="$md_inst"
    make clean
    make
}

function install_gngeopi() {
    cd gngeo
    make install
    mkdir -p "$md_inst/neogeobios"
    md_ret_require="$md_inst/bin/gngeo"
}

function configure_gngeopi() {
    mkRomDir "neogeo-gngeopi"

    # add default controls for keyboard p1/p2
    mkdir -p "$home/.gngeo"
    cat > "$home/.gngeo/gngeorc" <<\_EOF_
p1control A=K122,B=K120,C=K97,D=K115,START=K49,COIN=K51,UP=K273,DOWN=K274,LEFT=K276,RIGHT=K275,MENU=K27
p2control A=K108,B=K59,C=K111,D=K112,START=K50,COIN=K52,UP=K264,DOWN=K261,LEFT=K260,RIGHT=K262,MENU=K27
_EOF_

    chown -R $user:$user "$home/.gngeo"

    setESSystem "NeoGeo" "neogeo-gngeopi" "~/RetroPie/roms/neogeo-gngeopi" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/gngeo -i $romdir/neogeo-gngeopi -B $md_inst/neogeobios %ROM%\" \"$md_id\"" "neogeo" "neogeo"

    __INFMSGS="$__INFMSGS You need to copy the NeoGeo BIOS (neogeo.zip) files to the roms folder '$romdir/neogeo-gngeopi'."
}
