rp_module_id="hatari"
rp_module_desc="Atari emulator Hatari"
rp_module_menus="2+"

function install_hatari() {
    aptInstall hatari
    mkdir -p $romdir/atariststefalcon
}