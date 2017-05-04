#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function _get_config_pisnes() {
    echo "$configdir/snes/snes9x.cfg"
}

function _split_config_pisnes() {
    local cfg="$(_get_config_pisnes)"
    sed -n '/\[Keyboard\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pisnes-kb.cfg
    sed -n '/\[Joystick\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pisnes-js.cfg
    sed -n '/\[Graphics\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pisnes-gfx.cfg
}

function check_pisnes() {
    [[ ! -f "$(_get_config_pisnes)" ]] && return 1
    return 0
}

function onstart_pisnes_joystick() {
    _split_config_pisnes

    iniConfig "=" "" /tmp/pisnes-js.cfg
}

function onstart_pisnes_keyboard() {
    _split_config_pisnes

    iniConfig "=" "" /tmp/pisnes-kb.cfg

    sdl1_map
}

function map_pisnes_keyboard() {
    map_pifba_keyboard "$@"
}

function map_pisnes_joystick() {
    map_pifba_joystick "$@"
}

function onend_pisnes_joystick() {
    local cfg="$configdir/snes/snes9x.cfg"
    cat "/tmp/pisnes-kb.cfg" "/tmp/pisnes-js.cfg" "/tmp/pisnes-gfx.cfg" >"$cfg"
    rm /tmp/pisnes-{kb,js,gfx}.cfg
}

function onend_pisnes_keyboard() {
    onend_pisnes_joystick
}
