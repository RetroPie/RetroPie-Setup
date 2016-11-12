#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="docs"
rp_module_desc="Generate developer documentation"
rp_module_section=""

function depends_docs() {
    getDepends doxygen graphviz
}

function sources_docs() {
    gitPullOrClone "$md_build" https://github.com/Anvil/bash-doxygen.git
}

function build_docs() {
    local config="Doxyfile"
    rm -f "$config"
    doxygen -g "$config" >/dev/null
    iniConfig " = " '' "$config"
    iniSet "PROJECT_NAME" "RetroPie-Setup"
    iniSet "PROJECT_NUMBER" "$__version"

    iniSet "EXTENSION_MAPPING" "sh=C"
    iniSet "QUIET" "YES"
    iniSet "WARN_IF_DOC_ERROR" "NO"
    iniSet "INPUT" "$scriptdir"
    iniSet "FILE_PATTERNS" "*.sh"
    iniSet "EXCLUDE_PATTERNS" "*/tmp/*"
    iniSet "INPUT_FILTER" "\"sed -n -f $md_build/doxygen-bash.sed -- \""
    iniSet "RECURSIVE" "YES"
    doxygen "$config"
}

function install_docs() {
    rm -rf "$scriptdir/docs"
    cp -R "$md_build/html" "$scriptdir/docs"
    chown -R $user:$user "$scriptdir/docs"
}
