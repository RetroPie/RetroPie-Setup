#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="scummvm"
rp_module_desc="ScummVM"
rp_module_help="Copy your ScummVM games to $romdir/scummvm"
rp_module_licence="GPL3 https://raw.githubusercontent.com/scummvm/scummvm/master/COPYING"
rp_module_repo="git https://github.com/scummvm/scummvm.git v2.8.1"
rp_module_section="opt"
rp_module_flags="sdl2"

function depends_scummvm() {
    local depends=(
        liba52-0.7.4-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libgif-dev libmad0-dev libpng-dev
        libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev zlib1g-dev
        libjpeg-dev libasound2-dev libcurl4-openssl-dev libmikmod-dev libvpx-dev
    )
    if isPlatform "vero4k"; then
        depends+=(vero3-userland-dev-osmc)
    fi
    if [[ "$md_id" == "scummvm-sdl1" ]]; then
        depends+=(libsdl1.2-dev)
    else
        depends+=(libsdl2-dev)
    fi
    getDepends "${depends[@]}"
}

function sources_scummvm() {
    gitPullOrClone
}

function build_scummvm() {
    rpSwap on 750
    local params=(
        --prefix="$md_inst"
        --enable-release --enable-vkeybd
        --disable-debug --disable-eventrecorder --disable-sonivox
    )
    isPlatform "rpi" && isPlatform "32bit" && params+=(--host=raspberrypi)
    isPlatform "rpi" && [[ "$md_id" == "scummvm-sdl1" ]] && params+=(--opengl-mode=none)
    # stop scummvm using arm-linux-gnueabihf-g++ which is v4.6 on
    # wheezy and doesn't like rpi2 cpu flags
    if isPlatform "rpi"; then
        if [[ "$md_id" == "scummvm-sdl1" ]]; then
            SDL_CONFIG=sdl-config CC="gcc" CXX="g++" ./configure "${params[@]}"
        else
            CC="gcc" CXX="g++" ./configure "${params[@]}"
        fi
    else
        ./configure "${params[@]}"
    fi
    make clean
    make
    strip "$md_build/scummvm"
    rpSwap off
    md_ret_require="$md_build/scummvm"
}

function install_scummvm() {
    make install
    mkdir -p "$md_inst/extra"
    cp -v backends/vkeybd/packs/vkeybd_*.zip "$md_inst/extra"
}

function configure_scummvm() {
    mkRomDir "scummvm"

    local dir
    for dir in .config .local/share; do
        moveConfigDir "$home/$dir/scummvm" "$md_conf_root/scummvm"
    done

    # Create startup script
    rm -f "$romdir/scummvm/+Launch GUI.sh"
    local name="ScummVM"
    [[ "$md_id" == "scummvm-sdl1" ]] && name="ScummVM-SDL1"
    cat > "$romdir/scummvm/+Start $name.sh" << _EOF_
#!/bin/bash
game="\$1"
pushd "$romdir/scummvm" >/dev/null
if ! grep -qs extrapath "\$HOME/.config/scummvm/scummvm.ini"; then
    params="--extrapath="$md_inst/extra""
fi
$md_inst/bin/scummvm --fullscreen \$params --joystick=0 "\$game"
while read id desc; do
    echo "\$desc" > "$romdir/scummvm/\$id.svm"
done < <($md_inst/bin/scummvm --list-targets | tail -n +3)
popd >/dev/null
_EOF_
    chown $user:$user "$romdir/scummvm/+Start $name.sh"
    chmod u+x "$romdir/scummvm/+Start $name.sh"

    addEmulator 1 "$md_id" "scummvm" "bash $romdir/scummvm/+Start\ $name.sh %BASENAME%"
    addSystem "scummvm"
}
