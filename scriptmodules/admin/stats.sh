#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="stats"
rp_module_desc="Generates statistics about packages"
rp_module_section=""

function _get_commit_data_stats() {
    local hash=$(git -C "$scriptdir" log -1 --format=%h)
    local date=$(git -C "$scriptdir" log -1 --format=%cd --date=iso-strict)
    local branch=$(git -C "$scriptdir" rev-parse --abbrev-ref HEAD)
    echo "$hash;$date;$branch;"
}

function _get_package_data_stats() {
    local data=()
    local id
    for id in ${__mod_id[@]}; do
        data+=("${__mod_info[$id/section]};$id;${__mod_info[$id/desc]};${__mod_info[$id/licence]};${__mod_info[$id/flags]};")
    done
    printf "%s\n" "${data[@]}"
}

function build_stats() {
    local dest="$__tmpdir/stats"
    mkUserDir "$dest"

    # ignore platform flags to get info for all packages
    __ignore_flags=1
    rp_registerAllModules

    echo "$(_get_package_data_stats)" > "$dest/packages.csv"
    echo "$(_get_commit_data_stats)" > "$dest/commit.csv"

    cp -rv "$md_data/licences" "$dest/"
    cp -rv "$md_data/pkgflags" "$dest/"
    chown -R $user: "$dest"
}

function upload_stats() {
    adminRsync "$__tmpdir/stats/" "stats/" --delete
}
