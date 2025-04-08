#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ikemen-go"
rp_module_desc="Ikemen GO - Clone of M.U.G.E.N to the Go programming language (0.98.2)"
rp_module_licence="MIT https://raw.githubusercontent.com/ikemen-engine/Ikemen-GO/master/License.txt"
rp_module_help="ROM Extensions: .mgn + folder\n\nCopy M.U.G.E.N/Ikemen games or contents to $romdir/mugen/game_name_here\n\nIn order to launch games, create a 'game_name_here.mgn' file in $romdir/mugen\n\n"
rp_module_repo="git https://github.com/SuperFromND/Ikemen-GO-98point2.git master"
rp_module_section="exp"

function depends_ikemen-go() {
    rp_callModule golang-1.17 install_bin
    getDepends libgl1-mesa-dev xinit xterm xorg libopenal-dev libgtk-3-dev libasound2-dev
}

function sources_ikemen-go() {
    gitPullOrClone
}

function build_ikemen-go() {
    local goroot="$(_get_goroot_golang-1.17)"
    "$goroot/bin/go" clean -modcache
    "$goroot/bin/go" build -v -tags al_cmpt -o Ikemen_GO ./src
    # grabs default screenpack and content required for the game to run; note that the screenpack has a CC-BY-NC 3.0 license
    git clone https://github.com/SuperFromND/Ikemen_GO-Elecbyte-Screenpack.git elecbyte
    md_ret_require="$md_build/Ikemen_GO"
}

function install_ikemen-go() {
    cp 'elecbyte/LICENCE.txt' 'ScreenpackLicense.txt'

    md_ret_files=(
        'Ikemen_GO'
        'License.txt'
        'ScreenpackLicense.txt'
        'data'
        'font'
        'external'
        'elecbyte/chars'
        'elecbyte/stages'
        'elecbyte/data'
        'elecbyte/font'
    )
}

function configure_ikemen-go() {
    mkRomDir "mugen"
    addEmulator 0 "$md_id" "mugen" "XINIT:$md_inst/ikemen-go.sh %BASENAME%"
    addSystem "mugen" "M.U.G.E.N" ".mgn"

    # creates a dummy file; used to launch games
    touch "$romdir/mugen/ikemen-go.mgn"

    moveConfigDir "$md_inst/chars" "$romdir/mugen/ikemen-go/chars"
    moveConfigDir "$md_inst/stages" "$romdir/mugen/ikemen-go/stages"
    moveConfigDir "$md_inst/data" "$romdir/mugen/ikemen-go/data"
    moveConfigDir "$md_inst/external" "$romdir/mugen/ikemen-go/external"
    moveConfigDir "$md_inst/font" "$romdir/mugen/ikemen-go/font"
    mkUserDir "$romdir/mugen/ikemen-go/sound"
    mkUserDir "$configdir/mugen/ikemen-go/save"

    cat >"$md_inst/ikemen-go.sh" << _EOF_
#!/bin/bash
BASENAME=\$1
export MESA_GL_VERSION_OVERRIDE=2.1
xset -dpms s off s noblank
cd "$romdir/mugen/\${BASENAME}" && xterm -g 1x1+0-0 -e '/opt/retropie/ports/ikemen-go/Ikemen_GO'
_EOF_
    chmod +x "$md_inst/ikemen-go.sh"
    chown -R $user:$user "$md_inst"
    chown -R $user:$user "$romdir/mugen/"
}
