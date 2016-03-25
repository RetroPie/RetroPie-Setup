#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="minecraft"
rp_module_desc="Minecraft"
rp_module_menus="4+"
rp_module_flags="nobin !mali !x86"

function depends_minecraft() {
    getDepends xorg matchbox
}

function install_minecraft() {
    wget -O- -q https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz | tar -xvz --strip-components=1 -C "$md_inst"
}

function configure_minecraft() {
    addPort "$md_id" "minecraft" "Minecraft" "xinit $md_inst/Minecraft.sh"

    cat >"$md_inst/Minecraft.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
$md_inst/minecraft-pi
_EOF_
    chmod +x "$md_inst/Minecraft.sh"


}
