rp_module_id="stella"
rp_module_desc="Atari2600 emulator STELLA"
rp_module_menus="2+"

function install_stella()
{
    aptInstall stella
}

function configure_stella() {
    mkdir -p "$romdir/atari2600-stella"

    setESSystem "Atari 2600" "atari2600" "~/RetroPie/roms/atari2600-stella" ".a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"stella %ROM%\"" "atari2600" "atari2600"
}