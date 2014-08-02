rp_module_id="fbzx"
rp_module_desc="ZXSpectrum emulator FBZX"
rp_module_menus="2+"

function sources_fbzx() {
    rmDirExists "$rootdir/emulators/fbzx-2.10.0"
    wget -O fbzx-2.10.0.tar.bz2 http://www.rastersoft.com/descargas/fbzx-2.10.0.tar.bz2
    tar xvfj fbzx-2.10.0.tar.bz2  -C "$rootdir/emulators"
    rm fbzx-2.10.0.tar.bz2
}

function build_fbzx() {
    pushd "$rootdir/emulators/fbzx-2.10.0"
    make
    if [[ ! -f "$rootdir/emulators/fbzx-2.10.0/fbzx" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile FBZX."
    fi
    popd
}

function configure_fbzx() {
    mkdir -p $romdir/zxspectrum-fbzx

    setESSystem "ZX Spectrum" "zxspectrum-fbzx" "RetroPie/roms/zxspectrum-fbzx" "z80 .Z80 .ipf .IPF" "$rootdir/emulators/fbzx-2.10.0/fbzx %ROM%" "zxspectrum" "zxspectrum"
}