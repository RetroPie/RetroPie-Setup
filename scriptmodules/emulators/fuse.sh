rp_module_id="fuse"
rp_module_desc="ZXSpectrum emulator Fuse"
rp_module_menus="2+"

function install_fuse() {
    aptInstall spectrum-roms fuse-emulator-utils fuse-emulator-common
}