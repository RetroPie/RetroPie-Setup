#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="zesarux"
rp_module_desc="ZX Spectrum emulator ZEsarUX"
rp_module_menus="4+"
rp_module_flags="dispmanx"

function depends_zesarux() {
    getDepends libssl-dev libpthread-stubs0-dev libsdl1.2-dev libasound2-dev
}

function sources_zesarux() {
    wget -O- -q "http://downloads.petrockblock.com/retropiearchives/ZEsarUX_src-3.0.tar.gz" | tar -xvz --strip-components=1
}

function build_zesarux() {
    ./configure --enable-raspberry --prefix "$md_inst"
    make clean
    make
    md_ret_require="$md_build/zesarux"
}

function install_zesarux() {
    make install
}


function configure_zesarux() {
    mkRomDir "zxspectrum"

    mkUserDir "$romdir/zxspectrum"

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

    ln -sf "$configdir/zxspectrum/.zesaruxrc" "$home/.zesaruxrc"

    cat > "$configdir/zxspectrum/.zesaruxrc" << _EOF_
;ZEsarUX sample configuration file
;
;Lines beginning with ; or # are ignored

;Run zesarux with --help or --experthelp to see all the options
--disableborder
--disablefooter
--vo sdl
--ao alsa
--hidemousepointer

--smartloadpath $romdir/zxspectrum

--joystickemulated Kempston

;Remap Fire Event. Uncomment and amend if you wish to change the default button 3.
;--joystickevent 3 Fire
_EOF_

    chown $user:$user "$configdir/zxspectrum/.zesaruxrc"

    setDispmanx "$md_id" 1

    addSystem 1 "$md_id" "zxspectrum" "$romdir/zxspectrum/+Start\ ZEsarUX.sh %ROM%" "" ".sh"
}