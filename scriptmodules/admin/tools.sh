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
    local ids
    if [[ -n "$1" ]]; then
        ids=("$@")
    else
        ids=("${__mod_id[@]}")
    fi
    local id
    local ret=0
    for id in "${ids[@]}"; do
        eval "$(rp_moduleVars $id)"
        local out
        [[ -z "$md_repo_type" ]] && continue
        md_repo_branch="$(rp_resolveRepoParam "$md_repo_branch")"
        md_repo_commit="$(rp_resolveRepoParam "$md_repo_commit")"
        printMsgs "console" "Checking $id repository ($md_repo_url / $md_repo_branch) ..."
        case "$md_repo_type" in
            git|svn)
                out=$(rp_getRemoteRepoHash "$md_repo_type" "$md_repo_url" "$md_repo_branch" "$md_repo_commit")
                if [[ "$?" -ne 0 || -z "$out" ]]; then
                    printMsgs "console" "$id repository failed - $md_repo_url $md_repo_branch"
                    ret=1
                fi
                ;;
           file)
                if ! rp_getFileDate "$md_repo_url" >/dev/null; then
                    printMsgs "console" "$id file archive failed - $md_repo_url"
                    ret=1
                fi
                ;;
           :*)
                # handle checking via module function - function should return 1 if there was an error
                local function="${md_repo_type:1}"
                if fnExists "$function" ; then
                    ! "$function" check && ret=1
                fi
                ;;

        esac
    done
    return "$ret"
}
