rp_module_id="fuse"
rp_module_desc="ZXSpectrum emulator Fuse"
rp_module_menus="2+"
rp_module_flags="dispmanx nobin"

function install_fuse() {
    aptInstall fuse-emulator-sdl fuse-emulator-utils fuse-emulator-common spectrum-roms
}

function configure_fuse() {
    mkRomDir "zxspectrum"

    setESSystem "ZX Spectrum" "zxspectrum" "~/RetroPie/roms/zxspectrum" ".sna .SNA .szx .SZX .z80 .Z80 .ipf .IPF .tap .TAP .tzx .TZX .gz .bz2 .udi .UDI .mgt .MGT .img .IMG .trd .TRD .scl .SCL .dsk .DSK" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"fuse-sdl\" \"$md_id\"" "zxspectrum" "zxspectrum"
}