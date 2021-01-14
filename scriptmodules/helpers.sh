#!/bin/bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

## @file helpers.sh
## @brief RetroPie helpers library
## @copyright GPLv3

## @fn printMsgs()
## @param type style of display to use - dialog, console or heading
## @param message string or array of messages to display
## @brief Prints messages in a variety of ways.
function printMsgs() {
    local type="$1"
    shift
    if [[ "$__nodialog" == "1" && "$type" == "dialog" ]]; then
        type="console"
    fi
    for msg in "$@"; do
        [[ "$type" == "dialog" ]] && dialog --backtitle "$__backtitle" --cr-wrap --no-collapse --msgbox "$msg" 20 60 >/dev/tty
        [[ "$type" == "console" ]] && echo -e "$msg"
        [[ "$type" == "heading" ]] && echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$msg\n= = = = = = = = = = = = = = = = = = = = =\n"
    done
    return 0
}

## @fn printHeading()
## @param message string or array of messages to display
## @brief Calls PrintMsgs with "heading" type.
function printHeading() {
    printMsgs "heading" "$@"
}

## @fn fatalError()
## @param message string or array of messages to display
## @brief Calls PrintMsgs with "heading" type, and exits immediately.
function fatalError() {
    printHeading "Error"
    echo -e "$1"
    joy2keyStop
    exit 1
}

# @fn fnExists()
# @param name name of function to check for
# @brief Checks if function name exists.
# @retval 0 if the function name exists
# @retval 1 if the function name does not exist
function fnExists() {
    declare -f "$1" > /dev/null
    return $?
}

function ask() {
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

## @fn runCmd()
## @param command command to run
## @brief Calls command and record any non zero return codes for later printing.
## @return whatever the command returns.
function runCmd() {
    local ret
    "$@"
    ret=$?
    if [[ "$ret" -ne 0 ]]; then
        md_ret_errors+=("Error running '$*' - returned $ret")
    fi
    return $ret
}

## @fn hasFlag()
## @param string string to search in
## @param flag flag to search for
## @brief Checks for a flag in a string (consisting of space separated flags).
## @retval 0 if the flag was found
## @retval 1 if the flag was not found
function hasFlag() {
    local string="$1"
    local flag="$2"
    [[ -z "$string" || -z "$flag" ]] && return 1

    if [[ "$string" =~ (^| )$flag($| ) ]]; then
        return 0
    else
        return 1
    fi
}

## @fn isPlatform()
## @param platform
## @brief Test for current platform / platform flags.
function isPlatform() {
    local flag="$1"
    if hasFlag "${__platform_flags[*]}" "$flag"; then
        return 0
    fi
    return 1
}

## @fn addLineToFile()
## @param line line to add
## @param file file to add line to
## @brief Adds a new line of text to a file.
function addLineToFile() {
    if [[ -f "$2" ]]; then
        cp -p "$2" "$2.bak"
    else
        sed -i --follow-symlinks '$a\' "$2"
    fi

    echo "$1" >> "$2"
}

## @fn editFile()
## @param file file to edit
## @brief Opens an editing dialog for specified file.
function editFile() {
    local file="$1"
    local cmd=(dialog --backtitle "$__backtitle" --editbox "$file" 22 76)
    local choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && echo "$choice" >"$file"
}

## @fn hasPackage()
## @param package name of Debian package
## @param version requested version (optional)
## @param comparison type of comparison - defaults to `ge` (greater than or equal) if a version parameter is provided.
## @brief Test for an installed Debian package / package version.
## @retval 0 if the requested package / version was installed
## @retval 1 if the requested package / version was not installed
function hasPackage() {
    local pkg="$1"
    local req_ver="$2"
    local comp="$3"
    [[ -z "$comp" ]] && comp="ge"

    local ver
    local status
    local out=$(dpkg-query -W --showformat='${Status} ${Version}' $1 2>/dev/null)
    if [[ "$?" -eq 0 ]]; then
        ver="${out##* }"
        status="${out% *}"
    fi

    local installed=0
    [[ "$status" == *"ok installed" ]] && installed=1
    # if we are not checking version
    if [[ -z "$req_ver" ]]; then
        # if the package is installed return true
        [[ "$installed" -eq 1 ]] && return 0
    else
        # if checking version and the package is not installed we need to clear "ver" as it may contain
        # the version number of a removed package and give a false positive with compareVersions.
        # we still need to do the version check even if not installed due to the varied boolean operators
        [[ "$installed" -eq 0 ]] && ver=""

        compareVersions "$ver" "$comp" "$req_ver" && return 0
    fi
    return 1
}

## @fn aptUpdate()
## @brief Calls apt-get update (if it has not been called before).
function aptUpdate() {
    if [[ "$__apt_update" != "1" ]]; then
        apt-get update
        __apt_update="1"
    fi
}

## @fn aptInstall()
## @param packages package / space separated list of packages to install
## @brief Calls apt-get install with the packages provided.
function aptInstall() {
    aptUpdate
    apt-get install -y "$@"
    return $?
}

## @fn aptRemove()
## @param packages package / space separated list of packages to install
## @brief Calls apt-get remove with the packages provided.
function aptRemove() {
    aptUpdate
    apt-get remove -y "$@"
    return $?
}

function _mapPackage() {
    local pkg="$1"
    case "$pkg" in
        libraspberrypi-bin)
            isPlatform "osmc" && pkg="rbp-userland-osmc"
            isPlatform "xbian" && pkg="xbian-package-firmware"
            ;;
        libraspberrypi-dev)
            isPlatform "osmc" && pkg="rbp-userland-dev-osmc"
            isPlatform "xbian" && pkg="xbian-package-firmware"
            ;;
        mali-fbdev)
            isPlatform "vero4k" && pkg=""
            ;;
        # handle our custom package alias LINUX-HEADERS
        LINUX-HEADERS)
            if isPlatform "rpi"; then
                pkg="raspberrypi-kernel-headers"
            elif [[ -z "$__os_ubuntu_ver" ]]; then
                pkg="linux-headers-$(uname -r)"
            else
                pkg="linux-headers-generic"
            fi
            ;;
        # map libpng-dev to libpng12-dev for Jessie
        libpng-dev)
            compareVersions "$__os_debian_ver" lt 9 && pkg="libpng12-dev"
            ;;
        libsdl1.2-dev)
            rp_hasModule "sdl1" && pkg="RP sdl1 $pkg"
            ;;
        libsdl2-dev)
            if rp_hasModule "sdl2"; then
                # check whether to use our own sdl2 - can be disabled to resolve issues with
                # mixing custom 64bit sdl2 and os distributed i386 version on multiarch
                local own_sdl2=1
                # default to off for x11 targets due to issues with dependencies with recent
                # Ubuntu (19.04). eg libavdevice58 requiring exactly 2.0.9 sdl2.
                isPlatform "x11" && own_sdl2=0
                iniConfig " = " '"' "$configdir/all/retropie.cfg"
                iniGet "own_sdl2"
                if [[ "$ini_value" == "1" ]]; then
                    own_sdl2=1
                elif [[ "$ini_value" == "0" ]]; then
                    own_sdl2=0
                fi
                [[ "$own_sdl2" -eq 1 ]] && pkg="RP sdl2 $pkg"
            fi
            ;;
    esac
    echo "$pkg"
}

## @fn getDepends()
## @param packages package / space separated list of packages to install
## @brief Installs packages if they are not installed.
## @retval 0 on success
## @retval 1 on failure
function getDepends() {
    local own_pkgs=()
    local apt_pkgs=()
    local all_pkgs=()
    local pkg
    for pkg in "$@"; do
        pkg=($(_mapPackage "$pkg"))
        # manage our custom packages (pkg = "RP module_id pkg_name")
        if [[ "${pkg[0]}" == "RP" ]]; then
            # if removing, check if any version is installed and queue for removal via the custom module
            if [[ "$md_mode" == "remove" ]]; then
                if hasPackage "${pkg[2]}"; then
                    own_pkgs+=("${pkg[1]}")
                    all_pkgs+=("${pkg[2]}(custom)")
                fi
            else
                # if installing check if our version is installed and queue for installing via the custom module
                if hasPackage "${pkg[2]}" $(get_pkg_ver_${pkg[1]}) "ne"; then
                    own_pkgs+=("${pkg[1]}")
                    all_pkgs+=("${pkg[2]}(custom)")
                fi
            fi
            continue
        fi

        if [[ "$md_mode" == "remove" ]]; then
            # add package to apt_pkgs for removal if installed
            if hasPackage "$pkg"; then
                apt_pkgs+=("$pkg")
                all_pkgs+=("$pkg")
            fi
        else
            # add package to apt_pkgs for installation if not installed
            if ! hasPackage "$pkg"; then
                apt_pkgs+=("$pkg")
                all_pkgs+=("$pkg")
            fi
        fi

    done


    # return if no packages required
    [[ ${#apt_pkgs[@]} -eq 0 && ${#own_pkgs[@]} -eq 0 ]] && return

    # if we are removing, then remove packages, do an autoremove to clean up additional packages and return
    if [[ "$md_mode" == "remove" ]]; then
        printMsgs "console" "Removing dependencies: ${all_pkgs[*]}"
        for pkg in ${own_pkgs[@]}; do
            rp_callModule "$pkg" remove
        done
        apt-get remove --purge -y "${apt_pkgs[@]}"
        apt-get autoremove --purge -y
        return 0
    fi

    printMsgs "console" "Did not find needed dependencies: ${all_pkgs[*]}. Trying to install them now."

    # install any custom packages
    for pkg in ${own_pkgs[@]}; do
       rp_callModule "$pkg" _auto_
    done

    aptInstall --no-install-recommends "${apt_pkgs[@]}"

    local failed=()
    # check the required packages again rather than return code of apt-get,
    # as apt-get might fail for other reasons (eg other half installed packages)
    for pkg in ${apt_pkgs[@]}; do
        if ! hasPackage "$pkg"; then
            # workaround for installing samba in a chroot (fails due to failed smbd service restart)
            # we replace the init.d script with an empty script so the install completes
            if [[ "$pkg" == "samba" && "$__chroot" -eq 1 ]]; then
                mv /etc/init.d/smbd /etc/init.d/smbd.old
                echo "#!/bin/sh" >/etc/init.d/smbd
                chmod u+x /etc/init.d/smbd
                apt-get -f install
                mv /etc/init.d/smbd.old /etc/init.d/smbd
            else
                failed+=("$pkg")
            fi
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        md_ret_errors+=("Could not install package(s): ${failed[*]}.")
        return 1
    fi

    return 0
}


## @fn rpSwap()
## @param command *on* to add swap if needed and *off* to remove later
## @param memory total memory needed (swap added = memory needed - available memory)
## @brief Adds additional swap to the system if needed.
function rpSwap() {
    local command=$1
    local swapfile="$__swapdir/swap"
    case $command in
        on)
            rpSwap off
            local needed=$2
            local size=$((needed - __memory_avail))
            mkdir -p "$__swapdir/"
            if [[ $size -ge 0 ]]; then
                echo "Adding $size MB of additional swap"
                fallocate -l ${size}M "$swapfile"
                chmod 600 "$swapfile"
                mkswap "$swapfile"
                swapon "$swapfile"
            fi
            ;;
        off)
            echo "Removing additional swap"
            swapoff "$swapfile" 2>/dev/null
            rm -f "$swapfile"
            ;;
    esac
}

## @fn gitPullOrClone()
## @param dest destination directory
## @param repo repository to clone or pull from
## @param branch branch to clone or pull from (optional)
## @param commit specific commit to checkout (optional - requires branch to be set)
## @param depth depth parameter for git. (optional)
## @brief Git clones or pulls a repository.
## @details depth parameter will default to 1 (shallow clone) so long as __persistent_repos isn't set.
## A depth parameter of 0 will do a full clone with all history.
function gitPullOrClone() {
    local dir="$1"
    local repo="$2"
    local branch="$3"
    [[ -z "$branch" ]] && branch="master"
    local commit="$4"
    local depth="$5"
    if [[ -z "$depth" && "$__persistent_repos" -ne 1 && -z "$commit" ]]; then
        depth=1
    else
        depth=0
    fi

    if [[ -d "$dir/.git" ]]; then
        pushd "$dir" > /dev/null
        runCmd git checkout "$branch"
        runCmd git pull
        runCmd git submodule update --init --recursive
        popd > /dev/null
    else
        local git="git clone --recursive"
        if [[ "$depth" -gt 0 ]]; then
            git+=" --depth $depth"
        fi
        git+=" --branch $branch"
        printMsgs "console" "$git \"$repo\" \"$dir\""
        runCmd $git "$repo" "$dir"
    fi

    if [[ -n "$commit" ]]; then
        printMsgs "console" "Winding back $repo->$branch to commit: #$commit"
        git -C "$dir" branch -D "$commit" &>/dev/null
        runCmd git -C "$dir" checkout -f "$commit" -b "$commit"
    fi

    branch=$(runCmd git -C "$dir" rev-parse --abbrev-ref HEAD)
    commit=$(runCmd git -C "$dir" rev-parse HEAD)
    printMsgs "console" "HEAD is now in branch '$branch' at commit '$commit'"
}

# @fn setupDirectories()
# @brief Makes sure some required retropie directories and files are created.
function setupDirectories() {
    mkdir -p "$rootdir"
    mkUserDir "$datadir"
    mkUserDir "$romdir"
    mkUserDir "$biosdir"
    mkUserDir "$configdir"
    mkUserDir "$configdir/all"

    # some home folders for configs that modules rely on
    mkUserDir "$home/.cache"
    mkUserDir "$home/.config"
    mkUserDir "$home/.local"
    mkUserDir "$home/.local/share"

    # make sure we have inifuncs.sh in place and that it is up to date
    mkdir -p "$rootdir/lib"
    local helper_libs=(inifuncs.sh archivefuncs.sh)
    for helper in "${helper_libs[@]}"; do
        if [[ ! -f "$rootdir/lib/$helper" || "$rootdir/lib/$helper" -ot "$scriptdir/scriptmodules/$helper" ]]; then
            cp --preserve=timestamps "$scriptdir/scriptmodules/$helper" "$rootdir/lib/$helper"
        fi
    done

    # create template for autoconf.cfg and make sure it is owned by $user
    local config="$configdir/all/autoconf.cfg"
    if [[ ! -f "$config" ]]; then
        echo "# this file can be used to enable/disable retropie autoconfiguration features" >"$config"
    fi
    chown $user:$user "$config"
}

## @fn rmDirExists()
## @param dir directory to remove
## @brief Removes a directory and all contents if it exists.
function rmDirExists() {
    if [[ -d "$1" ]]; then
        rm -rf "$1"
    fi
}

## @fn mkUserDir()
## @param dir directory to create
## @brief Creates a directory owned by the current user.
function mkUserDir() {
    mkdir -p "$1"
    chown $user:$user "$1"
}

## @fn mkRomDir()
## @param dir rom directory to create
## @brief Creates a directory under $romdir owned by the current user.
function mkRomDir() {
    mkUserDir "$romdir/$1"
    if [[ "$1" == "megadrive" ]]; then
        pushd "$romdir"
        ln -snf "$1" "genesis"
        popd
    fi
}

## @fn moveConfigDir()
## @param from source directory
## @param to destination directory
## @brief Moves the contents of a folder and symlinks to the new location.
function moveConfigDir() {
    local from="$1"
    local to="$2"

    # if we are in remove mode - remove the symlink
    if [[ "$md_mode" == "remove" ]]; then
        [[ -h "$from" ]] && rm -f "$from"
        return
    fi

    mkUserDir "$to"
    # move any old configs to the new location
    if [[ -d "$from" && ! -h "$from" ]]; then
        cp -a "$from/." "$to/"
        rm -rf "$from"
    fi
    ln -snf "$to" "$from"
    # set ownership of the actual link to $user
    chown -h $user:$user "$from"
}

## @fn moveConfigFile()
## @param from source file
## @param to destination file
## @brief Moves the file and symlinks to the new location.
function moveConfigFile() {
    local from="$1"
    local to="$2"

    # if we are in remove mode - remove the symlink
    if [[ "$md_mode" == "remove" && -h "$from" ]]; then
        rm -f "$from"
        return
    fi

    # move old file
    if [[ -f "$from" && ! -h "$from" ]]; then
        mv "$from" "$to"
    fi
    ln -sf "$to" "$from"
    # set ownership of the actual link to $user
    chown -h $user:$user "$from"
}

## @fn diffFiles()
## @param file1 file to compare
## @param file2 file to compare
## @brief Compares two files using diff.
## @retval 0 if the files were the same
## @retval 1 if they were not
## @retval >1 an error occurred
function diffFiles() {
    diff -q "$1" "$2" >/dev/null
    return $?
}

## @fn compareVersions()
## @param version first version to compare
## @param operator operator to use (lt le eq ne ge gt)
## @brief version second version to compare
## @retval 0 if the comparison was true
## @retval 1 if the comparison was false
function compareVersions() {
    dpkg --compare-versions "$1" "$2" "$3" >/dev/null
    return $?
}

## @fn dirIsEmpty()
## @param path path to directory
## @param files_only set to 1 to ignore sub directories
## @retval 0 if the directory is empty
## @retval 1 if the directory is not empty
function dirIsEmpty() {
    if [[ "$2" -eq 1 ]]; then
        [[ -z "$(ls -lA1 "$1" | grep "^-")" ]] && return 0
    else
        [[ -z "$(ls -A "$1")" ]] && return 0
    fi
    return 1
}

## @fn copyDefaultConfig()
## @param from source file
## @param to destination file
## @brief Copies a default configuration.
## @details Copies from the source file to the destination file if the destination
## file doesn't exist. If the destination is the same nothing is done. If different
## the source is copied to `$destination.rp-dist`.
function copyDefaultConfig() {
    local from="$1"
    local to="$2"
    # if the destination exists, and is different then copy the config as name.rp-dist
    if [[ -f "$to" ]]; then
        if ! diffFiles "$from" "$to"; then
            to+=".rp-dist"
            printMsgs "console" "Copying new default configuration to $to"
            cp "$from" "$to"
        fi
    else
        printMsgs "console" "Copying default configuration to $to"
        cp "$from" "$to"
    fi

    chown $user:$user "$to"
}

## @fn renameModule()
## @param from source file
## @param to destination file
## @brief Renames an existing module.
## @details Renames an existing module, moving it's install folder to the new location
## and changing any references to it in `emulators.cfg`.
function renameModule() {
    local from="$1"
    local to="$2"
    # move from old location and update emulators.cfg
    if [[ -d "$rootdir/$md_type/$from" ]]; then
        rm -rf "$rootdir/$md_type/$to"
        mv "$rootdir/$md_type/$from" "$rootdir/$md_type/$to"
        # replace any default = "$from"
        sed -i --follow-symlinks "s/\"$from\"/\"$to\"/g" "$configdir"/*/emulators.cfg
        # replace any $from = "cmdline"
        sed -i --follow-symlinks "s/^$from\([ =]\)/$to\1/g" "$configdir"/*/emulators.cfg
        # replace any paths with /$from/
        sed -i --follow-symlinks "s|/$from/|/$to/|g" "$configdir"/*/emulators.cfg
    fi
}

## @fn addUdevInputRules()
## @brief Creates a udev rule to adjust input device permissions.
## @details Creates a udev rule in `/etc/udev/rules.d/99-input.rules` to
## make everything in `/dev/input` it writable by any user in group `input`.
function addUdevInputRules() {
    if [[ ! -f /etc/udev/rules.d/99-input.rules ]]; then
        echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules
    fi
    # remove old 99-evdev.rules
    rm -f /etc/udev/rules.d/99-evdev.rules
}

## @fn setDispmanx()
## @param module_id name of module to add dispmanx flag for
## @param status initial status of flag (0 or 1)
## @brief Sets a dispmanx flag for a module.
## @details Set a dispmanx flag for a module as to whether it should use the
## sdl1 dispmanx backend by default or not (0 for framebuffer, 1 for dispmanx).
function setDispmanx() {
    isPlatform "dispmanx" || return
    local mod_id="$1"
    local status="$2"
    iniConfig "=" "\"" "$configdir/all/dispmanx.cfg"
    iniSet $mod_id "$status"
    chown $user:$user "$configdir/all/dispmanx.cfg"
}

## @fn iniFileEditor()
## @param delim ini file delimiter eg. ' = '
## @param quote ini file quoting character eg. '"'
## @param config ini file to edit
## @brief Allows editing of ini files with a user friendly dialog based gui.
## @details Some arrays need to be configured before calling this, which are
## used to display what can be edited and the options available.
##
## The first array is `$ini_titles` which provides the titles for each
## entry..
##
## The second array is `$ini_descs` which contains a help description for each
## entry.
##
## The third array is `$ini_options` which contains multiple space separated
## strings in each element to control how each entry should be managed.
##
## The `$ini_options` array is constructed as follows:
##
## If the first string is `_function_` then the next string should be a function
## name that will handle that entry. The function will be called with a parameter
## `get` or `set`. The function should return the value for get via `echo`
## and should handle any gui functionality when called with `set`. This can be
## used for example to build custom dialogs.
##
## If the first option is anything else, it is assumed to be a key name, followed
## by a control type and a list of parameters.
##
## Control types are:
##  * `_id_` map the following values to an id
##  * `_string_` allow the value to be inputted by the user
##  * `_file_` select from a list of files. The following values are wildcard,
##    then file path.
##
## If none of the above, then the rest of the array element should be a list of
## possible values for the key.
##
## Some examples for ini_options:
##
##     ini_options=('video_smooth true false')
## Allow setting of the key `video_smooth` with the values of *true* or *false*
##
##     ini_options=('aspect_ratio_index _id_ 4:3 16:9 16:10)
## Allow setting of the key `aspect_ratio_index` with the values 0 1 or 2 which
## correspond to the ratios. The user is shown the ratios, but the ini configuration
## is set to the id (4:3 = 0, 16:9 = 1, 16:10 = 2).
##
##     ini_options=('_function_ _video_fullscreen_configedit')
## The function `_video_fullscreen_configedit` is called with *get* or *set*
## to manage this entry.
##
##     ini_options=("video_shader _file_ *.*p $rootdir/emulators/retroarch/shader")
## The key `video_shader` will be able to be set to a list of files in
## `$rootdir/emulators/retroarch/shader` that match the wildcard `*.*p`
##
## For more examples you can check out the code in supplementary/configedit.sh
function iniFileEditor() {
    local delim="$1"
    local quote="$2"
    local config="$3"
    [[ ! -f "$config" ]] && return

    iniConfig "$delim" "$quote" "$config"
    local sel
    local value
    local option
    local title
    while true; do
        local options=()
        local params=()
        local values=()
        local keys=()
        local i=0

        # generate menu from options
        for option in "${ini_options[@]}"; do
            # split into new array (globbing safe)
            read -ra option <<<"$option"
            key="${option[0]}"
            keys+=("$key")
            params+=("${option[*]:1}")

            # if the first parameter is _function_ we call the second parameter as a function
            # so we can handle some options with a custom menu etc
            if [[ "$key" == "_function_" ]]; then
                value="$(${option[1]} get)"
            else
                # get current value
                iniGet "$key"
                if [[ -n "$ini_value" ]]; then
                    value="$ini_value"
                else
                    value="unset"
                fi
            fi

            values+=("$value")

            # add the matching value to our id in _id_ lists
            if [[ "${option[1]}" == "_id_" && "$value" != "unset" ]]; then
                value+=" - ${option[value+2]}"
            fi

            # use custom title if provided
            if [[ -n "${ini_titles[i]}" ]]; then
                title="${ini_titles[i]}"
            else
                title="$key"
            fi

            options+=("$i" "$title ($value)" "${ini_descs[i]}")

            ((i++))
        done

        local cmd=(dialog --backtitle "$__backtitle" --default-item "$sel" --item-help --help-button --menu "Please choose the setting to modify in $config" 22 76 16)
        sel=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${sel[@]:0:4}" == "HELP" ]]; then
            printMsgs "dialog" "${sel[@]:5}"
            continue
        fi

        [[ -z "$sel" ]] && break

        # if the key is _function_ we handle the option with a custom function
        if [[ "${keys[sel]}" == "_function_" ]]; then
            "${params[sel]}" set "${values[sel]}"
            continue
        fi

        # process the editing of the option
        i=0
        options=("U" "unset")
        local default=""

        # split into new array (globbing safe)
        read -ra params <<<"${params[sel]}"

        local mode="${params[0]}"

        case "$mode" in
            _string_)
                options+=("E" "Edit (Currently ${values[sel]})")
                ;;
            _file_)
                local match="${params[1]}"
                local path="${params[*]:2}"
                local file
                while read file; do
                    [[ "${values[sel]}" == "$file" ]] && default="$i"
                    file="${file//$path\//}"
                    options+=("$i" "$file")
                    ((i++))
                done < <(find -L "$path" -type f -name "$match" | sort)
                ;;
            _id_|*)
                [[ "$mode" == "_id_" ]] && params=("${params[@]:1}")
                for option in "${params[@]}"; do
                    if [[ "$mode" == "_id_" ]]; then
                        [[ "${values[sel]}" == "$i" ]] && default="$i"
                    else
                        [[ "${values[sel]}" == "$option" ]] && default="$i"
                    fi
                    options+=("$i" "$option")
                    ((i++))
                done
                ;;
        esac
        [[ -z "$default" ]] && default="U"
        # display values
        cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Please choose the value for ${keys[sel]}" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        # if it is a _string_ type we will open an inputbox dialog to get a manual value
        if [[ -z "$choice" ]]; then
            continue
        elif [[ "$choice" == "E" ]]; then
            [[ "${values[sel]}" == "unset" ]] && values[sel]=""
            cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the value for ${keys[sel]}" 10 60 "${values[sel]}")
            value=$("${cmd[@]}" 2>&1 >/dev/tty)
        elif [[ "$choice" == "U" ]]; then
            value=""
        else
            if [[ "$mode" == "_id_" ]]; then
                value="$choice"
            else
                # get the actual value from the options array
                local index=$((choice*2+3))
                if [[ "$mode" == "_file_" ]]; then
                    value="$path/${options[index]}"
                else
                    value="${options[index]}"
                fi
            fi
        fi

        if [[ "$choice" == "U" ]]; then
            iniUnset "${keys[sel]}" "$value"
        else
            iniSet "${keys[sel]}" "$value"
        fi

    done
}

## @fn setESSystem()
## @param fullname full name of system
## @param name short name of system
## @param path rom path
## @param extension file extensions to show
## @param command command to run
## @param platform name of platform (used by es for scraping)
## @param theme name of theme to use
## @brief Adds a system entry for Emulation Station (to /etc/emulationstation/es_systems.cfg).
function setESSystem() {
    local function
    for function in $(compgen -A function _add_system_); do
        "$function" "$@"
    done
}

## @fn ensureSystemretroconfig()
## @param system system to create retroarch.cfg for
## @param shader set a default shader to use (deprecated)
## @brief Creates a default retroarch.cfg for specified system in `/opt/retropie/configs/$system/retroarch.cfg`.
function ensureSystemretroconfig() {
    local system="$1"
    local shader="$2"

    if [[ ! -d "$configdir/$system" ]]; then
        mkUserDir "$configdir/$system"
    fi

    local config="$(mktemp)"
    # add the initial comment regarding include order
    echo -e "# Settings made here will only override settings in the global retroarch.cfg if placed above the #include line\n" >"$config"

    # add the per system default settings
    iniConfig " = " '"' "$config"
    iniSet "input_remapping_directory" "$configdir/$system/"

    if [[ -n "$shader" ]]; then
        iniUnset "video_smooth" "false"
        iniSet "video_shader" "$emudir/retroarch/shader/$shader"
        iniUnset "video_shader_enable" "true"
    fi

    # include the main retroarch config
    echo -e "\n#include \"$configdir/all/retroarch.cfg\"" >>"$config"

    copyDefaultConfig "$config" "$configdir/$system/retroarch.cfg"
    rm "$config"
}

## @fn setRetroArchCoreOption()
## @param option option to set
## @param value value to set
## @brief Sets a retroarch core option in `$configdir/all/retroarch-core-options.cfg`.
function setRetroArchCoreOption() {
    local option="$1"
    local value="$2"
    iniConfig " = " "\"" "$configdir/all/retroarch-core-options.cfg"
    iniGet "$option"
    if [[ -z "$ini_value" ]]; then
        iniSet "$option" "$value"
    fi
    chown $user:$user "$configdir/all/retroarch-core-options.cfg"
}

## @fn setConfigRoot()
## @param dir directory under $configdir to use
## @brief Sets module config root `$md_conf_root` to subfolder from `$configdir`
## @details This is used for ports that are not actually in scriptmodules/ports
## as they would get the wrong config root otherwise.
function setConfigRoot() {
    local dir="$1"
    md_conf_root="$configdir"
    [[ -n "$dir" ]] && md_conf_root+="/$dir"
    mkUserDir "$md_conf_root"
}

## @fn loadModuleConfig()
## @param params space separated list of key=value parameters
## @brief Load the settings for a module.
## @details This allows modules to quickly load some settings from an ini file.
## It can provide a shortcut way to load a set of keys from an ini file into
## variables.
##
## It requires iniConfig to be called first to specify the format and file.
## eg.
##
##     iniConfig " = " '"' "$configdir/all/mymodule.cfg"
##     eval $(loadModuleConfig \
##        'some_option=1' \
##        'another_option=2'
##
## This would load the keys `some_option` and `another_option` into local
## variables `some_option` and `another_option`. If the keys did not exist
## in mymodule.cfg the variables would be initialised to 1 and 2.
function loadModuleConfig() {
    local options=("$@")
    local option
    local key
    local value

    for option in "${options[@]}"; do
        option=(${option/=/ })
        key="${option[0]}"
        value="${option[@]:1}"
        iniGet "$key"
        if [[ -z "$ini_value" ]]; then
            iniSet "$key" "$value"
            echo "local $key=\"$value\""
        else
            echo "local $key=\"$ini_value\""
        fi
    done
}

## @fn applyPatch()
## @param patch filename of patch to apply
## @brief Apply a patch if it has not already been applied to current folder.
## @details This is used for applying patches against upstream code.
## @retval 0 on success
## @retval 1 on failure
function applyPatch() {
    local patch="$1"
    local patch_applied="${patch##*/}.applied"

    if [[ ! -f "$patch_applied" ]]; then
        if patch -f -p1 <"$patch"; then
            touch "$patch_applied"
            printMsgs "console" "Successfully applied patch: $patch"
        else
            md_ret_errors+=("$md_id patch $patch failed to apply")
            return 1
        fi
    fi
    return 0
}

## @fn download()
## @param url url of file
## @param dest destination name (optional), use - for stdout
## @brief Download a file
## @details Download a file - if the dest parameter is omitted, the file will be downloaded to the current directory.
## If the destination name is a hyphen (-), then the file will be outputted to stdout, for piping to another command
## or retrieving the contents directly to a variable.
## @retval 0 on success
function download() {
    local url="$1"
    local dest="$2"

    # if no destination, get the basename from the url (supported by GNU basename)
    [[ -z "$dest" ]] && dest="${PWD}/$(basename "$url")"

    # set up additional file descriptor for stdin
    exec 3>&1

    local cmd_err
    local ret
    # get the last non zero exit status (ignoring tee)
    set -o pipefail
    local params=()
    if [[ "$dest" == "-" ]]; then
        params+=(-s)
    else
        printMsgs "console" "Downloading $url to $dest ..."
        params+=(-o "$dest")
    fi
    params+=("$url")
    # capture stderr - while passing both stdout and stderr to terminal
    cmd_err=$(curl "${params[@]}" 2>&1 1>&3 | tee /dev/stderr)
    ret="$?"
    set +o pipefail
    # remove stdin copy
    exec 3>&-

    # if download failed, remove file, log error and return error code
    if [[ "$ret" -ne 0 ]]; then
        rm "$dest"
        md_ret_errors+=("URL $url failed to download.\n\n$cmd_err")
        return "$ret"
    fi
    return 0
}

## @fn downloadAndVerify()
## @param url url of file
## @param dest destination file (optional)
## @brief Download a file and a corresponding .asc signature and verify the contents
## @details Download a file and a corresponding .asc signature and verify the contents.
## The .asc file will be downloaded to verify the file, but will be removed after downloading.
## If the dest parameter is omitted, the file will be downloaded to the current directory
## @retval 0 on success
function downloadAndVerify() {
    local url="$1"
    local dest="$2"

    # if no destination, get the basename from the url (supported by GNU basename)
    [[ -z "$dest" ]] && dest="${PWD}/$(basename "$url")"

    local cmd_out
    local ret=1
    if download "${url}.asc" "${dest}.asc"; then
        if download "$url" "$dest"; then
            cmd_out="$(gpg --verify "${dest}.asc" 2>&1)"
            ret="$?"
            if [[ "$ret" -ne 0 ]]; then
                md_ret_errors+=("$dest failed signature check:\n\n$cmd_out")
            fi
        fi
    fi
    return "$ret"
}

## @fn downloadAndExtract()
## @param url url of archive
## @param dest destination folder for the archive
## @param optional additional parameters to pass to the decompression tool.
## @brief Download and extract an archive
## @details Download and extract an archive.
## @retval 0 on success
function downloadAndExtract() {
    local url="$1"
    local dest="$2"
    shift 2
    local opts=("$@")

    local ext="${url##*.}"
    local file="${url##*/}"

    local temp="$(mktemp -d)"
    # download file, removing temporary folder and returning on error
    if ! download "$url" "$temp/$file"; then
        rm -rf "$temp"
        return 1
    fi

    mkdir -p "$dest"

    local ret
    case "$ext" in
        exe|zip)
            runCmd unzip "${opts[@]}" -o "$temp/$file" -d "$dest"
            ;;
        *)
            tar -xvf "$temp/$file" -C "$dest" "${opts[@]}"
            ;;
    esac
    ret=$?

    rm -rf "$temp"

    return $ret
}

## @fn ensureFBMode()
## @param res_x width of mode
## @param res_y height of mode
## @brief Add a framebuffer mode to /etc/fb.modes
## @details Useful for adding specific resolutions used by emulators so SDL1 can
## use them and utilise the RPI hardware scaling. Without for example a 320x240
## mode in fb.modes many of the emulators that output to the framebuffer and
## were not set to use the dispmanx SDL1 backend would just show in a small
## area of the screen.
function ensureFBMode() {
    [[ ! -f /etc/fb.modes ]] && return
    local res_x="$1"
    local res_y="$2"
    local res="${res_x}x${res_y}"
    sed -i --follow-symlinks "/$res mode/,/endmode/d" /etc/fb.modes

    cat >> /etc/fb.modes <<_EOF_
# added by RetroPie-Setup - $res mode for emulators
mode "$res"
    geometry $res_x $res_y $res_x $res_y 16
    timings 0 0 0 0 0 0 0
endmode
_EOF_
}

## @fn joy2keyStart()
## @param left mapping for left
## @param right mapping for right
## @param up mapping for up
## @param down mapping for down
## @param but1 mapping for button 1
## @param but2 mapping for button 2
## @param but3 mapping for button 3
## @param butX mapping for button X ...
## @brief Start joy2key.py process in background to map joystick presses to keyboard
## @details Arguments are curses capability names or hex values starting with '0x'
## see: http://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html
function joy2keyStart() {
    # don't start on SSH sessions
    # (check for bracket in output - ip/name in brackets over a SSH connection)
    [[ "$(who -m)" == *\(* ]] && return

    local params=("$@")
    if [[ "${#params[@]}" -eq 0 ]]; then
        params=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20 0x1b)
    fi

    # get the first joystick device (if not already set)
    [[ -c "$__joy2key_dev" ]] || __joy2key_dev="/dev/input/jsX"

    # if no joystick device, or joy2key is already running exit
    [[ -z "$__joy2key_dev" ]] || pgrep -f joy2key.py >/dev/null && return 1

    # if joy2key.py is installed run it with cursor keys for axis/dpad, and enter + space for buttons 0 and 1
    if "$scriptdir/scriptmodules/supplementary/runcommand/joy2key.py" "$__joy2key_dev" "${params[@]}" 2>/dev/null; then
        __joy2key_pid=$(pgrep -f joy2key.py)
        return 0
    fi

    return 1
}

## @fn joy2keyStop()
## @brief Stop previously started joy2key.py process.
function joy2keyStop() {
    if [[ -n $__joy2key_pid ]]; then
        kill $__joy2key_pid 2>/dev/null
        __joy2key_pid=""
        sleep 1
    fi
}

## @fn getPlatformConfig()
## @param key key to look up
## @brief gets a config from a platforms.cfg ini
## @details gets a config from a platforms.cfg ini first looking in
## `$configdir/all/platforms.cfg` then `$scriptdir/platforms.cfg`
## allowing users to override any parts of `$scriptdir/platforms.cfg`
function getPlatformConfig() {
    local key="$1"
    local conf
    for conf in "$configdir/all/platforms.cfg" "$scriptdir/platforms.cfg"; do
        [[ ! -f "$conf" ]] && continue
        iniConfig "=" '"' "$conf"
        iniGet "$key"
        [[ -n "$ini_value" ]] && break
    done
    # workaround for RetroPie platform
    [[ "$key" == "retropie_fullname" ]] && ini_value="RetroPie"
    echo "$ini_value"
}

## @fn addSystem()
## @param system system to add
## @brief adds an emulator entry / system
## @param fullname optional fullname for the frontend (if not present in platforms.cfg)
## @param exts optional extensions for the frontend (if not present in platforms.cfg)
## @details Adds a system to one of the frontend launchers
function addSystem() {
    local system="$1"
    local fullname="$2"
    local exts=($3)

    local platform="$system"
    local theme="$system"
    local cmd
    local path

    # if removing and we don't have an emulators.cfg we can remove the system from the frontends
    if [[ "$md_mode" == "remove" ]] && [[ ! -f "$md_conf_root/$system/emulators.cfg" ]]; then
        delSystem "$system" "$fullname"
        return
    fi

    # set system / platform / theme for configuration based on data in names field
    if [[ "$system" == "ports" ]]; then
        cmd="bash %ROM%"
        path="$romdir/ports"
    else
        cmd="$rootdir/supplementary/runcommand/runcommand.sh 0 _SYS_ $system %ROM%"
        path="$romdir/$system"
    fi

    exts+=("$(getPlatformConfig "${system}_exts")")

    local temp
    temp="$(getPlatformConfig "${system}_theme")"
    if [[ -n "$temp" ]]; then
        theme="$temp"
    else
        theme="$system"
    fi

    temp="$(getPlatformConfig "${system}_platform")"
    if [[ -n "$temp" ]]; then
        platform="$temp"
    else
        platform="$system"
    fi

    temp="$(getPlatformConfig "${system}_fullname")"
    [[ -n "$temp" ]] && fullname="$temp"

    exts="${exts[*]}"
    # add the extensions again as uppercase
    exts+=" ${exts^^}"

    setESSystem "$fullname" "$system" "$path" "$exts" "$cmd" "$platform" "$theme"
}

## @fn delSystem()
## @param system system to delete
## @brief Deletes a system
## @details deletes a system from all frontends.
function delSystem() {
    local system="$1"
    local fullname="$2"

    local temp
    temp="$(getPlatformConfig "${system}_fullname")"
    [[ -n "$temp" ]] && fullname="$temp"

    local function
    for function in $(compgen -A function _del_system_); do
        "$function" "$fullname" "$system"
    done
}

## @fn addPort()
## @param id id of the module / command
## @param port name of the port
## @param name display name for the launch script
## @param cmd commandline to launch
## @param game rom/game parameter (optional)
## @brief Adds a port to the emulationstation ports menu.
## @details Adds an emulators.cfg entry as with addSystem but also creates a launch script in `$datadir/ports/$name.sh`.
##
## Can also optionally take a game parameter which can be used to create multiple launch
## scripts for different games using the same engine - eg for quake
##
##     addPort "lr-tyrquake" "quake" "Quake" "$emudir/retroarch/bin/retroarch -L $md_inst/tyrquake_libretro.so --config $md_conf_root/quake/retroarch.cfg %ROM%" "$romdir/ports/quake/id1/pak0.pak"
##     addPort "lr-tyrquake" "quake" "Quake Mission Pack 2 (rogue)" "$emudir/retroarch/bin/retroarch -L $md_inst/tyrquake_libretro.so --config $md_conf_root/quake/retroarch.cfg %ROM%" "$romdir/ports/quake/id1/rogue/pak0.pak"
##
## Would add an entry in $configdir/ports/quake/emulators.cfg for lr-tyrquake (setting it to default if no default set)
## and create a launch script in $romdir/ports for each game.
function addPort() {
    local id="$1"
    local port="$2"
    local file="$romdir/ports/$3.sh"
    local cmd="$4"
    local game="$5"

    # move configurations from old ports location
    if [[ -d "$configdir/$port" ]]; then
        mv "$configdir/$port" "$md_conf_root/"
    fi

    # remove the emulator / port
    if [[ "$md_mode" == "remove" ]]; then
        delEmulator "$id" "$port"

        # remove launch script if in remove mode and the ports emulators.cfg is empty
        [[ ! -f "$md_conf_root/$port/emulators.cfg" ]] && rm -f "$file"

        # if there are no more port launch scripts we can remove ports from emulation station
        if [[ "$(find "$romdir/ports" -maxdepth 1 -name "*.sh" | wc -l)" -eq 0 ]]; then
            delSystem "ports"
        fi
        return
    fi

    mkUserDir "$romdir/ports"

    cat >"$file" << _EOF_
#!/bin/bash
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ "$port" "$game"
_EOF_

    chown $user:$user "$file"
    chmod +x "$file"

    [[ -n "$cmd" ]] && addEmulator 1 "$id" "$port" "$cmd"
    addSystem "ports"
}

## @fn addEmulator()
## @param default 1 to make the emulator / command default for the system if no default already set
## @param id unique id of the module / command
## @param name name of the system to add the emulator to
## @param cmd commandline to launch
## @brief Adds a new emulator for a system.
## @details This is the primary function for adding emulators to a system which can be
## switched between via the runcommand launch menu 
##
##     addEmulator 1 "vice-x64" "c64" "$md_inst/bin/x64 %ROM%"
##     addEmulator 0 "vice-xvic" "c64" "$md_inst/bin/xvic %ROM%"
##
## Would add two optional emulators for the c64 - with vice-x64 being the default if no default
## was already set. This adds entries to `$configdir/$system/emulators.cfg` with
##
##     id = "cmd"
##     default = id
##
## Which are then selectable from runcommand when launching roms
##
## For libretro emulators, cmd needs to only contain the path to the libretro library.
##
## eg. for the lr-fcuemm module
##
##     addEmulator 1 "$md_id" "nes" "$md_inst/fceumm_libretro.so"
function addEmulator() {
    local default="$1"
    local id="$2"
    local system="$3"
    local cmd="$4"

    # check if we are removing the system
    if [[ "$md_mode" == "remove" ]]; then
        delEmulator "$id" "$system"
        return
    fi

    # automatically add parameters for libretro modules
    if [[ "$id" == lr-* && "$cmd" =~ ^"$md_inst"[^[:space:]]*\.so ]]; then
        cmd="$emudir/retroarch/bin/retroarch -L $cmd --config $md_conf_root/$system/retroarch.cfg %ROM%"
    fi

    # create a config folder for the system / port
    mkUserDir "$md_conf_root/$system"

    # add the emulator to the $conf_dir/emulators.cfg if a commandline exists (not used for some ports)
    if [[ -n "$cmd" ]]; then
        iniConfig " = " '"' "$md_conf_root/$system/emulators.cfg"
        iniSet "$id" "$cmd"
        # set a default unless there is one already set
        iniGet "default"
        if [[ -z "$ini_value" && "$default" -eq 1 ]]; then
            iniSet "default" "$id"
        fi
        chown $user:$user "$md_conf_root/$system/emulators.cfg"
    fi
}

## @fn delEmulator()
## @param id id of emulator to delete
## @param system system to delete from
## @brief Deletes an emulator entry / system
## @details Delete the entry for the id from `$configdir/$system/emulators.cfg`.
## If there are no more emulators for the system present, it will also
## delete the system entry from the installed frontends.
function delEmulator() {
    local id="$1"
    local system="$2"

    local config="$md_conf_root/$system/emulators.cfg"
    # remove from apps list for system
    if [[ -f "$config" && -n "$id" ]]; then
        # delete emulator entry
        iniConfig " = " '"' "$config"
        iniDel "$id"
        # if it is the default - remove it - runcommand will prompt to select a new default
        iniGet "default"
        [[ "$ini_value" == "$id" ]] && iniDel "default"
        # if we no longer have any entries in the emulators.cfg file we can remove it
        grep -q "=" "$config" || rm -f "$config"
    fi

}

## @fn patchVendorGraphics()
## @param filename file to patch
## @details replace declared dependencies of old vendor graphics libraries with new names
## Temporary compatibility workaround for legacy software to work on new Raspberry Pi firmwares.
function patchVendorGraphics() {
    local filename="$1"

    # patchelf is not available on Raspbian Jessie
    compareVersions "$__os_debian_ver" lt 9 && return

    getDepends patchelf
    printMsgs "console" "Applying vendor graphics patch: $filename"
    patchelf --replace-needed libEGL.so libbrcmEGL.so \
             --replace-needed libGLES_CM.so libbrcmGLESv2.so \
             --replace-needed libGLESv1_CM.so libbrcmGLESv2.so \
             --replace-needed libGLESv2.so libbrcmGLESv2.so \
             --replace-needed libOpenVG.so libbrcmOpenVG.so \
             --replace-needed libWFC.so libbrcmWFC.so "$filename"
}

## @fn dkmsManager()
## @param mode dkms operation type
## @module_name name of dkms module
## @module_ver version of dkms module
## Helper function to manage DKMS modules installed by RetroPie
function dkmsManager() {
    local mode="$1"
    local module_name="$2"
    local module_ver="$3"
    local kernel="$(uname -r)"
    local ver

    case "$mode" in
        install)
            if dkms status | grep -q "^$module_name"; then
                dkmsManager remove "$module_name" "$module_ver"
            fi
            ln -sf "$md_inst" "/usr/src/${module_name}-${module_ver}"
            dkms install --no-initrd --force -m "$module_name" -v "$module_ver" -k "$kernel"
            if ! dkms status "$module_name/$module_ver" -k "$kernel" | grep -q installed; then
                # Force building for any kernel that has source/headers
                local k_ver
                while read k_ver; do
                    if [[ -d "$(realpath /lib/modules/$k_ver/build)" ]]; then
                        dkms install --no-initrd --force -m "$module_name/$module_ver" -k "$k_ver"
                    fi
                done < <(ls -r1 /lib/modules)
            fi
            if ! dkms status "$module_name/$module_ver" | grep -q installed; then
                md_ret_errors+=("Failed to install $md_id")
                return 1
            fi
            ;;
        remove)
            for ver in $(dkms status "$module_name" | cut -d"," -f2 | cut -d":" -f1); do
                dkms remove -m "$module_name" -v "$ver" --all
                rm -f "/usr/src/${module_name}-${ver}"
            done
            dkmsManager unload "$module_name" "$module_ver"
            ;;
        reload)
            dkmsManager unload "$module_name" "$module_ver"
            # No reason to load modules in chroot
            if [[ "$__chroot" -eq 0 ]]; then
                modprobe "$module_name"
            fi
            ;;
        unload)
            if [[ -n "$(lsmod | grep ${module_name/-/_})" ]]; then
                rmmod "$module_name"
            fi
            ;;
    esac
}

## @fn getIPAddress()
## @param dev optional specific network device to use for address lookup
## @brief Obtains the current externally routable source IP address of the machine
## @details This function first tries to obtain an external IPv4 route and
## otherwise tries an IPv6 route if the IPv4 route can not be determined.
## If no external route can be determined, nothing will be returned.
## This function uses Google's DNS servers as the external lookup address.
function getIPAddress() {
    local dev="$1"
    local ip_route

    # first try to obtain an external IPv4 route
    ip_route=$(ip -4 route get 8.8.8.8 ${dev:+dev $dev} 2>/dev/null)
    if [[ -z "$ip_route" ]]; then
        # if there is no IPv4 route, try to obtain an IPv6 route instead
        ip_route=$(ip -6 route get 2001:4860:4860::8888 ${dev:+dev $dev} 2>/dev/null)
    fi

    # if an external route was found, report its source address
    [[ -n "$ip_route" ]] && grep -oP "src \K[^\s]+" <<< "$ip_route"
}

## @fn adminRsync()
## @param src src folder on local system - eg "$__tmpdir/stats/"
## @param dest destination folder on remote system - eg "stats/"
## @param params additional rsync parameters - eg --delete
## @brief Rsyncs data to remote host for admin modules
## @details Used to rsync data to our server for admin modules. Default remote
## user is retropie, host is $__binary_host and default port is 22. These can be overridden with
## env vars __upload_user __upload_host and __upload_port
##
## The default parameters for rsync are "-av --delay-updates" - more can be added via the 3rd+ argument
function adminRsync() {
    local src="$1"
    local dest="$2"
    shift 2
    local params=("$@")

    local remote_user="$__upload_user"
    [[ -z "$remote_user" ]] && remote_user="retropie"
    local remote_host="$__upload_host"
    [[ -z "$remote_host" ]] && remote_host="$__binary_host"
    local remote_port="$__upload_port"
    [[ -z "$remote_port" ]] && remote_port=22

    rsync -av --delay-updates -e "ssh -p $remote_port" "${params[@]}" "$src" "$remote_user@$remote_host:$dest"
}

## @fn signFile()
## @param file path to file to sign
## @brief signs file with $__gpg_signing_key
## @details signs file with $__gpg_signing_key creating corresponding .asc file in the same folder
function signFile() {
    local file="$1"
    local cmd_out
    cmd_out=$(gpg --default-key "$__gpg_signing_key" --detach-sign --armor --yes "$1" 2>&1)
    if [[ "$?" -ne 0 ]]; then
        md_ret_errors+=("Failed to sign $1\n\n$cmd_out")
        return 1
    fi
    return 0
}
