#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="resetromdirs"
rp_module_desc="Reset ownership/permissions of $romdir"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_resetromdirs() {
    printHeading "Resetting $romdir ownershop/permissions"
    mkUserDir "$romdir"
    mkUserDir "$biosdir"
    chown -R $user:$user "$romdir"
    chown -R $user:$user "$biosdir"
}
