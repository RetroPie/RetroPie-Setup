rp_module_id="openmsx"
rp_module_desc="MSX emulator OpenMSX"
rp_module_menus="4+"

function depends_openmsx() {
    rps_checkNeededPackages libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev
}

function sources_openmsx() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/openmsx-0.10.0.tar.gz | tar -xvz --strip-components=1
    sed -i "s|INSTALL_BASE:=/opt/openMSX|INSTALL_BASE:=$emudir/$1|" build/custom.mk
    sed -i "s|SYMLINK_FOR_BINARY:=true|SYMLINK_FOR_BINARY:=false|" build/custom.mk
}

function build_openmsx() {
    rpSwap on 256 240
    ./configure
    make clean
    make
    rpSwap off
}

function install_openmsx() {
    make install
}

function configure_openmsx() {
    mkdir -p "$romdir/msx"
    wget http://downloads.petrockblock.com/retropiearchives/openmsxroms.zip
    mkdir -p "$emudir/$1/share/systemroms/"
    unzip openmsxroms.zip -d "$emudir/$1/share/systemroms/"

    setESSystem "MSX / MSX2" "msx" "~/RetroPie/roms/msx" ".rom .ROM .mx2 .MX2 .mx1 .MX1" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/bin/openmsx -cart %ROM%\"" "" "msx"
}