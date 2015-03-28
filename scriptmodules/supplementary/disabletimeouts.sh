#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="disabletimeouts"
rp_module_desc="Disable system timeouts"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_disabletimeouts() {
    sed -i 's/BLANK_TIME=30/BLANK_TIME=0/g' /etc/kbd/config
    sed -i 's/POWERDOWN_TIME=30/POWERDOWN_TIME=0/g' /etc/kbd/config
}
