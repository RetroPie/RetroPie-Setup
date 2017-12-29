#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dosbox-sdl2"
rp_module_desc="DOS emulator (enhanced DOSBox fork)"
rp_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy your DOS games to $romdir/pc"
rp_module_licence="GPL2 https://sourceforge.net/p/dosbox/code-0/HEAD/tree/dosbox/trunk/COPYING"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_dosbox-sdl2() {
    depends_dosbox libsdl2-dev libsdl2-net-dev libfluidsynth-dev fluid-soundfont-gm
}

function sources_dosbox-sdl2() {
    gitPullOrClone "$md_build" "https://github.com/duganchen/dosbox.git"
    # use custom config filename & path to allow coexistence with regular dosbox
    sed -i "src/misc/cross.cpp" -e 's/~\/.dosbox/~\/.'$md_id'/g' \
       -e 's/DEFAULT_CONFIG_FILE "dosbox-"/DEFAULT_CONFIG_FILE "'$md_id'-"/g'
}

function build_dosbox-sdl2() {
    build_dosbox
}

function install_dosbox-sdl2() {
    install_dosbox
}

function configure_dosbox-sdl2() {
    configure_dosbox
    if [[ "$md_mode" == "install" ]]; then
        local config_path=$(su "$user" -c "\"$md_inst/bin/dosbox\" -printconf")
        if [[ -f "$config_path" ]]; then
            iniConfig "=" "" "$config_path"
            iniSet "fluid.driver" "alsa"
            iniSet "fluid.soundfont" "/usr/share/sounds/sf2/FluidR3_GM.sf2"
            iniSet "fullresolution" "desktop"
            iniSet "fullscreen" "true"
            iniSet "mididevice" "fluidsynth"
            iniSet "output" "texture"
            iniDel "usescancodes"
        fi
    fi
}
