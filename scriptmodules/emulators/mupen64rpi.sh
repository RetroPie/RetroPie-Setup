rp_module_id="mupen64rpi"
rp_module_desc="N64 emulator MUPEN64Plus-RPi"
rp_module_menus="4+"

function sources_mupen64rpi() {
    gitPullOrClone "$rootdir/emulators/mupen64plus" https://github.com/ricrpi/mupen64plus
}

function build_mupen64rpi() {
    rpSwap on 750

    pushd "$rootdir/emulators/mupen64plus"
    ./build.sh
    ./install.sh
    if [[ ! -f "$rootdir/emulators/mupen64plus" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Mupen 64 Plus RPi."
    fi
    popd
    
    # to solve startup problems delete old config file 
    rm /home/pi/.config/mupen64plus/mupen64plus.cfg

    rpSwap off
}

function configure_mupen64rpi() {
    mkdir -p "$romdir/n64"

    setESSystem "Nintendo 64" "n64" "~/RetroPie/roms/n64" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"mupen64plus %ROM%\"" "n64" "n64"
}
