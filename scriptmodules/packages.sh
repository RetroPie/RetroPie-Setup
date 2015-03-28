#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

__mod_idx=()
__mod_id=()
__mod_type=()
__mod_desc=()
__mod_menus=()
__mod_flags=()

function fn_exists() {
    declare -f "$1" > /dev/null
    return $?
}

# params: $1=index, $2=id, $3=type, $4=description, $5=menus,  $6=flags
function rp_registerFunction() {
    __mod_idx+=($1)
    __mod_id[$1]=$2
    __mod_type[$1]=$3
    __mod_desc[$1]=$4
    __mod_menus[$1]=$5
    __mod_flags[$1]=$6
}

function rp_listFunctions() {
    local idx
    local mod_id
    local desc
    local mode
    local func

    echo -e "Index/ID:                 Description:                                 List of available actions"
    echo "-----------------------------------------------------------------------------------------------------------------------------------"
    for idx in ${__mod_idx[@]}; do
        mod_id=${__mod_id[$idx]};
        printf "%d/%-20s: %-42s : " "$idx" "$mod_id" "${__mod_desc[$idx]}"
        for mode in depends sources build install configure remove; do
            func="${mode}_${mod_id}"
            fn_exists $func && echo -e "$mode \c"
        done
        echo ""
    done
    echo "==================================================================================================================================="
}

function rp_printUsageinfo() {
    echo -e "Usage:\n$0 <Index # or ID>\nThis will run the actions depends, sources, build, install, configure and clean automatically.\n"
    echo -e "Alternatively, $0 can be called as\n$0 <Index # or ID [depends|sources|build|install|configure|clean|remove]\n"
    echo    "Definitions:"
    echo    "depends:    install the dependencies for the module"
    echo    "sources:    install the sources for the module"
    echo    "build:      build/compile the module"
    echo    "install:    install the compiled module"
    echo    "configure:  configure the installed module (es_systems.cfg / launch parameters etc)"
    echo    "clean:      remove the sources/build folder for the module"
    echo -e "\nThis is a list of valid modules/packages and supported commands:\n"
    rp_listFunctions
}

function rp_callModule() {
    local req_id="$1"
    local mode="$2"
    # shift the function parameters left so $@ will contain any additional parameters which we can use in modules
    shift 2

    if [[ -z "$mode" ]]; then
        for mode in depends sources build install configure clean; do
            rp_callModule $req_id $mode || return 1
        done
        return 0
    fi

    # if index get mod_id from array else try and find it (we should probably use bash associative arrays for efficiency)
    local mod_id
    local idx
    if [[ "$req_id" =~ ^[0-9]+$ ]]; then
        mod_id=${__mod_id[$req_id]}
        idx=$req_id
    else
        for idx in "${!__mod_id[@]}"; do
            if [[ "$req_id" == "${__mod_id[$idx]}" ]]; then
                mod_id="$req_id"
                break
            fi
        done
    fi

    if [[ -z "$mod_id" ]]; then
        fatalError "No module '$req_id' found for platform $__platform"
    fi

    # create variables that can be used in modules
    local md_id="$mod_id"
    local md_desc="${__mod_desc[$idx]}"
    local md_type="${__mod_type[$idx]}"
    local md_flags="${__mod_flags[$idx]}"
    local md_build="$__builddir/$mod_id"
    local md_inst="$rootdir/$md_type/$mod_id"

    # remove source/build files
    if [[ "${mode}" == "clean" ]]; then
        rmDirExists "$md_build"
        return 0
    fi

    # create function name
    function="${mode}_${mod_id}"
    if [[ "${mode}" == "install_bin" ]] && [[ ! "$md_flags" =~ nobin ]]; then
        rp_installBin
        return
    fi

    if [[ "${mode}" == "create_bin" ]] && [[ ! "$md_flags" =~ nobin ]]; then
        rp_createBin
        return
    fi

    # return if function doesn't exist
    fn_exists $function || return 0

    # these can be returned by a module
    local md_ret_require=""
    local md_ret_files=""

    local action
    case "$mode" in
        depends)
            action="Installing dependencies for"
            ;;
        sources)
            action="Getting sources for"
            rmDirExists "$md_build"
            mkdir -p "$md_build"
            pushd "$md_build"
            ;;
        build)
            action="Building"
            pushd "$md_build" 2>/dev/null
            ;;
        install|install_bin)
            action="Installing"
            mkdir -p "$md_inst"
            pushd "$md_build" 2>/dev/null
            ;;
        configure)
            action="Configuring"
            pushd "$md_inst" 2>/dev/null
            ;;
        remove)
            action="Removing"
            ;;
    esac
    local pushed=$?
    local md_ret_errors=()

    # print an action and a description
    [[ -n "$action" ]] && printHeading "$action '$md_id' : $md_desc"

    # call the function with parameters
    $function "$@"

    local file
    # some errors were returned. append to global errors and return
    if [[ "${#md_ret_errors}" -eq 0 ]]; then
        # check if any required files are found
        if [[ -n "$md_ret_require" ]]; then
            for file in "${md_ret_require[@]}"; do
                if [[ ! -e "$file" ]]; then
                    md_ret_errors+=("Could not successfully $function $md_desc ($file not found).")
                    break
                fi
            done
        else
            # check for existance and copy any files/directories returned
            if [[ -n "$md_ret_files" ]]; then
                for file in "${md_ret_files[@]}"; do
                    if [[ ! -e "$md_build/$file" ]]; then
                        md_ret_errors+=("Could not successfully install $md_desc ($md_build/$file not found).")
                        break
                    fi
                    cp -Rv "$md_build/$file" "$md_inst"
                done
            fi
        fi
    fi

    # remove build/install folder if empty
    [[ -d "$md_build" ]] && find "$md_build" -maxdepth 0 -empty -exec rmdir {} \;
    [[ -d "$md_inst" ]] && find "$md_inst" -maxdepth 0 -empty -exec rmdir {} \;

    case "$mode" in
        sources|build|install|configure)
            [[ $pushed -ne 1 ]] && popd
            ;;
    esac

    if [[ "${#md_ret_errors[@]}" -gt 0 ]]; then
        printMsgs "console" "${md_ret_errors[@]}" >&2
        __ERRMSGS+=("${md_ret_errors[@]}")
        return 1
    fi

    return 0
}

function rp_installBin() {
    printHeading "Installing binary archive for $md_desc"
    [[ "$__has_binaries" -eq 0 ]] && fatalError "There are no binary archives for platform $__platform"
    local archive="$md_type/$md_id.tar.gz";
    local dest="$rootdir/$md_type"
    mkdir -p "$dest"
    wget -O- -q "$__binary_url/$archive" | tar -xvz -C "$dest"
    if fn_exists $function; then
        $function
    fi
}

function rp_createBin() {
    printHeading "Creating binary archive for $md_desc"
    local archive="$md_id.tar.gz"
    local dest="$__tmpdir/archives/$__platform/$md_type"
    rm -f "$dest/$archive"
    mkdir -p "$dest"
    tar cvzf "$dest/$archive" -C "$rootdir/$md_type" "$md_id"
    chown $user:$user "$dest/$archive"
}

function rp_registerModule() {
    local module_idx="$1"
    local module_path="$2"
    local module_type="$3"
    local rp_module_id=""
    local rp_module_desc=""
    local rp_module_menus=""
    local rp_module_flags=""
    local var
    local error=0
    source $module_path
    for var in rp_module_id rp_module_desc; do
        if [[ -z "${!var}" ]]; then
            echo "Module $module_path is missing valid $var"
            error=1
        fi
    done
    [[ $error -eq 1 ]] && exit 1
    if ! hasFlag "$rp_module_flags" "!$__platform"; then
        rp_registerFunction "$module_idx" "$rp_module_id" "$module_type" "$rp_module_desc" "$rp_module_menus"  "$rp_module_flags"
    fi
}

function rp_registerModuleDir() {
    local module_idx="$1"
    local module_dir="$2"
    for module in $(find "$scriptdir/scriptmodules/$2" -maxdepth 1 -name "*.sh" | sort); do
        rp_registerModule $module_idx "$module" "$module_dir"
        ((module_idx++))
    done
}

function rp_registerAllModules() {
    rp_registerModuleDir 100 "emulators"
    rp_registerModuleDir 200 "libretrocores" 
    rp_registerModuleDir 250 "ports"
    rp_registerModuleDir 300 "supplementary"
    rp_registerModuleDir 900 "admin"
}
