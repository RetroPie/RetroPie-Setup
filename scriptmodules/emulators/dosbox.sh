rp_module_id="dosbox"
rp_module_desc="DOS Emulator Dosbox"
rp_module_menus="2+"

function install_dosbox() {
    aptInstall dosbox
}

function configure_dosbox() {
    mkdir -p "$romdir/pc"
}