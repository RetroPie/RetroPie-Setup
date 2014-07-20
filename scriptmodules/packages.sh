#!/usr/bin/env bash

#
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
#
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
#
#  Permission to use, copy, modify and distribute this work in both binary and
#  source form, for non-commercial purposes, is hereby granted without fee,
#  providing that this license information and copyright notice appear with
#  all copies and any derived work.
#
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event shall the authors be held liable for any damages
#  arising from the use of this software.
#
#  RetroPie-Setup is freeware for PERSONAL USE only. Commercial users should
#  seek permission of the copyright holders first. Commercial use includes
#  charging money for RetroPie-Setup or software derived from RetroPie-Setup.
#
#  The copyright holders request that bug fixes and improvements to the code
#  should be forwarded to them so everyone can benefit from the modifications
#  in future versions.
#
#  Many, many thanks go to all people that provide the individual packages!!!
#

__idx=()
__cmd_id=()
__description=()
__menus=()
__doPackages=0

# params: $1=ID, $2=description, $3=sources, $4=build, $5=install, $6=configure, $7=package
function rp_registerFunction() {
    __idx+=($1)
    __cmd_id[$1]=$2
    __description[$1]=$3
    __menus[$1]=$4
}

function rp_listFunctions() {
    local idx
    local cmd_id
    local desc
    local mode
    local func

    echo -e "Index/ID:                 Description:                       List of available actions [sources|build|install|configure|package]"
    echo "-----------------------------------------------------------------------------------------------------------------------------------"
    echo ${__cmd_id[1]}
    for (( i = 0; i < ${#__idx[@]}; i++ )); do
        idx=${__idx[$i]};
        cmd_id=${__cmd_id[$idx]};
        printf "%d/%-20s: %-32s : " "$idx" "$cmd_id" "${__description[$idx]}"
        for mode in depen sources build install configure; do
            func="${mode}_${cmd_id}"
            fn_exists $func && echo -e "$mode \c"
        done
        echo ""
    done
    echo "==================================================================================================================================="
}

function rp_printUsageinfo() {
    echo -e "Usage:\n$0 <Index # or ID> [depend|sources|build|install|configure|package]\nThis will run the actions sources, build, install, configure, and package automatically.\n"
    echo -e "Alternatively, $0 can be called as\n$0 <ID> [sources|build|install|configure|package]\n"
    echo -e "This is a list of valid commands:\n"
    rp_listFunctions
}

function rp_callFunction() {
    local idx="$1"
    local func="$2"
    local desc
    local cmd_id
    # if index get cmd_id from ass array
    if [[ "$idx" =~ ^[0-9]+$ ]]; then
        cmd_id=${__cmd_id[$1]}
    else
        cmd_id="$idx"
        for idx in "${!__cmd_id[@]}"; do
            [[ "$cmd_id" == "${__cmd_id[$idx]}" ]] && break 
        done
    fi
    case "$func" in
        depen)
            desc="Installing dependencies for"
            ;;
        sources)
            desc="Getting sources for"
            ;;
        build)
            desc="Building"
            ;;
        install)
            desc="Installing"
            ;;
        configure)
            desc="Configuring"
            ;;
    esac
    func="${func}_${cmd_id}"
    # echo "Checking, if function ${!__function} exists"
    fn_exists $func || return
    # echo "Printing function name"
    printMsg "$desc ${__description[$idx]}"
    # echo "Executing function"
    $func
}

function registerModule() {
    local module_idx="$1"
    local module_path="$2"
    local rp_module_id=""
    local rp_module_desc=""
    local rp_module_menus=""
    local var
    local error=0
    source $module_path
    for var in rp_module_id rp_module_desc rp_module_menus; do
        if [[ "${!var}" == "" ]]; then
            echo "Module $module_path is missing valid $var"
            error=1
        fi
    done
    [[ $error -eq 1 ]] && exit 1
    rp_registerFunction "$module_idx" "$rp_module_id" "$rp_module_desc" "$rp_module_menus"
}

function registerModuleDir() {
    local module_idx="$1"
    local module_dir="$2"
    for module in `find "$scriptdir/scriptmodules/$2" -maxdepth 1 -name "*.sh" | sort`; do
        registerModule $module_idx "$module"
        ((module_idx++))
    done
}

function registerAllModules() {
    registerModuleDir 100 "emulators" 
    registerModuleDir 200 "libretrocores" 
    registerModuleDir 300 "supplementary"
}