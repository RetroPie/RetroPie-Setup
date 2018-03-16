#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

declare -A __mod_id_to_idx
__mod_idx=()
__mod_id=()
__mod_type=()
__mod_desc=()
__mod_help=()
__mod_licence=()
__mod_section=()
__mod_flags=()

declare -A __sections
__sections[core]="core"
__sections[main]="main"
__sections[opt]="optional"
__sections[exp]="experimental"
__sections[driver]="driver"
__sections[config]="configuration"

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
        printf "%d/%-20s: %-42s :" "$idx" "$mod_id" "${__mod_desc[$idx]}"
        while read mode; do
            # skip private module functions (start with an underscore)
            [[ "$mode" = _* ]] && continue
            mode=${mode//_$mod_id/}
            echo -n " $mode"
        done < <(compgen -A function -X \!*_$mod_id)
        fnExists "install_${mod_id}" || fnExists "install_bin_${mod_id}" && ! fnExists "remove_${mod_id}" && echo -n " remove"
        echo -n " help"
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
    echo    "help:       get additional help on the module"
    echo -e "\nThis is a list of valid modules/packages and supported commands:\n"
    rp_listFunctions
}

function rp_callModule() {
    local req_id="$1"
    local mode="$2"
    # shift the function parameters left so $@ will contain any additional parameters which we can use in modules
    shift 2

    # if index get mod_id from array else we look it up
    local md_id
    local md_idx
    if [[ "$req_id" =~ ^[0-9]+$ ]]; then
        md_id="$(rp_getIdFromIdx $req_id)"
        md_idx="$req_id"
    else
        md_idx="$(rp_getIdxFromId $req_id)"
        md_id="$req_id"
    fi

    if [[ -z "$md_id" || -z "$md_idx" ]]; then
        printMsgs "console" "No module '$req_id' found for platform $__platform"
        return 2
    fi

    # automatically build/install module if no parameters are given
    if [[ -z "$mode" ]]; then
        for mode in depends sources build install configure clean; do
            rp_callModule "$md_idx" "$mode" || return 1
        done
        return 0
    fi

    # create variables that can be used in modules
    local md_desc="${__mod_desc[$md_idx]}"
    local md_help="${__mod_help[$md_idx]}"
    local md_type="${__mod_type[$md_idx]}"
    local md_flags="${__mod_flags[$md_idx]}"
    local md_build="$__builddir/$md_id"
    local md_inst="$rootdir/$md_type/$md_id"
    local md_data="$scriptdir/scriptmodules/$md_type/$md_id"
    local md_mode="install"

    # set md_conf_root to $configdir and to $configdir/ports for ports
    # ports in libretrocores or systems (as ES sees them) in ports will need to change it manually with setConfigRoot
    local md_conf_root
    if [[ "$md_type" == "ports" ]]; then
        setConfigRoot "ports"
    else
        setConfigRoot ""
    fi

    case "$mode" in
        # remove sources
        clean)
            if [[ "$__persistent_repos" -eq 1 ]] && [[ -d "$md_build/.git" ]]; then
                git -C "$md_build" reset --hard
                git -C "$md_build" clean -f -d
            else
                rmDirExists "$md_build"
            fi
            return 0
            ;;
        # create binary archive
        create_bin)
            rp_createBin
            return 0
            ;;
        # echo module help to console
        help)
            printMsgs "console" "$md_desc\n\n$md_help"
            return 0;
            ;;
    esac

    # create function name
    function="${mode}_${md_id}"

    # handle cases where we have automatic module functions like remove
    if ! fnExists "$function"; then
        if [[ "$mode" == "install" ]] && fnExists "install_bin_${md_id}"; then
            function="install_bin_${md_id}"
        elif [[ "$mode" != "install_bin" && "$mode" != "remove" ]]; then
            return 0
        fi
    fi

    # these can be returned by a module
    local md_ret_require=()
    local md_ret_files=()
    local md_ret_errors=()
    local md_ret_info=()

    local action
    local pushed=1
    case "$mode" in
        depends)
            if [[ "$1" == "remove" ]]; then
                md_mode="remove"
                action="Removing"
            else
                action="Installing"
            fi
            action+=" dependencies for"
            ;;
        sources)
            action="Getting sources for"
            mkdir -p "$md_build"
            pushd "$md_build"
            pushed=$?
            ;;
        build)
            action="Building"
            pushd "$md_build" 2>/dev/null
            pushed=$?
            ;;
        install|install_bin)
            action="Installing"
            # remove any previous install folder before installing
            if ! hasFlag "${__mod_flags[$md_idx]}" "noinstclean"; then
                rmDirExists "$md_inst"
            fi
            mkdir -p "$md_inst"
            pushd "$md_build" 2>/dev/null
            pushed=$?
            ;;
        configure)
            action="Configuring"
            pushd "$md_inst" 2>/dev/null
            pushed=$?
            ;;
        remove)
            action="Removing"
            ;;
        _update_hook)
            ;;
        *)
            action="Running action '$mode' for"
            ;;
    esac

    # print an action and a description
    if [[ -n "$action" ]]; then
        printHeading "$action '$md_id' : $md_desc"
    fi

    case "$mode" in
        remove)
            fnExists "$function" && "$function" "$@"
            md_mode="remove"
            if fnExists "configure_${md_id}"; then
                pushd "$md_inst" 2>/dev/null
                pushed=$?
                "configure_${md_id}"
            fi
            rm -rf "$md_inst"
            printMsgs "console" "Removed directory $md_inst"
            ;;
        install)
            if fnExists "$function"; then
                "$function" "$@"
            elif fnExists "install_bin_${md_id}"; then
                "install_bin_${md_id}" "$@"
            fi
            ;;
        install_bin)
            if fnExists "install_bin_${md_id}"; then
                if ! "$function" "$@"; then
                    md_ret_errors+=("Unable to install binary for $md_id")
                fi
            else
                if rp_hasBinary "$md_idx"; then
                    rp_installBin
                else
                    md_ret_errors+=("Could not find a binary for $md_id")
                fi
            fi
            ;;
        *)
            # call the function with parameters
            fnExists "$function" && "$function" "$@"
            ;;
    esac

    # check if any required files are found
    if [[ -n "$md_ret_require" ]]; then
        for file in "${md_ret_require[@]}"; do
            if [[ ! -e "$file" ]]; then
                md_ret_errors+=("Could not successfully $mode $md_id - $md_desc ($file not found).")
                break
            fi
        done
    fi

    if [[ "${#md_ret_errors}" -eq 0 && -n "$md_ret_files" ]]; then
        # check for existence and copy any files/directories returned
        local file
        for file in "${md_ret_files[@]}"; do
            if [[ ! -e "$md_build/$file" ]]; then
                md_ret_errors+=("Could not successfully install $md_desc ($md_build/$file not found).")
                break
            fi
            cp -Rvf "$md_build/$file" "$md_inst"
        done
    fi

    # remove build folder if empty
    [[ -d "$md_build" ]] && find "$md_build" -maxdepth 0 -empty -exec rmdir {} \;

    [[ "$pushed" -eq 0 ]] && popd

    # some errors were returned.
    if [[ "${#md_ret_errors[@]}" -gt 0 ]]; then
        __ERRMSGS+=("${md_ret_errors[@]}")
        printMsgs "console" "${md_ret_errors[@]}" >&2
        # if sources fails make sure we clean up
        if [[ "$mode" == "sources" ]]; then
            rp_callModule "$md_idx" clean
        fi
        # remove install folder if there is an error (and it is empty)
        [[ -d "$md_inst" ]] && find "$md_inst" -maxdepth 0 -empty -exec rmdir {} \;
        return 1
    fi

    # some information messages were returned
    if [[ "${#md_ret_info[@]}" -gt 0 ]]; then
        __INFMSGS+=("${md_ret_info[@]}")
    fi

    return 0
}

function rp_hasBinaries() {
    [[ "$__has_binaries" -eq 1 ]] && return 0
    return 1
}

function rp_hasBinary() {
    local idx="$1"
    local id="${__mod_id[$idx]}"
    fnExists "install_bin_${__mod_id[$idx]}" && return 0

    # binary blacklist for armv7 Debian/OSMC due to GCC ABI incompatibility with
    # threaded C++ apps on Raspbian (armv6 userland)
    if [[ "$__os_id" != "Raspbian" ]] && ! isPlatform "armv6"; then
        case "$id" in
            emulationstation|zdoom|lr-dinothawr|lr-ppsspp|ppsspp)
                return 1
                ;;
        esac
    fi

    if rp_hasBinaries; then
        wget --spider -q "$__binary_url/${__mod_type[$idx]}/${__mod_id[$idx]}.tar.gz"
        return $?
    fi
    return 1
}

function rp_installBin() {
    rp_hasBinaries || fatalError "There are no binary archives for platform $__platform"
    local archive="$md_type/$md_id.tar.gz";
    local dest="$rootdir/$md_type"
    mkdir -p "$dest"
    wget -O- -q "$__binary_url/$archive" | tar -xvz -C "$dest"
}

function rp_createBin() {
    printHeading "Creating binary archive for $md_desc"

    if [[ ! -d "$rootdir/$md_type/$md_id" ]]; then
        printMsgs "console" "No install directory $rootdir/$md_type/$md_id - no archive created"
        return 1
    fi

    if dirIsEmpty "$rootdir/$md_type/$md_id"; then
        printMsgs "console" "Empty install directory $rootdir/$md_type/$md_id - no archive created"
        return 1
    fi

    local archive="$md_id.tar.gz"
    local dest="$__tmpdir/archives/$__os_codename/$__platform/$md_type"
    rm -f "$dest/$archive"
    mkdir -p "$dest"
    tar cvzf "$dest/$archive" -C "$rootdir/$md_type" "$md_id"
    chown $user:$user "$dest/$archive"
}

function rp_installModule() {
    local idx="$1"
    local mode
    if rp_hasBinary "$idx"; then
        for mode in depends install_bin configure; do
            rp_callModule "$idx" "$mode" || return 1
        done
    else
        rp_callModule "$idx" clean
        rp_callModule "$idx" || return 1
    fi
    return 0
}

function rp_registerModule() {
    local module_idx="$1"
    local module_path="$2"
    local module_type="$3"
    local rp_module_id=""
    local rp_module_desc=""
    local rp_module_help=""
    local rp_module_licence=""
    local rp_module_section=""
    local rp_module_flags=""
    local var
    local error=0

    source "$module_path"

    for var in rp_module_id rp_module_desc; do
        if [[ -z "${!var}" ]]; then
            echo "Module $module_path is missing valid $var"
            error=1
        fi
    done
    [[ $error -eq 1 ]] && exit 1

    local flags=($rp_module_flags)
    local flag
    local valid=1

    for flag in "${flags[@]}"; do
        if [[ "$flag" =~ ^\!(.+) ]] && isPlatform "${BASH_REMATCH[1]}"; then
            valid=0
            break
        fi
    done

    if [[ "$valid" -eq 1 ]]; then
        __mod_idx+=("$module_idx")
        __mod_id["$module_idx"]="$rp_module_id"
        __mod_type["$module_idx"]="$module_type"
        __mod_desc["$module_idx"]="$rp_module_desc"
        __mod_help["$module_idx"]="$rp_module_help"
        __mod_licence["$module_idx"]="$rp_module_licence"
        __mod_section["$module_idx"]="$rp_module_section"
        __mod_flags["$module_idx"]="$rp_module_flags"

        # id to idx mapping via associative array
        __mod_id_to_idx["$rp_module_id"]="$module_idx"
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
    rp_registerModuleDir 300 "ports"
    rp_registerModuleDir 800 "supplementary"
    rp_registerModuleDir 900 "admin"
}

function rp_getIdxFromId() {
    echo "${__mod_id_to_idx[$1]}"
}

function rp_getIdFromIdx() {
    echo "${__mod_id[$1]}"
}

function rp_getSectionIds() {
    local section
    local id
    local ids=()
    for id in "${__mod_idx[@]}"; do
        for section in "$@"; do
            [[ "${__mod_section[$id]}" == "$section" ]] && ids+=("$id")
        done
    done
    echo "${ids[@]}"
}

function rp_isInstalled() {
    local md_idx="$1"
    local md_inst="$rootdir/${__mod_type[$md_idx]}/${__mod_id[$md_idx]}"
    [[ -d "$md_inst" ]] && return 0
    return 1
}

function rp_updateHooks() {
    local function
    local mod_idx
    for function in $(compgen -A function _update_hook_); do
        mod_idx="$(rp_getIdxFromId "${function/_update_hook_/}")"
        [[ -n "$mod_idx" ]] && rp_callModule "$mod_idx" _update_hook
    done
}
