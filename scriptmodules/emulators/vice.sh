rp_module_id="vice"
rp_module_desc="C64 emulator VICE"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_vice() {
    if hasPackage vice; then
        printf 'Package vice is already installed - removing package\n' "${1}"
        apt-get remove -y vice
    fi
    getDepends libxaw7-dev automake checkinstall
}

function sources_vice() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/vice-2.4.tar.gz | tar -xvz --strip-components=1
}

function build_vice() {
    ./configure --prefix="$md_inst" --enable-sdlui --without-pulse --with-sdlsound
    sed -i "s/#define HAVE_HWSCALE/#undef HAVE_HWSCALE/" src/config.h
    make
}

function install_vice() {
    make install
}

function configure_vice() {
    mkRomDir "c64"

    mkdir -p "$rootdir/configs/c64/"
    chown $user:$user "$rootdir/configs/c64/"

    [[ ! -f "$rootdir/configs/c64/vice.cfg" ]] && echo "[C64]" > "$rootdir/configs/c64/vice.cfg"
    chown $user:$user "$rootdir/configs/c64/vice.cfg"

    iniConfig "=" "" "$rootdir/configs/c64/vice.cfg"
    iniSet "SDLBitdepth" "8"
    iniSet "Mouse" "1"
    iniSet "VICIIFilter" "0"
    iniSet "VICIIVideoCache" "0"
    iniSet "SoundDeviceName" "alsa"
    iniSet "SoundSampleRate" "22050"
    iniSet "Drive8Type" "1542"
    iniSet "SidEngine" "0"
    iniSet "AutostartWarp" "0"
    iniSet "WarpMode" "0"

    configure_dispmanx_on_vice
    setDispmanx "$md_id" 1

    setESSystem "C64" "c64" "~/RetroPie/roms/c64" ".crt .CRT .d64 .D64 .g64 .G64 .t64 .T64 .tap .TAP .x64 .X64 .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/x64 -config $rootdir/configs/c64/vice.cfg %ROM%\" \"$md_id\"" "c64" "c64"
}

function configure_dispmanx_off_vice() {
    iniConfig "=" "" "$rootdir/configs/c64/vice.cfg"
    iniSet "VICIIDoubleSize" "1"
    iniSet "VICIIDoubleScan" "1"
}

function configure_dispmanx_on_vice() {
    iniConfig "=" "" "$rootdir/configs/c64/vice.cfg"
    iniSet "VICIIDoubleSize" "0"
    iniSet "VICIIDoubleScan" "0"
}