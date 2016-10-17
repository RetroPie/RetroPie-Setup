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
    local ids=($@)

    local id
    local mode
    for id in "${ids[@]}"; do
        if [[ "$id" =~ ^[0-9]+$ ]]; then
            id="${__mod_id[$id]}"
        fi
        ! fnExists "install_$id" && continue

        # build, install and create binary archive.
        # initial clean in case anything was in the build folder when calling
        for mode in clean remove depends sources build install clean create_bin; do
            rp_callModule "$id" "$mode" || return 1
        done
    done
}

function section_builder() {
    local section="$1"
    local idx
    for idx in $(rp_getSectionIds $section); do
        module_builder "$idx" || return 1
    done
}

function upload_builder() {
    rsync -av --progress --delay-updates "$__tmpdir/archives/" "retropie@$__binary_host:files/binaries/"
}

function clean_archives_builder() {
    rm -rfv "$__tmpdir/archives"
}
