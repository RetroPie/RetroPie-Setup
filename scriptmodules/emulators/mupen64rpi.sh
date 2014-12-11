rp_module_id="mupen64rpi"
rp_module_desc="N64 emulator MUPEN64Plus-RPi"
rp_module_menus="4+"

function sources_mupen64rpi() {
    gitPullOrClone "$builddir/$1" https://github.com/ricrpi/mupen64plus
}

function build_mupen64rpi() {
    rpSwap on 256 400
    ./build.sh
    rpSwap off

    require="$builddir/$1/mupen64plus"
}

function install_mupen64rpi() {
    ./install.sh
}

function configure_mupen64rpi() {
    # to solve startup problems delete old config file 
    rm /home/$user/.config/mupen64plus/mupen64plus.cfg

    mkdir -p "$romdir/n64"

    setESSystem "Nintendo 64" "n64" "~/RetroPie/roms/n64" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"mupen64plus %ROM%\"" "n64" "n64"
}
