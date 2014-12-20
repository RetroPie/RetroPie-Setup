rp_module_id="openmsx"
rp_module_desc="MSX emulator OpenMSX"
rp_module_menus="4+"

function depends_openmsx() {
    rps_checkNeededPackages libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev
}

function sources_openmsx() {
    wget http://downloads.petrockblock.com/retropiearchives/openmsx-0.10.0.tar.gz
    mkdir -p "$rootdir/emulators"
    tar xvfz openmsx-0.10.0.tar.gz  -C "$rootdir/emulators"
    rm openmsx-0.10.0.tar.gz
}

function build_openmsx() {
    rpSwap on 512

    pushd "$rootdir/emulators/openmsx-0.10.0"
    ./configure
    make
    popd

    rpSwap off
}

function configure_openmsx() {
    mkdir -p $romdir/msx
    wget http://downloads.petrockblock.com/retropiearchives/openmsxroms.zip
    mkdir -p "$home/.openMSX/share/systemroms/"
    chown -R $user:$user "$home/.openMSX/share/systemroms/"
    unzip openmsxroms.zip "$home/.openMSX/share/systemroms/"
    rm openmsxroms.zip

    setESSystem "MSX / MSX2" "msx" "~/RetroPie/roms/msx" ".rom .ROM .mx2 .MX2 .mx1 .MX1" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/openmsx-0.10.0/derived/arm-linux-opt/bin/openmsx -cart %ROM%\"" "" "msx"
}