#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="tools"
rp_module_desc="Various RetroPie development/administration tools"
rp_module_section=""

function check_repos_tools() {
    local id
    local ret=0
    for id in "${__mod_id[@]}"; do
        eval "$(rp_moduleVars $id)"
        local out
        [[ -z "$md_repo_type" ]] && continue
        printMsgs "console" "Checking $id repository source ..."
        case "$md_repo_type" in
            git)
                out="$(git ls-remote --symref "$md_repo_url" "$md_repo_branch")"
                if [[ -z "$out" ]]; then
                    printMsgs "console" "$id repository failed - $md_repo_url $md_repo_branch"
                    ret=1
                fi
                ;;
            svn)
                if ! out="$(svn info -r"$md_repo_commit" "$md_repo_url" 2>&1)"; then
                    printMsgs "console" "$id repository failed - $md_repo_url $md_repo_commit\n$out"
                    ret=1
                fi
                ;;
           file)
                if ! rp_getFileDate "$md_repo_url" >/dev/null; then
                    printMsgs "console" "$id file archive failed - $md_repo_url"
                    ret=1
                fi
                ;;
        esac
    done
    return "$ret"
}
