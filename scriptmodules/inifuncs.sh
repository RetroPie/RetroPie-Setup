#!/bin/bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function fatalError() {
    echo "$1"
    exit 1
}

# arg 1: delimiter, arg 2: quote, arg 3: file
function iniConfig() {
    __ini_cfg_delim="$1"
    __ini_cfg_quote="$2"
    __ini_cfg_file="$3"
}

# arg 1: command, arg 2: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniProcess() {
    local cmd="$1"
    local key="$2"
    local value="$3"
    local file="$4"
    [[ -z "$file" ]] && file="$__ini_cfg_file"
    local delim="$__ini_cfg_delim"
    local quote="$__ini_cfg_quote"

    [[ -z "$file" ]] && fatalError "No file provided for ini/config change"
    [[ -z "$key" ]] && fatalError "No key provided for ini/config change on $file"

    # we strip the delimiter of spaces, so we can "fussy" match existing entries that have the wrong spacing
    local delim_strip=${delim// /}
    # if the stripped delimiter is empty - such as in the case of a space, just use the delimiter instead
    [[ -z "$delim_strip" ]] && delim_strip="$delim"
    local match_re="^[[:space:]#]*$key[[:space:]]*$delim_strip.*$"

    local match
    if [[ -f "$file" ]]; then
        match=$(egrep -i "$match_re" "$file" | tail -1)
    else
        touch "$file"
    fi

    if [[ "$cmd" == "del" ]]; then
        [[ -n "$match" ]] && sed -i -e "\|$(sedQuote "$match")|d" "$file"
        return 0
    fi

    [[ "$cmd" == "unset" ]] && key="# $key"

    local replace="$key$delim$quote$value$quote"
    if [[ -z "$match" ]]; then
        # add key-value pair
        echo "$replace" >> "$file"
    else
        # replace existing key-value pair
        sed -i -e "s|$(sedQuote "$match")|$(sedQuote "$replace")|g" "$file"
    fi

    local include
    # remove any retroarch.cfg include line
    if [[ "$file" =~ retroarch\.cfg$ ]]; then
        include=$(grep "^#include.*retroarch\.cfg" "$file")

        # re-add the include line
        if [[ -n "$include" ]]; then
            sed -i "/^#include.*retroarch\.cfg/d" "$file"
            echo "$include" >>"$file"
        fi
    fi
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniUnset() {
    iniProcess "unset" "$1" "$2" "$3"
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniSet() {
    iniProcess "set" "$1" "$2" "$3"
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniDel() {
    iniProcess "del" "$1" "$2" "$3"
}

# arg 1: key, arg 2: file (optional - uses file from iniConfig if not used)
# value ends up in ini_value variable
function iniGet() {
    local key="$1"
    local file="$2"
    [[ -z "$file" ]] && file="$__ini_cfg_file"
    if [[ ! -f "$file" ]]; then
        ini_value=""
        return 1
    fi

    local delim="$__ini_cfg_delim"
    local quote="$__ini_cfg_quote"
    # we strip the delimiter of spaces, so we can "fussy" match existing entries that have the wrong spacing
    local delim_strip=${delim// /}
    # if the stripped delimiter is empty - such as in the case of a space, just use the delimiter instead
    [[ -z "$delim_strip" ]] && delim_strip="$delim"

    # create a regexp to match the value based on whether we are looking for quotes or not
    local value_m
    if [[ -n "$quote" ]]; then
        value_m="$quote*\([^$quote]*\)$quote*"
    else
        value_m="\(.*\)"
    fi

    ini_value="$(sed -n "s/^[ |\t]*$key[ |\t]*$delim_strip[ |\t]*$value_m/\1/p" "$file" | tail -1)"
}

# arg 1: key, arg 2: default value (optional - is 1 if not used)
function addAutoConf() {
    local key="$1"
    local default="$2"
    local file="$configdir/all/autoconf.cfg"

    if [[ -z "$default" ]]; then
       default="1"
    fi

    iniConfig " = " '"' "$file"
    iniGet "$key"
    ini_value="${ini_value// /}"
    if [[ -z "$ini_value" ]]; then
        iniSet "$key" "$default"
    fi
}

# arg 1: key, arg 2: value
function setAutoConf() {
    local key="$1"
    local value="$2"
    local file="$configdir/all/autoconf.cfg"

    iniConfig " = " '"' "$file"
    iniSet "$key" "$value"
}

# arg 1: key
function getAutoConf(){
    local key="$1"

    iniConfig " = " '"' "$configdir/all/autoconf.cfg"
    iniGet "$key"

    [[ "$ini_value" == "1" ]] && return 0
    return 1
}

# escape backslashes and pipes for sed
function sedQuote() {
    local string="$1"
    string="${string//\\/\\\\}"
    string="${string//|/\\|}"
    echo "$string"
}