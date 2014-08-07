rp_module_id="osmose"
rp_module_desc="Gamegear emulator Osmose"
rp_module_menus="2+"

function sources_osmose() {
    wget 'http://downloads.petrockblock.com/retropiearchives/osmose-0.8.1%2Brpi20121122.tar.bz2?dl=1' -O osmose.tar.bz2
    mkdir -p "$rootdir/emulators"
    tar -jxvf osmose.tar.bz2 -C "$rootdir/emulators/"
    rm osmose.tar.bz2
}

function build_osmose() {
    pushd "$rootdir/emulators/osmose-0.8.1+rpi20121122/"
    make clean
    make
    if [[ ! -f "$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile OsmMose."
    fi
    popd
}

function configure_osmose() {
    mkdir -p "$romdir/gamegear-osmose"
    mkdir -p "$romdir/mastersystem-osmose"

    setESSystem "Sega Game Gear" "gamegear-osmose" "~/RetroPie/roms/gamegear-osmose" ".gg .GG" "$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose %ROM% -joy -tv -fs" "gamegear" "gamegear"
    setESSystem "Sega Master System / Mark III" "mastersystem-osmose" "~/RetroPie/roms/mastersystem-osmose" ".sms .SMS" "$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose %ROM% -joy -tv -fs" "mastersystem" "mastersystem"
}