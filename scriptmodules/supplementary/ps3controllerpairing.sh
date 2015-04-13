#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="ps3controllerpairing"
rp_module_desc="Pair PS3 controller"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_ps3controllerpairing() {
    if [[ -f "$rootdir/supplementary/ps3controller/sixpair" ]]; then
        # Only start sixpair. Don't waste time with driver compilation.
        rp_callModule ps3controller configure
    else
        # Install PS3 controller driver
        rp_callModule ps3controller	
    fi
}
