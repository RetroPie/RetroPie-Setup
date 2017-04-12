#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# http://www.gtkdb.de/index_36_2176.html
rp_module_id="kodi-15"
rp_module_desc="Install Kodi 15 (Must install the other Kodi first!)"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_kodi-15() {
    apt-get remove -y kodi kodi.bin
}

function sources_kodi-15() {
 wget -O- -q http://steinerdatenbank.de/software/kodi-15.tar.gz | tar -xvz
 cd kodi-15
 ./install
}

function configure_kodi-15() {
    echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules

    mkRomDir "ports"
    cat > "$romdir/ports/Kodi.sh" << _EOF_
#!/bin/bash
startkodi
_EOF_

    chmod +x "$romdir/ports/Kodi.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
