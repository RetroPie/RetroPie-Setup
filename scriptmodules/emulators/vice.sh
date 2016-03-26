#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="vice"
rp_module_desc="C64 emulator VICE"
rp_module_menus="2+"
rp_module_flags="dispmanx !mali"

function depends_vice() {
    if hasPackage vice; then
        printf 'Package vice is already installed - removing package\n' "${1}"
        apt-get remove -y vice
    fi
    getDepends libsdl1.2-dev libxaw7-dev automake checkinstall
}

function sources_vice() {
    wget -O- -q $__archive_url/vice-2.4.tar.gz | tar -xvz --strip-components=1
}

function build_vice() {
    local params=(--enable-sdlui)
    ! isPlatform "x11" && params+=(--without-pulse --with-sdlsound)
    ./configure --prefix="$md_inst" --prefix="$md_inst/lib" "${params[@]}"
    if ! isPlatform "x11"; then
        sed -i "s/#define HAVE_HWSCALE/#undef HAVE_HWSCALE/" src/config.h
    fi
    make
}

function install_vice() {
    make install
}

function configure_vice() {
    mkRomDir "c64"

    # copy any existing configs from ~/.vice and symlink the config folder to $md_conf_root/c64/
    moveConfigDir "$home/.vice" "$md_conf_root/c64"

    # on 64bit platforms lib64 is used and vice cannot find the roms there.
    if [[ -d "$md_inst/lib64" ]]; then
        ln -snf "$md_inst/lib64" "$md_inst/lib"
    fi

    # if we have an old config vice.cfg then move it to sdl-vicerc
    if [[ -f "$md_conf_root/c64/vice.cfg" ]]; then
        mv -v "$md_conf_root/c64/vice.cfg" "$md_conf_root/c64/sdl-vicerc"
    elif [[ ! -f "$md_conf_root/c64/sdl-vicerc" ]]; then
        echo "[C64]" > "$md_conf_root/c64/sdl-vicerc"
    fi
    chown -R $user:$user "$md_conf_root/c64"

    iniConfig "=" "" "$md_conf_root/c64/sdl-vicerc"
    if ! isPlatform "x11"; then
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
    fi

    if isPlatform "rpi"; then
        configure_dispmanx_on_vice
        setDispmanx "$md_id" 1
    fi

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
    iniConfig "=" "" "$md_conf_root/c64/sdl-vicerc"
    iniSet "VICIIDoubleSize" "1"
    iniSet "VICIIDoubleScan" "1"
}

function configure_dispmanx_on_vice() {
    local id
    for id in $md_id-x64 $md_id-x64sc $md_id-x128 $md_id-xpet $md_id-xplus4 $md_id-xvic; do
        setDispmanx "$id" 1
    done
    iniConfig "=" "" "$md_conf_root/c64/sdl-vicerc"
    iniSet "VICIIDoubleSize" "0"
    iniSet "VICIIDoubleScan" "0"
}
