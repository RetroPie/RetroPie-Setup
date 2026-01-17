#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ags"
rp_module_desc="Adventure Game Studio - Adventure game engine"
rp_module_help="ROM Extension: .exe\n\nCopy your Adventure Game Studio roms to $romdir/ags/<game>/"
rp_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
rp_module_repo="git https://github.com/adventuregamestudio/ags.git release-3.6.0"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_ags() {
    getDepends libsdl2-dev cmake pkg-config libaldmb1-dev libfreetype6-dev libtheora-dev libvorbis-dev libogg-dev liballegro4-dev
}

function sources_ags() {
    gitPullOrClone
}

function build_ags() {
    cmake -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DAGS_USE_LOCAL_ALL_LIBRARIES=ON \
        -DAGS_USE_LOCAL_SDL2_SOUND=OFF \
        -DCMAKE_BUILD_TYPE=Release
    make -C Engine clean
    make -C Engine
    md_ret_require="$md_build/ags"
}

function install_ags() {
    make -C Engine install
    # install Eawpatches GUS patch set (see: http://liballeg.org/digmid.html)
    download "http://www.eglebbk.dds.nl/program/download/digmid.dat" - | bzcat >"$md_inst/bin/patches.dat"
}

function configure_ags() {
    local launcher="$md_inst/launch_ags.sh"

    moveConfigDir "$home/.local/share/ags" "$md_conf_root/ags"
    mkRomDir "ags"

    if [[ "$md_mode" == "install" ]]; then
        _create_launcher_ags "$launcher"
    fi

    addEmulator 1 "$md_id" "ags" "bash '$launcher' %ROM%" "Adventure Game Studio" ".exe"
    addSystem "ags"
}

function _create_launcher_ags() {
    local launcher="$1"
    local binary="$md_inst/bin/ags"
    local params=(
        "--fullscreen"
        "--gfxdriver ogl"
    )

    cat > "$launcher" << _EOF_
#! /usr/bin/env bash

# ROM usually denotes ".../roms/ags/<something>.exe" whereas the game files are
# expected in "<something>/" subfolder. <something>.exe and <something>/ are
# expected to be sibling in the $romdir/ags folder.
ROM=\$1
fn="\${ROM##*/}"
subfolder="\${fn%.*}"
path="\${ROM%/*}"

# only hint the emulator to the subfolder if it exists, because some games
# can be run with a single AGS exe and do not require a game subfolder
if [[ -d "\$path/\$subfolder/" ]] ; then
    ROM="\$path/\$subfolder/"
fi

echo "ROM parameter for AGS engine: \$ROM" >> /dev/shm/runcommand.log
$binary "${params[*]}" "\$ROM"
_EOF_

    chown "$__user":"$__group" "$launcher"
    chmod u+x "$launcher"
}
