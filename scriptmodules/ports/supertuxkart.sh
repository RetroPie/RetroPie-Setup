
#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="supertuxkart"
rp_module_desc="SuperTuxKart SDL2-compatible racing game"
rp_module_licence="GPL3 https://github.com/supertuxkart/stk-editor/blob/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!mali"

function _update_hook_supertuxkart() {
    # to show as installed in retropie-setup 4.x
    hasPackage supertuxkart && mkdir -p "$md_inst"
}

function install_bin_supertuxkart() {
    aptInstall supertuxkart
}

function remove_supertuxkart() {
    aptRemove supertuxkart supertuxkart-data
}

function configure_supertuxkart() {
    addPort  "$md_inst" "supertuxkart" "SuperTuxKart"
}
