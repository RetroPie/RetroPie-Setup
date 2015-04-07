#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

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

    mkUserDir "$configdir/c64"

    # copy any existing configs from ~/.vice and symlink the config folder to $configdir/c64/
    if [[ -d "$home/.vice" && ! -h "$home/.vice" ]]; then
        mv -v "$home/.vice/"* "$configdir/c64/"
        rm -rf "$home/.vice"
    fi

    ln -snf "$configdir/c64" "$home/.vice"

    # if we have an old config vice.cfg then move it to sdl-vicerc
    if [[ -f "$configdir/c64/vice.cfg" ]]; then
        mv -v "$configdir/c64/vice.cfg" "$configdir/c64/sdl-vicerc"
    elif [[ ! -f "$configdir/c64/sdl-vicerc" ]]; then
        echo "[C64]" > "$configdir/c64/sdl-vicerc"
    fi
    chown -R $user:$user "$configdir/c64"

    iniConfig "=" "" "$configdir/c64/sdl-vicerc"
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

    addSystem 1 "$md_id-x64" "c64" "$md_inst/bin/x64 %ROM%"
    addSystem 0 "$md_id-x64sc" "c64" "$md_inst/bin/x64sc %ROM%" 
    addSystem 0 "$md_id-x128" "c64" "$md_inst/bin/x128 %ROM%"
    addSystem 0 "$md_id-xpet" "c64" "$md_inst/bin/xpet %ROM%"
    addSystem 0 "$md_id-xplus4" "c64" "$md_inst/bin/xplus4 %ROM%"
    addSystem 0 "$md_id-xvic" "c64" "$md_inst/bin/xvic %ROM%"
}

function configure_dispmanx_off_vice() {
    local id
    for id in $md_id-x64 $md_id-x64sc $md_id-x128 $md_id-xpet $md_id-xplus4 $md_id-xvic; do
        setDispmanx "id" 0
    done
    iniConfig "=" "" "$configdir/c64/sdl-vicerc"
    iniSet "VICIIDoubleSize" "1"
    iniSet "VICIIDoubleScan" "1"
}

function configure_dispmanx_on_vice() {
    local id
    for id in $md_id-x64 $md_id-x64sc $md_id-x128 $md_id-xpet $md_id-xplus4 $md_id-xvic; do
        setDispmanx "$id" 1
    done
    iniConfig "=" "" "$configdir/c64/sdl-vicerc"
    iniSet "VICIIDoubleSize" "0"
    iniSet "VICIIDoubleScan" "0"
}