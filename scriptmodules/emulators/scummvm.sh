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
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_scummvm() {
    getDepends libsdl1.2-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev libpng12-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev zlib1g-dev
    if [[ "$__raspbian_ver" -lt "8" ]]; then
        getDepends libjpeg8-dev
    else
        getDepends libjpeg-dev
    fi
}

function sources_scummvm() {
    wget -O- -q $__archive_url/scummvm-1.7.0.tar.gz | tar -xvz --strip-components=1
}

function build_scummvm() {
    ./configure --enable-vkeybd --enable-release --disable-debug --enable-keymapper --disable-eventrecorder --prefix="$md_inst"
    make clean
    make
    strip "$md_build/scummvm"
    md_ret_require="$md_build/scummvm"
}

function install_scummvm() {
    make install
    mkdir -p "$md_inst/extra"
    cp -v backends/vkeybd/packs/vkeybd_*.zip "$md_inst/extra"
}

function configure_scummvm() {
    mkRomDir "scummvm"

    moveConfigDir "$home/.scummvm" "$configdir/scummvm"

    # Create startup script
    rm -f "$romdir/scummvm/+Launch GUI.sh"
    cat > "$romdir/scummvm/+Start ScummVM.sh" << _EOF_
#!/bin/bash
game="\$1"
[[ "\$game" =~ ^\+ ]] && game=""
$md_inst/bin/scummvm --joystick=0 --extrapath="$md_inst/extra" \$game
while read line; do
    id=(\$line);
    touch "$romdir/scummvm/\$id.svm"
done < <($md_inst/bin/scummvm --list-targets | tail -n +3)
_EOF_
    chown $user:$user "$romdir/scummvm/+Start ScummVM.sh"
    chmod u+x "$romdir/scummvm/+Start ScummVM.sh"

    addSystem 1 "$md_id" "scummvm" "$romdir/scummvm/+Start\ ScummVM.sh %BASENAME%" "ScummVM" ".sh .svm"
}
