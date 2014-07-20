rp_module_id="stella"
rp_module_desc="Atari2600 emulator STELLA"
rp_module_menus="2+"

function install_stella()
{
    aptInstall stella
}

function configure_stella() {
    mkdir -p "$romdir/atari2600"
}