#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wikidocs"
rp_module_desc="Generate mkdocs documentation from wiki"
rp_module_section=""

function depends_wikidocs() {
    getDepends python3 python3-pip libyaml-dev python3-setuptools python3-wheel python3-virtualenv
}

function sources_wikidocs() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/RetroPie-Docs.git
}

function build_wikidocs() {
    python3 -m venv "$md_inst"
    source "$md_inst/bin/activate"
    pip3 install --upgrade mkdocs-material mdx_truly_sane_lists git+https://github.com/cmitu/mkdocs-altlink-plugin
    mkdocs build
    deactivate
}

function install_wikidocs() {
    rsync -a --delete "$md_build/site/" "$__tmpdir/wikidocs/"
    chown -R "$__user":"$__group" "$__tmpdir/wikidocs"
}

function upload_wikidocs() {
    adminRsync "$__tmpdir/wikidocs/" "docs/" --delete
}
