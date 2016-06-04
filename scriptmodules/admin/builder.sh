#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="builder"
rp_module_desc="Create binary archives for distribution"
rp_module_section=""

function depends_builder() {
    getDepends rsync
}

function module_builder() {
    local id="$1"
    rp_callModule "$id" remove
    for mode in depends sources build install clean; do
        rp_callModule "$id" "$mode"
    done
    rp_callModule "$id" create_bin
}

function section_builder() {
    local section="$1"
    local idx
    for idx in $(rp_getSectionIds $section); do
        module_builder "$idx"
    done
}

function upload_builder() {
    rsync -av --progress --delay-updates "$__tmpdir/archives/" "retropie@$__binary_host:files/binaries/"
}

function clean_archives_builder() {
    rm -rfv "$__tmpdir/archives"
}
