#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pkgflags"
rp_module_desc="Collect package flags and generate statistics"
rp_module_section=""

function build_pkgflags() {
    mkdir -p "$md_build"
    pushd "$md_build"

    local idx
    local mod_id
    local mod_desc
    local mod_section
    local mod_flags

    echo > packages.csv
    for idx in ${__mod_idx[@]}; do
        mod_section="${__mod_section[$idx]}"
        mod_id="${__mod_id[$idx]}"
        mod_desc="${__mod_desc[$idx]}"
        mod_flags="${__mod_flags[$idx]}"
        echo "$mod_section;$mod_id;$mod_desc;$mod_flags;" >> packages.csv
    done

    local git_hash=$(git -C "$scriptdir" log -1 --format=%h)
    local git_date=$(git -C "$scriptdir" log -1 --format=%cd --date=iso-strict)
    local git_branch=$(git -C "$scriptdir" rev-parse --abbrev-ref HEAD)
    echo "$git_hash;$git_date;$git_branch;" > commit.csv

    cp -v "$md_data/"* ./
    popd
}

function install_pkgflags() {
    rsync -a --delete "$md_build/" "$__tmpdir/pkgflags/"
    chown -R $user:$user "$__tmpdir/pkgflags"
}

function upload_pkgflags() {
    rsync -av --delete "$__tmpdir/pkgflags/" "retropie@$__binary_host:pkgflags/"
}
