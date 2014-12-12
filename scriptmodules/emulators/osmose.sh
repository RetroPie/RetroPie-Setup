rp_module_id="osmose"
rp_module_desc="Gamegear emulator Osmose"
rp_module_menus="2+"

function sources_osmose() {
    wget -O- -q 'http://downloads.petrockblock.com/retropiearchives/osmose-0.8.1%2Brpi20121122.tar.bz2?dl=1' | tar -xvj --strip-components=1
}

function build_osmose() {
    make clean
    make
    require="$md_build/osmose"
}

function install_osmose() {
    files=(
        'changes.txt'
        'license.txt'
        'osmose'
    )
}

function configure_osmose() {
    mkdir -p "$romdir/gamegear-osmose"
    mkdir -p "$romdir/mastersystem-osmose"

    setESSystem "Sega Game Gear" "gamegear-osmose" "~/RetroPie/roms/gamegear-osmose" ".gg .GG" "$md_inst/osmose %ROM% -joy -tv -fs" "gamegear" "gamegear"
    setESSystem "Sega Master System / Mark III" "mastersystem-osmose" "~/RetroPie/roms/mastersystem-osmose" ".sms .SMS" "$md_inst/osmose %ROM% -joy -tv -fs" "mastersystem" "mastersystem"
}