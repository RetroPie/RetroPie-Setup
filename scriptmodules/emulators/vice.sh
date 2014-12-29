rp_module_id="vice"
rp_module_desc="C64 emulator VICE"
rp_module_menus="2+"

function depends_vice() {
    if ! checkForInstalledAPTPackage vice; then
        printf 'Package vice is already installed - removing package\n' "${1}"
        apt-get remove -y vice
    fi
    checkNeededPackages libxaw7-dev automake checkinstall
}

function sources_vice() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/vice-2.4.tar.gz | tar -xvz --strip-components=1
}

function build_vice() {
    ./configure --prefix="$md_inst" --enable-sdlui --without-pulse --with-sdlsound
    make
}

function install_vice() {
    make install
    
    # install c64 roms
    mkdir -p "$md_inst/lib/vice"
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/vice-1.5-roms.tar.gz | tar -xvz --strip-components=2 -C "$md_inst/lib/vice"
}

function configure_vice() {
    mkRomDir "c64"

    setESSystem "C64" "c64" "~/RetroPie/roms/c64" ".crt .CRT .d64 .D64 .g64 .G64 .t64 .T64 .tap .TAP .x64 .X64 .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$md_inst/bin/x64 -sdlbitdepth 16 %ROM%\" \"$md_id\"" "c64" "c64"

}