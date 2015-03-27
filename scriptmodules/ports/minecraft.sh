#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#
#  Many, many thanks go to all people that provide the individual modules!!!
#

rp_module_id="minecraft"
rp_module_desc="Minecraft"
rp_module_menus="4+"
rp_module_flags="nobin"

function install_minecraft() {
    wget -O- -q https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz | tar -xvz --strip-components=1 -C "$md_inst"
}

function configure_minecraft() {
    mkRomDir "ports"

    cat > "$romdir/ports/Minecraft.sh" << _EOF_
#!/bin/bash
xinit "$md_inst/minecraft-pi"
_EOF_

    chmod +x "$romdir/ports/Minecraft.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
