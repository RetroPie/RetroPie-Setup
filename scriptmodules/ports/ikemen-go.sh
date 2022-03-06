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
rp_module_desc="I.K.E.M.E.N GO - Clone of M.U.G.E.N to the Go programming language"
rp_module_licence="MIT https://raw.githubusercontent.com/Windblade-GR01/Ikemen-GO/master/License.txt"
rp_module_help="Copy characters, stages, screenpacks, etc. to $romdir/ports/ikemen-go\n\nConfig files can be found at $configdir/ports/ikemen-go/save"
rp_module_repo="git https://github.com/Windblade-GR01/Ikemen-GO.git master"
rp_module_section="exp"

function depends_ikemen-go() {
    rp_callModule golang-1.17 install_bin
    getDepends libgl1-mesa-dev xinit xorg libopenal-dev libgtk-3-dev libasound2-dev
}

function sources_ikemen-go() {
    gitPullOrClone
}

function build_ikemen-go() {
    local goroot="$(_get_goroot_golang-1.17)"
    "$goroot/bin/go" clean -modcache
    "$goroot/bin/go" build -v -tags al_cmpt -o Ikemen_GO ./src
    # grabs default screenpack and content required for the game to run; note that the screenpack has a CC-BY-NC 3.0 license
    git clone https://github.com/ikemen-engine/Ikemen_GO-Elecbyte-Screenpack.git elecbyte
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
    mkRomDir "ports/ikemen-go"
    addPort "$md_id" "ikemen-go" "I.K.E.M.E.N GO" "XINIT:$md_inst/ikemen-go.sh"

    moveConfigDir "$md_inst/chars" "$romdir/ports/ikemen-go/chars"
    moveConfigDir "$md_inst/stages" "$romdir/ports/ikemen-go/stages"
    moveConfigDir "$md_inst/data" "$romdir/ports/ikemen-go/data"
    moveConfigDir "$md_inst/external" "$romdir/ports/ikemen-go/external"
    moveConfigDir "$md_inst/font" "$romdir/ports/ikemen-go/font"

    mkUserDir "$romdir/ports/ikemen-go/sound"
    mkUserDir "$configdir/ports/ikemen-go/save"
    ln -sf "$romdir/ports/ikemen-go/sound" "$md_inst/sound"
    ln -sf "$configdir/ports/ikemen-go/save" "$md_inst/save"

    cat >"$md_inst/ikemen-go.sh" << _EOF_
#!/bin/bash
export MESA_GL_VERSION_OVERRIDE=2.1
xset -dpms s off s noblank
xterm -g 1x1+0-0 -e 'cd $md_inst && ./Ikemen_GO'
_EOF_
    chmod +x "$md_inst/ikemen-go.sh"
    chown -R $user:$user "$md_inst"
    chown -R $user:$user "$romdir/ports/ikemen-go/."
}
