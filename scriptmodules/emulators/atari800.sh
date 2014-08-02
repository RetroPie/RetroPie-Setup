rp_module_id="atari800"
rp_module_desc="Atari 800 emulator"
rp_module_menus="2+"

function sources_atari800() {
    wget -O atari800-3.0.0.tar.gz http://sourceforge.net/projects/atari800/files/atari800/3.0.0/atari800-3.0.0.tar.gz/download
    rmDirExists "$rootdir/emulators/atari800-3.0.0"
    tar xvfz atari800-3.0.0.tar.gz -C "$rootdir/emulators/"
    rm atari800-3.0.0.tar.gz
}

function build_atari800() {
    pushd "$rootdir/emulators/atari800-3.0.0/src"
    mkdir -p "$rootdir/emulators/atari800-3.0.0/installdir"
    ./configure --prefix="$rootdir/emulators/atari800-3.0.0/installdir"
    make
    popd
}

function install_atari800() {
    pushd "$rootdir/emulators/atari800-3.0.0/src"
    make install
    if [[ ! -f "$rootdir/emulators/atari800-3.0.0/installdir/bin/atari800" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 800 emulator."
    fi
    popd
}

function configure_atari800() {
    mkdir -p "$romdir/atari800"

    setESSystem "Atari 800" "atari800" "~/RetroPie/roms/atari800" ".xex .XEX" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/atari800-3.0.0/installdir/bin/atari800 %ROM%\"" "atari800" "atari800"
}