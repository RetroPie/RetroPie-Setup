rp_module_id="fbzx"
rp_module_desc="ZXSpectrum emulator FBZX"
rp_module_menus="2+"

function sources_fbzx() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/fbzx-2.10.0.tar.bz2 | tar -xvj --strip-components=1 
}

function build_fbzx() {
    make clean
    make
    md_ret_require="$md_build/fbzx"
}

function install_fbzx() {
    md_ret_files=(
        'AMSTRAD'
        'CAPABILITIES'
        'COPYING'
        'FAQ'
        'fbzx'
        'fbzx.desktop'
        'fbzx.svg'
        'INSTALL'
        'keymap.bmp'
        'PORTING'
        'README'
        'README.TZX'
        'spectrum-roms'
        'TODO'
        'VERSIONS'
    )
}

function configure_fbzx() {
    mkdir -p $romdir/zxspectrum-fbzx

    setESSystem "ZX Spectrum" "zxspectrum-fbzx" "RetroPie/roms/zxspectrum-fbzx" "z80 .Z80 .ipf .IPF" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/fbzx %ROM%\"" "zxspectrum" "zxspectrum"
}