rp_module_id="atari800"
rp_module_desc="Atari 800 emulator"
rp_module_menus="2+"

function sources_atari800() {
    rmDirExists "$builddir/$1"
    mkdir -p "$builddir/$1"
    wget -O- "http://downloads.petrockblock.com/retropiearchives/atari800-3.0.0.tar.gz" | tar -xvz --strip-components=1 -C "$builddir/$1"
}

function build_atari800() {
    pushd "$builddir/$1/src"
    ./configure --prefix="$emudir/$1"
    make
    if [[ ! -f "atari800" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 800 emulator."
    fi
    popd
}

function install_atari800() {
    mkdir -p "$emudir/$1"
    pushd "$builddir/$1/src"
    make install
    popd
}

function configure_atari800() {
    mkdir -p "$romdir/atari800"

    setESSystem "Atari 800" "atari800" "~/RetroPie/roms/atari800" ".xex .XEX" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/$1/bin/atari800 %ROM%\"" "atari800" "atari800"
}