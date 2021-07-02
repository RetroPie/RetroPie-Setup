#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="residualvm"
rp_module_desc="ResidualVM - A 3D Game Interpreter"
rp_module_help="Copy your ResidualVM games to $romdir/residualvm"
rp_module_licence="GPL2 https://raw.githubusercontent.com/residualvm/residualvm/master/COPYING"
rp_module_repo="git https://github.com/ResidualVM/ResidualVM.git master"
rp_module_section="exp"
rp_module_flags="sdl2 !mali"

function depends_residualvm() {
    local depends=(
        libsdl2-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev
        libpng-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev
        zlib1g-dev libjpeg-dev
    )
    isPlatform "x11" && depends+=(libglew-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_residualvm() {
    gitPullOrClone
}

function build_residualvm() {
    local params=(
        --enable-opengl-shaders
        --enable-vkeybd
        --enable-release
        --disable-debug
        --prefix="$md_inst"
    )
    if isPlatform "gles"; then
        params+=(--force-opengles2)
        # wintermute fails to build on rpi/opegles - disable for now
        params+=(--disable-engine=wintermute)
    fi
    if isPlatform "videocore"; then
        CXXFLAGS+=" -I/opt/vc/include" LDFLAGS+=" -L/opt/vc/lib" ./configure "${params[@]}"
    else
        ./configure "${params[@]}"
    fi

    make clean
    make
    strip "$md_build/residualvm"
    md_ret_require="$md_build/residualvm"
}

function install_residualvm() {
    make install
    mkdir -p "$md_inst/extra"
    cp -v backends/vkeybd/packs/vkeybd_*.zip "$md_inst/extra"
}

function configure_residualvm() {
    mkRomDir "residualvm"

    moveConfigDir "$home/.config/residualvm" "$md_conf_root/residualvm"

    # Create startup script
    cat > "$romdir/residualvm/+Start ResidualVM.sh" << _EOF_
#!/bin/bash
renderer="\$1"
[[ -z "\$renderer" ]] && renderer="software"
game="\$2"
[[ "\$game" =~ ^\+ ]] && game=""
pushd "$romdir/residualvm" >/dev/null
$md_inst/bin/residualvm --renderer=\$renderer --fullscreen --joystick=0 --extrapath="$md_inst/extra" \$game
while read id desc; do
    echo "\$desc" > "$romdir/residualvm/\$id.rvm"
done < <($md_inst/bin/residualvm --list-targets | tail -n +3)
popd >/dev/null
_EOF_
    chown $user:$user "$romdir/residualvm/+Start ResidualVM.sh"
    chmod u+x "$romdir/residualvm/+Start ResidualVM.sh"

    addEmulator 0 "$md_id" "residualvm" "bash $romdir/residualvm/+Start\ ResidualVM.sh opengl_shaders %BASENAME%"
    addEmulator 1 "$md_id-software" "residualvm" "bash $romdir/residualvm/+Start\ ResidualVM.sh software %BASENAME%"
    addSystem "residualvm" "ResidualVM" ".sh .rvm"
}
