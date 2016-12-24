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
rp_module_help="Copy your ResidualVM roms to $romdir/residualvm"
rp_module_section="exp"
rp_module_flags="dispmanx !mali"

function depends_residualvm() {
    getDepends libsdl2-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev libpng12-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev zlib1g-dev libjpeg-dev
}

function sources_residualvm() {
    gitPullOrClone "$md_build" https://github.com/ResidualVM/ResidualVM.git
}

function build_residualvm() {
    SDL_CONFIG=sdl2-config LDFLAGS="-L/opt/vc/lib" ./configure \
        --force-opengles2 \
        --disable-glew \
        --enable-opengl-shaders \
        --enable-vkeybd \
        --enable-release \
        --disable-debug \
        --enable-keymapper \
        --prefix="$md_inst"
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

    moveConfigDir "$home/.residualvm" "$md_conf_root/residualvm"
    moveConfigFile "$home/.residualvmrc" "$md_conf_root/residualvm/residualvmrc"

    # Create startup script
    rm -f "$romdir/residualvm/+Launch GUI.sh"
    cat > "$romdir/residualvm/+Start ResidualVM.sh" << _EOF_
#!/bin/bash
renderer="\$1"
game="\$2"
[[ "\$game" =~ ^\+ ]] && game=""
pushd "$romdir/residualvm" >/dev/null
$md_inst/bin/residualvm --renderer=\$renderer --fullscreen --joystick=0 --extrapath="$md_inst/extra" \$game
while read line; do
    id=(\$line);
    touch "$romdir/residualvm/\$id.svm"
done < <($md_inst/bin/residualvm --list-targets | tail -n +3)
popd >/dev/null
_EOF_
    chown $user:$user "$romdir/residualvm/+Start ResidualVM.sh"
    chmod u+x "$romdir/residualvm/+Start ResidualVM.sh"

    addSystem 1 "$md_id" "residualvm" "bash $romdir/residualvm/+Start\ ResidualVM.sh opengl_shaders %BASENAME%" "ResidualVM" ".sh .svm"
    addSystem 1 "$md_id-software" "residualvm" "bash $romdir/residualvm/+Start\ ResidualVM.sh software %BASENAME%" "ResidualVM" ".sh .svm"
}
