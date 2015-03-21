rp_module_id="hatari"
rp_module_desc="Atari emulator Hatari"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_hatari() {
    getDepends libsdl1.2-dev zlib1g-dev libpng12-dev cmake libreadline-dev portaudio19-dev
    apt-get remove -y hatari
}

function sources_hatari() {
    wget -q -O- "http://downloads.petrockblock.com/retropiearchives/hatari-1.8.0.tar.bz2" | tar -xvj --strip-components=1
}

function build_hatari() {
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/src/hatari"
}

function install_hatari() {
    make install
}

function configure_hatari() {
    mkRomDir "atariststefalcon"

    # move any old configs to new location
    if [[ -d "$home/.hatari" && ! -h "$home/.hatari" ]]; then
        mv -v "$home/.hatari/"* "$configdir/atariststefalcon/"
        rmdir "$home/.hatari"
    fi

    ln -snf "$configdir/atariststefalcon" "$home/.hatari"

    setDispmanx "$md_id" 1

    setESSystem "Atari ST/STE/Falcon" "atariststefalcon" "~/RetroPie/roms/atariststefalcon" ".st .ST .stx .STX .img .IMG .rom .ROM" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/hatari %ROM%\" \"$md_id\"" "atarist" "atarist"
}
