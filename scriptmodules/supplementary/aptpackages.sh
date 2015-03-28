#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="aptpackages"
rp_module_desc="Update APT packages"
rp_module_menus="2+ 3+"
rp_module_flags="nobin"

function install_aptpackages() {
    apt-get -y autoremove
    aptUpdate
    apt-get -y upgrade
}
