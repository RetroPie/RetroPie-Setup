#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="apidocs"
rp_module_desc="Generate developer documentation"
rp_module_section=""

function depends_apidocs() {
    getDepends doxygen graphviz
}

function sources_apidocs() {
    gitPullOrClone "$md_build" https://github.com/Anvil/bash-doxygen.git master 35ec6ff6
}

function build_apidocs() {
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
    iniSet "EXCLUDE_PATTERNS" "*/tmp/*"
    iniSet "INPUT_FILTER" "\"sed -n -f $md_build/doxygen-bash.sed -- \""
    iniSet "RECURSIVE" "YES"

    # unable to use iniSet for latest doxygen "multi line" FILE_PATTERNS default
    echo "FILE_PATTERNS = *.sh" >>"$config"

    doxygen "$config"
}

function install_apidocs() {
    rsync -a --delete "$md_build/html/" "$__tmpdir/apidocs/"
    chown -R $user:$user "$__tmpdir/apidocs"
}

function upload_apidocs() {
    rsync -av --delete "$__tmpdir/apidocs/" "retropie@$__binary_host:api/"
}
