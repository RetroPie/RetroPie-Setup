rp_module_id="uae4all"
rp_module_desc="Amiga emulator UAE4All"
rp_module_menus="2+"

# Amiga emulator UAE4All

function sources_uae4all() {
    rmDirExists "$rootdir/emulators/uae4rpi"
    mkdir -p "$rootdir/emulators"
    wget http://downloads.petrockblock.com/retropiearchives/uae4rpi.tar.bz2
    tar -jxvf uae4rpi.tar.bz2 -C "$rootdir/emulators/"
    rm uae4rpi.tar.bz2
}

function build_uae4all() {
    pushd "$rootdir/emulators/uae4rpi"
    if [[ ! -f /opt/vc/include/interface/vmcs_host/vchost_config.h ]]; then
        touch /opt/vc/include/interface/vmcs_host/vchost_config.h
    fi
    make
    if [[ ! -f "$rootdir/emulators/uae4rpi/uae4all" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Amiga emulator."
    fi
    popd
}

function configure_uae4all() {
    mkdir -p "$romdir/amiga"

    cat > "$rootdir/emulators/uae4rpi/startAmigaDisk.sh" << _EOF_
#!/bin/bash
pushd "$rootdir/emulators/uae4rpi/"
rm df0.adf
ln -s "$romdir/amiga/$1" "df0.adf"
./uae4all    
popd
_EOF_
    chmod +x "$rootdir/emulators/uae4rpi/startAmigaDisk.sh"
    setESSystem "Amiga" "amiga" "~/RetroPie/roms/amiga" ".adf .ADF" "$rootdir/emulators/uae4rpi/startAmigaDisk.sh %ROM%" "amiga" "amiga"
}