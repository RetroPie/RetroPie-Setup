rp_module_id="openmsx"
rp_module_desc="MSX emulator OpenMSX"
rp_module_menus="2+"

function depen_openmsx() {
    rps_checkNeededPackages libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev
}

function sources_openmsx() {
    wget http://downloads.sourceforge.net/project/openmsx/openmsx/0.10.0/openmsx-0.10.0.tar.gz
    tar xvfz openmsx-0.10.0.tar.gz  -C "$rootdir/emulators"
    rm openmsx-0.10.0.tar.gz
}

function build_openmsx() {
    pushd "$rootdir/emulators/openmsx-0.10.0"
    ./configure
    make
    popd
}

function configure_openmsx() {
    mkdir -p $romdir/msx
}