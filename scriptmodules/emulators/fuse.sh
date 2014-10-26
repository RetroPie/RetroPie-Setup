rp_module_id="fuse"
rp_module_desc="ZXSpectrum emulator Fuse"
rp_module_menus="2+"

function install_fuse() {
    aptInstall spectrum-roms fuse-emulator-utils fuse-emulator-common
}

function configure_fuse() {
    mkdir -p "$romdir/zxspectrum"

    setESSystem "ZX Spectrum" "zxspectrum" "~/RetroPie/roms/zxspectrum" ".z80 .Z80 .ipf .IPF" "xinit fuse" "zxspectrum" "zxspectrum"
}