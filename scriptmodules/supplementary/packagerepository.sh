#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="packagerepository"
rp_module_desc="Package Repository"
rp_module_menus=""
rp_module_flags="nobin"

function install_packagerepository() {
    # install repository helper package
    getDepends reprepro

    # Create repository
    mkdir -p RetroPieRepo/conf
    cat >> RetroPieRepo/conf/distributions << _EOF_
Origin: apt.petrockblock.com
Label: apt repository
Codename: wheezy/rpi
Architectures: armhf other source
Components: main
Description: RetroPie Raspbian package repository
SignWith: yes
Pull: wheezy/rpi
_EOF_
}
