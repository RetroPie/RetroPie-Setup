#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="minecraft"
rp_module_desc="Minecraft"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_minecraft() {
    getDepends matchbox
}

function install_minecraft() {
    wget -O- -q https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz | tar -xvz --strip-components=1 -C "$md_inst"
}

function configure_minecraft() {
    mkRomDir "ports"

    cat >"$md_inst/Minecraft.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
$md_inst/minecraft-pi
_EOF_
    chmod +x "$md_inst/Minecraft.sh"

    cat > "$romdir/ports/Minecraft.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 0 "xinit \"$md_inst/Minecraft.sh\"" minecraft
_EOF_
    chmod +x "$romdir/ports/Minecraft.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
