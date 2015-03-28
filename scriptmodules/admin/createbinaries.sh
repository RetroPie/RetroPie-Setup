#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="createbinaries"
rp_module_desc="Create binary archives for distribution"
rp_module_menus=""
rp_module_flags="nobin"

function install_createbinaries() {
    for idx in "${__mod_idx[@]}"; do
        if [[ ! "${__mod_menus[$idx]}" =~ 4 ]] && [[ ! "${__mod_flags[$idx]}" =~ nobin ]]; then
            rp_callModule $idx create_bin
        fi
    done
}
