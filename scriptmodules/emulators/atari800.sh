rp_module_id="atari800"
rp_module_desc="Atari 800 emulator"
rp_module_menus="2+"

function sources_atari800() {
    wget -q -O- "http://downloads.petrockblock.com/retropiearchives/atari800-3.0.0.tar.gz" | tar -xvz --strip-components=1
}

function build_atari800() {
    cd src
    ./configure --prefix="$emudir/$1"
    make
    if [[ ! -f "atari800" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 800 emulator."
    fi
}

function install_atari800() {
    cd src
    make install
}

function configure_atari800() {
    mkdir -p "$romdir/atari800"

    setESSystem "Atari 800" "atari800" "~/RetroPie/roms/atari800" ".xex .XEX" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/$1/bin/atari800 %ROM%\"" "atari800" "atari800"
}