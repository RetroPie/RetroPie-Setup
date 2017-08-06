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
        [[ "$id" =~ ^[0-9]+$ ]] && id="$(rp_getIdFromIdx $id)"
        ! fnExists "install_$id" && continue

        # build, install and create binary archive.
        # initial clean in case anything was in the build folder when calling
        for mode in clean remove depends sources build install create_bin clean remove "depends remove"; do
            rp_callModule "$id" $mode
            # return on error
            [[ $? -eq 1 ]] && return 1
            # no module found - skip to next module
            [[ $? -eq 2 ]] && break
        done
    done
    return 0
}

function section_builder() {
    module_builder $(rp_getSectionIds $1) || return 1
}

function upload_builder() {
    rsync -av --progress --delay-updates "$__tmpdir/archives/" "retropie@$__binary_host:files/binaries/"
}

function clean_archives_builder() {
    rm -rfv "$__tmpdir/archives"
}
