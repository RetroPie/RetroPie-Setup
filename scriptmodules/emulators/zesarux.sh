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
rp_module_menus="4+"
rp_module_flags="dispmanx !mali"

function depends_zesarux() {
    local depends=(libssl-dev libpthread-stubs0-dev libsdl1.2-dev libasound2-dev)
    isPlatform "x11" && depends+=(libpulse-dev)
    getDepends "${depends[@]}"
}

function sources_zesarux() {
    wget -O- -q "$__archive_url/ZEsarUX_src-3.0.tar.gz" | tar -xvz --strip-components=1
}

function build_zesarux() {
    local params=()
    isPlatform "rpi" && params+=(--enable-raspberry --disable-pulse)
    ./configure --prefix "$md_inst" "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/zesarux"
}

function install_zesarux() {
    make install
}


function configure_zesarux() {
    mkRomDir "zxspectrum"

    mkUserDir "$md_conf_root/zxspectrum"

    cat > "$romdir/zxspectrum/+Start ZEsarUX.sh" << _EOF_
#!/bin/bash
params="\$1"
pushd "$md_inst/bin"
if [[ "\$params" =~ \.sh$ ]]; then
    ./zesarux
else
    ./zesarux "\$params"
fi
popd
_EOF_
    chmod +x "$romdir/zxspectrum/+Start ZEsarUX.sh"
    chown $user:$user "$romdir/zxspectrum/+Start ZEsarUX.sh"

    moveConfigFile "$home/.zesaruxrc" "$md_conf_root/zxspectrum/.zesaruxrc"

    local ao="alsa"
    isPlatform "x11" && ao="pulse"
    if [[ ! -f "$md_conf_root/zxspectrum/.zesaruxrc" ]]; then
        cat > "$md_conf_root/zxspectrum/.zesaruxrc" << _EOF_
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
_EOF_
        chown $user:$user "$md_conf_root/zxspectrum/.zesaruxrc"
    fi

    if isPlatform "rpi"; then
        setDispmanx "$md_id" 1
    fi

    addSystem 1 "$md_id" "zxspectrum" "$romdir/zxspectrum/+Start\ ZEsarUX.sh %ROM%" "" ".sh"
}
