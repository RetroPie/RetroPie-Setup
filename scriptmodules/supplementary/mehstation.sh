#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mehstation"
rp_module_desc="mehstation emulator frontend"
rp_module_licence="MIT https://raw.githubusercontent.com/remeh/mehstation/master/LICENSE"
rp_module_section="exp"
rp_module_flags="frontend"

function _get_database_mehstation() {
    echo "$configdir/all/mehstation/database.db"
}

function _add_system_mehstation() {
    local db="$(_get_database_mehstation)"
    [[ ! -f "$db" ]] && return 0

    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    command="${command//%ROM%/%exec%}"
    extensions="${extensions// /,}"
    NAME="$fullname" COMMAND="$command" DIR="$path" EXTS="$extensions" "/opt/retropie/supplementary/mehstation/bin/mehtadata" -db="$db" -new-platform
}

function _del_system_mehstation() {
    local db="$(_get_database_mehstation)"
    [[ ! -f "$db" ]] && return 0

    local fullname="$1"
    local name="$2"

    PLATFORM_NAME="$fullname" "/opt/retropie/supplementary/mehstation/bin/mehtadata" -db="$db" -del-platform
}

function _add_rom_mehstation() {
    local db="$(_get_database_mehstation)"
    [[ ! -f "$db" ]] && return 0

    local system_name="$1"
    local system_fullname="$2"
    local path="$3"
    local name="$4"
    local desc="$5"
    local image="$6"

    NAME="$4" FILEPATH="$path" PLATFORM_NAME="$system_fullname" DESCRIPTION="$desc" "/opt/retropie/supplementary/mehstation/bin/mehtadata" -db="$db" -new-exec

    RESOURCE="$image" FILEPATH="$path" PLATFORM_NAME="$system_fullname" TYPE="cover" "/opt/retropie/supplementary/mehstation/bin/mehtadata" -db="$db" -new-res
}

function depends_mehstation() {
    local depends=(
        cmake automake libfreeimage-dev libopenal-dev libpango1.0-dev
        libsndfile1-dev libudev-dev libasound2-dev libjpeg-dev
        libtiff5-dev libwebp-dev libsqlite3-dev libavutil-dev libavcodec-dev
        libavformat-dev libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
        libsdl2-image-dev sqlite3 golang
    )
    getDepends "${depends[@]}"
}

function sources_mehstation() {
    gitPullOrClone "$md_build" https://github.com/remeh/mehstation
    GOPATH="$md_build/mehtadata" go get github.com/remeh/mehtadata
}

function build_mehstation() {
    cd mehtadata
    GOPATH="$md_build/mehtadata" go build
    cd ..

    cmake .
    make clean
    make

    md_ret_require=(
        "$md_build/mehstation"
        "$md_build/mehtadata/bin/mehtadata"
    )
}

function install_mehstation() {
    mkdir -p "$md_inst"/{bin,share/mehstation}
    cp mehstation mehtadata/bin/mehtadata "$md_inst/bin/"
    cp -R res "$md_inst/share/"
}


function configure_mehstation() {
    # move / symlink the configuration
    moveConfigDir "$home/.config/mehstation" "$md_conf_root/all/mehstation"

    local db="$md_conf_root/all/mehstation/database.db"

    if [[ ! -f "$db" ]]; then
        local sql
        while read -r sql; do
            sudo -u $user SCHEMA="$sql" "$md_inst/bin/mehtadata" -db="$db" -init
        done < <(find "$md_inst/share/res" -name "*.sql" | sort)
    fi

    cat >/usr/bin/mehstation <<_EOF_
#!/bin/bash
pushd "$md_inst/share" >/dev/null
"$md_inst/bin/mehstation" "\$@"
popd
_EOF_
    chmod +x "/usr/bin/mehstation"

    local idx
    for idx in "${__mod_idx[@]}"; do
        if rp_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" ]] && ! hasFlag "${__mod_flags[$idx]}" "frontend"; then
            rp_callModule "$idx" configure
        fi
    done
}
