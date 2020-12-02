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
declare -A __sections
__sections[core]="core"
__sections[main]="main"
__sections[opt]="optional"
__sections[exp]="experimental"
__sections[driver]="driver"
__sections[config]="configuration"
__sections[depends]="dependency"

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

    # parameters _auto_ _binary or _source_ (_source_ is used if no parameters are given for a module)
    case "$mode" in
        # install the module if not installed, and update if it is
        _autoupdate_)
            if rp_isInstalled "$md_idx"; then
                rp_callModule "$md_idx" "_update_" || return 1
            else
                rp_callModule "$md_idx" "_auto_" || return 1
            fi
            return 0
            ;;
        # automatic modes used by rp_installModule to choose between binary/source based on pkg info
        _auto_|_update_)
            # if updating and a package isn't installed, return an error
            if [[ "$mode" == "_update_" ]] && ! rp_isInstalled "$md_idx"; then
                __ERRMSGS+=("$md_id is not installed, so can't update")
                return 1
            fi

            eval $(rp_getPackageInfo "$md_idx")
            rp_hasBinary "$md_idx"
            local ret="$?"

            # check if we had a network failure from wget
            if [[ "$ret" -eq 4 ]]; then
                __ERRMSGS+=("Unable to connect to the internet")
                return 1
            fi

            if [[ "$pkg_origin" != "source" ]] && [[ "$ret" -eq 0 ]]; then
                # if we are in _update_ mode we only update if there is a newer binary
                if [[ "$mode" == "_update_" ]]; then
                    rp_hasNewerBinary "$md_idx"
                    local ret="$?"
                    [[ "$ret" -eq 1 ]] && return 0
                fi
                rp_callModule "$md_idx" _binary_ || return 1
            else
                rp_callModule "$md_idx" || return 1
            fi
            return 0
            ;;
        _binary_)
            for mode in depends install_bin configure; do
                rp_callModule "$md_idx" "$mode" || return 1
            done
            return 0
            ;;
        # automatically build/install module from source if no _source_ or no parameters are given
        ""|_source_)
            for mode in depends sources build install configure clean; do
                rp_callModule "$md_idx" "$mode" || return 1
            done
            return 0
            ;;
    esac

    # create variables that can be used in modules
    local md_desc="${__mod_desc[$md_idx]}"
    local md_help="${__mod_help[$md_idx]}"
    local md_type="${__mod_type[$md_idx]}"
    local md_flags="${__mod_flags[$md_idx]}"
    local md_build="$__builddir/$md_id"
    local md_inst="$(rp_getInstallPath $md_idx)"
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
            rp_createBin || return 1
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
        # if sources fails and we were called from the setup gui module clean sources
        if [[ "$mode" == "sources" && "$__setup" -eq 1 ]]; then
            rp_callModule "$md_idx" clean
        fi
        # remove install folder if there is an error (and it is empty)
        [[ -d "$md_inst" ]] && find "$md_inst" -maxdepth 0 -empty -exec rmdir {} \;
        return 1
    else
        [[ "$mode" == "install_bin" ]] && rp_setPackageInfo "$md_idx" "binary"
        [[ "$mode" == "install" ]] && rp_setPackageInfo "$md_idx" "source"
        # handle the case of a few drivers that don't have an install function and set the package info at build stage
        if ! fnExists "install_${md_id}" && [[ "$mode" == "build" ]]; then
            rp_setPackageInfo "$md_idx" "source"
        fi
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

function rp_getBinaryUrl() {
    local idx="$1"
    local id="${__mod_id[$idx]}"
    local url="$__binary_url/${__mod_type[$idx]}/$id.tar.gz"
    if fnExists "install_bin_${id}"; then
        if fnExists "__binary_url_${id}"; then
            url="$(__binary_url_${id})"
        else
            url="notest"
        fi
    fi
    echo "$url"
}

function rp_hasBinary() {
    local idx="$1"
    local id="${__mod_id[$idx]}"

    # binary blacklist for armv7 Debian/OSMC due to GCC ABI incompatibility with
    # threaded C++ apps on Raspbian (armv6 userland)
    if [[ "$__os_id" != "Raspbian" ]] && ! isPlatform "armv6"; then
        case "$id" in
            emulationstation|lzdoom|lr-dinothawr|lr-ppsspp|ppsspp)
                return 1
                ;;
        esac
    fi

    local url="$(rp_getBinaryUrl $idx)"
    [[ "$url" == "notest" ]] && return 0
    [[ -z "$url" ]] && return 1

    if rp_hasBinaries; then
        wget --spider -q "$url"
        return $?
    fi
    return 1
}

function rp_getBinaryDate() {
    local idx="$1"
    local id="$(rp_getIdFromIdx $idx)"
    local url="$(rp_getBinaryUrl $idx)"
    [[ -z "$url" || "$url" == "notest" ]] && return 1

    local bin_date=$(wget \
        --server-response --spider -q \
        "$url" 2>&1 \
        | grep -i "Last-Modified" \
        | cut -d" " -f4-)
    echo "$bin_date"
    return 0
}

function rp_hasNewerBinary() {
    local idx="$1"
    eval $(rp_getPackageInfo "$idx")
    [[ -z "$pkg_date" ]] && return 2
    local bin_date="$(rp_getBinaryDate $idx)"
    [[ -z "$bin_date" ]] && return 2

    local pkg_date_unix="$(date -d "$pkg_date" +%s)"
    local bin_date_unix="$(date -d "$bin_date" +%s)"
    if [[ "$bin_date_unix" -gt "$pkg_date_unix" ]]; then
        return 0
    fi

    return 1
}

function rp_getInstallPath() {
    local idx="$1"
    local id=$(rp_getIdFromIdx "$idx")
    echo "$rootdir/${__mod_type[$idx]}/$id"
}

function rp_installBin() {
    rp_hasBinaries || fatalError "There are no binary archives for platform $__platform"
    local archive="$md_id.tar.gz";
    local dest="$rootdir/$md_type"

    local cmd_out

    # create temporary folder
    local tmp=$(mktemp -d)

    if downloadAndVerify "$__binary_url/$md_type/$archive" "$tmp/$archive"; then
        mkdir -p "$dest"
        if tar -xvf "$tmp/$archive" -C "$dest"; then
            rm -rf "$tmp"
            return 0
        else
            md_ret_errors+=("Archive $archive failed to unpack correctly to $dest")
        fi
    fi

    rm -rf "$tmp"
    return 1
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
    local dest="$__tmpdir/archives/$__binary_path/$md_type"
    mkdir -p "$dest"
    rm -f "$dest/$archive"
    if tar cvzf "$dest/$archive" -C "$rootdir/$md_type" "$md_id"; then
        if signFile "$dest/$archive"; then
            chown $user:$user "$dest/$archive" "$dest/$archive.asc"
            return 0
        fi
    fi
    rm -f "$dest/$archive" "$dest/$archive.asc"
    return 1
}

function rp_hasModule() {
    local id="$1"
    [[ -n "$(rp_getIdxFromId $id)" ]] && return 0
    return 1
}

function rp_installModule() {
    local idx="$1"
    local mode="$2"
    [[ -z "$mode" ]] && mode="_auto_"
    rp_callModule "$idx" "$mode" || return 1
    return 0
}

# this is a basic / temporary fix to record the source of a package when updating (binary vs source)
# packaging will be overhauled at a later date
function rp_setPackageInfo() {
    local idx="$1"
    local install_path="$(rp_getInstallPath $idx)"
    [[ ! -d "$install_path" ]] && return 1
    local pkg="$install_path/retropie.pkg"
    local origin="$2"

    iniConfig "=" '"' "$pkg"
    iniSet "pkg_origin" "$origin"
    local pkg_date
    if [[ "$origin" == "binary" ]]; then
        pkg_date="$(rp_getBinaryDate $idx)"
    else
        pkg_date="$(date)"
    fi
    iniSet "pkg_date" "$pkg_date"
}

function rp_getPackageInfo() {
    local pkg="$(rp_getInstallPath $1)/retropie.pkg"

    local pkg_origin="unknown"

    local pkg_date
    if [[ -f "$pkg" ]]; then
        iniConfig "=" '"' "$pkg"
        iniGet "pkg_origin"
        [[ -n "$ini_value" ]] && pkg_origin="$ini_value"
        iniGet "pkg_date"
        [[ -n "$ini_value" ]] && pkg_date="$ini_value"
    fi
    echo "local pkg_origin=\"$pkg_origin\""
    echo "local pkg_date=\"$pkg_date\""
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

    # flags are parsed in the order provided in the module - so the !all flag only makes sense first
    # by default modules are enabled for all platforms
    if [[ "$__ignore_flags" -ne 1 ]]; then
        for flag in "${flags[@]}"; do
            # !all excludes the module from all platforms
            if [[ "$flag" == "!all" ]]; then
                valid=0
                continue
            fi
            # flags without ! make the module valid for the platform
            if isPlatform "$flag"; then
                valid=1
                continue
            fi
            # flags with !flag will exclude the module for the platform
            if [[ "$flag" =~ ^\!(.+) ]] && isPlatform "${BASH_REMATCH[1]}"; then
                valid=0
                continue
            fi
        done
    fi

    local sections=($rp_module_section)
    # get default section
    rp_module_section="${sections[0]}"

    # loop through any additional flag=section parameters
    local flag section
    for section in "${sections[@]:1}"; do
        section=(${section/=/ })
        flag="${section[0]}"
        section="${section[1]}"
        isPlatform "$flag" && rp_module_section="$section"
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
    __mod_idx=()
    __mod_id=()
    __mod_type=()
    __mod_desc=()
    __mod_help=()
    __mod_licence=()
    __mod_section=()
    __mod_flags=()

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
