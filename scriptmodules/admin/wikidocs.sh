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
    getDepends python3 python3-pip libyaml-dev
    pip3 install --upgrade mkdocs mkdocs-material mdx_truly_sane_lists git+https://github.com/cmitu/mkdocs-altlink-plugin
}

function sources_wikidocs() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/RetroPie-Docs.git
}

function build_wikidocs() {
    mkdocs build
}

function install_wikidocs() {
    rsync -a --delete "$md_build/site/" "$__tmpdir/wikidocs/"
    chown -R $user: "$__tmpdir/wikidocs"
}

function upload_wikidocs() {
    adminRsync "$__tmpdir/wikidocs/" "docs/" --delete
}
