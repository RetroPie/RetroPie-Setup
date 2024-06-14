#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="zesarux"
rp_module_desc="ZX Spectrum emulator ZEsarUX"
rp_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
rp_module_licence="GPL3 https://raw.githubusercontent.com/chernandezba/zesarux/master/src/LICENSE"
rp_module_repo="git https://github.com/chernandezba/zesarux.git ZEsarUX-11.0"
rp_module_section="opt"
rp_module_flags="sdl2 sdl1-videocore"

function depends_zesarux() {
    local depends=(libssl-dev libpthread-stubs0-dev libasound2-dev)
    isPlatform "x11" && depends+=(libpulse-dev)

    if isPlatform "videocore"; then
        depends+=(libsdl1.2-dev)
    else
        depends+=(libsdl2-dev)
    fi

    getDepends "${depends[@]}"
}

function sources_zesarux() {
    gitPullOrClone
}

function build_zesarux() {
    local params=()
    isPlatform "videocore" && params+=(--enable-raspberry)
    ! isPlatform "x11" && params+=(--disable-pulse)
    ! isPlatform "videocore" && params+=(--enable-sdl2)

    cd src
    ./configure --prefix "$md_inst" "${params[@]}" --enable-ssl
    make clean
    make
    md_ret_require="$md_build/src/zesarux"
}

function install_zesarux() {
    cd src
    make install
}


function configure_zesarux() {
    mkRomDir "zxspectrum"
    mkRomDir "amstradcpc"
    mkRomDir "samcoupe"

    mkUserDir "$md_conf_root/zxspectrum"

    cat > "$romdir/zxspectrum/+Start ZEsarUX.sh" << _EOF_
#!/bin/bash
"$md_inst/bin/zesarux" "\$@"
_EOF_
    chmod +x "$romdir/zxspectrum/+Start ZEsarUX.sh"
    chown $user:$user "$romdir/zxspectrum/+Start ZEsarUX.sh"

    moveConfigFile "$home/.zesaruxrc" "$md_conf_root/zxspectrum/.zesaruxrc"

    local ao="sdl"
    isPlatform "x11" && ao="pulse"
    local config="$(mktemp)"

    cat > "$config" << _EOF_
;ZEsarUX sample configuration file
;
;Lines beginning with ; or # are ignored

;Run zesarux with --help or --experthelp to see all the options
--disableborder
--disablefooter
--vo sdl
--ao $ao
--hidemousepointer
--fullscreen

--smartloadpath $romdir/zxspectrum

--joystickemulated Kempston

;Remap Fire Event. Uncomment and amend if you wish to change the default button 3.
;--joystickevent 3 Fire
;Remap On-screen keyboard. Uncomment and amend if you wish to change the default button 5.
;--joystickevent 5 Osdkeyboard
_EOF_

    copyDefaultConfig "$config" "$md_conf_root/zxspectrum/.zesaruxrc"
    rm "$config"

    isPlatform "videocore" && setBackend "$md_id" "dispmanx"

    addEmulator 1 "$md_id" "zxspectrum" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh %ROM%"
    addEmulator 1 "$md_id" "samcoupe" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh --machine sam %ROM%"
    addEmulator 1 "$md_id" "amstradcpc" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh --machine CPC464 %ROM%"
    addSystem "zxspectrum"
    addSystem "samcoupe"
    addSystem "amstradcpc"
}
