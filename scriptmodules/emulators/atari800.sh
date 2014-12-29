rp_module_id="atari800"
rp_module_desc="Atari 800 emulator"
rp_module_menus="2+"

function sources_atari800() {
    wget -q -O- "http://downloads.petrockblock.com/retropiearchives/atari800-3.0.0.tar.gz" | tar -xvz --strip-components=1
}

function build_atari800() {
    cd src
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/src/atari800"
}

function install_atari800() {
    cd src
    make install
}

function configure_atari800() {
    mkRomDir "atari800"

    setESSystem "Atari 800" "atari800" "~/RetroPie/roms/atari800" ".xex .XEX" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/atari800 %ROM%\" \"$md_id\"" "atari800" "atari800"
}