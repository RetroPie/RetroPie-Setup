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
rp_module_section="exp"
rp_module_flags="frontend"

function _add_system_mehstation() {
    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    local db="$md_conf_root/all/mehstation/database.db"

    dirIsEmpty "$path" 1 || [[ ! -f "$db" ]] && return 0

    local plat_id="$(sqlite3 "$db" "select id from platform where name='$fullname'")"
    if [[ -z "$plat_id" ]]; then
        command="${command//%ROM%/%exec%}"
        extensions="${extensions// /,}"
        plat_id="$(sqlite3 "$db" "insert into platform (name, command, discover_dir, discover_ext) values ('$fullname', '$command', '$path', '$extensions'); SELECT last_insert_rowid();")"
    fi
}

function depends_mehstation() {
    local depends=(
        cmake automake libfreeimage-dev libopenal-dev libpango1.0-dev
        libsndfile1-dev libudev-dev libasound2-dev libjpeg-dev
        libtiff5-dev libwebp-dev libsqlite3-dev libavutil-dev libavcodec-dev
        libavformat-dev git libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
        libsdl2-image-dev sqlite3
    )
    getDepends "${depends[@]}"
}

function sources_mehstation() {
    gitPullOrClone "$md_build" https://github.com/remeh/mehstation
}

function build_mehstation() {
    cmake .
    make clean
    make

    md_ret_require="$md_build/mehstation"
}

function install_mehstation() {
    mkdir -p "$md_inst"/{bin,share/mehstation}
    cp mehstation "$md_inst/bin/"
    cp -R res "$md_inst/share/"
}


function configure_mehstation() {

    # move / symlink the configuration
    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/mehstation" "$md_conf_root/all/mehstation"

    local db="$md_conf_root/all/mehstation/database.db"

    if [[ ! -f "$db" ]]; then
        sqlite3 "$db" <<\_EOF_
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE "platform"  (
    `id`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `name`  TEXT NOT NULL,
    `command`   TEXT,
    `icon`  TEXT,
    `background` TEXT,
    `type` TEXT DEFAULT 'complete', "discover_dir" TEXT, "discover_ext" TEXT);

CREATE TABLE "mehstation" (
    `name` TEXT NOT NULL PRIMARY KEY UNIQUE,
    `value` TEXT
);
INSERT INTO "mehstation" VALUES('schema','2');

CREATE TABLE "executable_resource" (
    `id`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    `executable_id` INTEGER NOT NULL,
    `type`  TEXT DEFAULT '',
    `filepath`  TEXT DEFAULT ''
);

CREATE TABLE "executable" (
    `id`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    `display_name`  TEXT DEFAULT '',
    `filepath`  TEXT DEFAULT '',
    `platform_id`   INTEGER NOT NULL,
    `description`   TEXT,
    `genres`    TEXT,
    `publisher` TEXT,
    `developer` TEXT,
    `release_date`  TEXT,
    `players`   TEXT,
    `rating`    TEXT,
    `extra_parameter`   TEXT,
    `favorite` INTEGER DEFAULT 0,
    `last_played` INTEGER DEFAULT 0
);

CREATE TABLE "mapping" (
    `id` TEXT NOT NULL,
    `left` INTEGER,
    `right` INTEGER,
    `up` INTEGER,
    `down` INTEGER,
    `a` INTEGER,
    `b` INTEGER,
    `start` INTEGER,
    `select` INTEGER,
    `l` INTEGER,
    `r` INTEGER
);

COMMIT;
_EOF_

        chown $user:$user "$db"
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
