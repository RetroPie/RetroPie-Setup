rp_module_id="osmose"
rp_module_desc="Gamegear emulator Osmose"
rp_module_menus="2+"

function sources_osmose() {
    gitPullOrClone "$md_build" https://github.com/joolswills/osmose-rpi.git
}

function build_osmose() {
    make clean
    make
    md_ret_require="$md_build/osmose"
}

function install_osmose() {
    md_ret_files=(
        'changes.txt'
        'license.txt'
        'osmose'
    )
}

function configure_osmose() {
    mkRomDir "gamegear-osmose"
    mkRomDir "mastersystem-osmose"

    setESSystem "Sega Game Gear" "gamegear-osmose" "~/RetroPie/roms/gamegear-osmose" ".gg .GG" "$md_inst/osmose %ROM% -tv -fs" "gamegear" "gamegear"
    setESSystem "Sega Master System / Mark III" "mastersystem-osmose" "~/RetroPie/roms/mastersystem-osmose" ".sms .SMS" "$rootdir/supplementary/runcommand/runcommand.sh \"$md_inst/osmose %ROM% -tv -fs\" \"$md_id\"" "mastersystem" "mastersystem"
}
