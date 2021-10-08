#!/bin/bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

## @file inifuncs.sh
## @brief RetroPie inifuncs library
## @copyright GPLv3

# @fn fatalError()
# @param message string or array of messages to display
# @brief echos message, and exits immediately.
function fatalError() {
    echo -e "$1"
    exit 1
}

# arg 1: delimiter, arg 2: quote, arg 3: file

## @fn iniConfig()
## @param delim ini file delimiter eg. ' = '
## @param quote ini file quoting character eg. '"'
## @param config ini file to edit
## @brief Configure an ini file for getting/setting values with `iniGet` and `iniSet`
function iniConfig() {
    __ini_cfg_delim="$1"
    __ini_cfg_quote="$2"
    __ini_cfg_file="$3"
}

# arg 1: command, arg 2: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)

# @fn iniProcess()
# @param command `set`, `unset` or `del`
# @param key ini key to operate on
# @param value to set
# @param file optional file to use another file than the one configured with iniConfig
# @param section optional section header within the file under which the line will be added
# @brief The main function for setting and deleting from ini files - usually
# not called directly but via iniSet iniUnset and iniDel
function iniProcess() {
    local cmd="$1"
    local key="$2"
    local value="$3"
    local file="$4"
    local section="$5"
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
    local file_temp
    if [[ -f "$file" ]]; then
        if [[ ! -z "$section" ]]; then
            # if section header exists, match after header, and before line break
            file_temp="$(awk "/$(sedQuote "$section")/,/^$/" "$file")"
            match=$(echo "$file_temp" | egrep -i "$match_re" | head -n 1)
        else
            # otherwise, use the last match in the file
            match=$(egrep -i "$match_re" "$file" | tail -1)
        fi
    else
        touch "$file"
    fi

    if [[ "$cmd" == "del" ]]; then
        [[ -n "$match" ]] && sed -i --follow-symlinks "\|$(sedQuote "$match")|d" "$file"
        return 0
    fi

    [[ "$cmd" == "unset" ]] && key="# $key"

    local replace="$key$delim$quote$value$quote"
    if [[ -z "$match" ]]; then
        # if section passed, add header if not already present
        if [[ ! -z "$section" ]]; then
            if ! grep -q -F "$section" "$file"; then
                # add blank line to signify end of previous section
                sed -i --follow-symlinks "$a\\" "$file"
                echo -e "$section" >> "$file"
            fi
            # add the key-value pair under the section header
            sed -i --follow-symlinks "/$(sedQuote "$section")/a$replace" "$file"
        else
            # make sure there is a newline then add the key-value pair
            sed -i --follow-symlinks '$a\' "$file"
            echo "$replace" >> "$file"
        fi
    else
        # replace existing key-value pair
        # if section passed, replace within section
        if [[ ! -z "$section" ]]; then
            sed -i --follow-symlinks "/$(sedQuote "$section")/,/^$/ s/$(sedQuote "$match")/$(sedQuote "$replace")/" "$file"
        else
            sed -i --follow-symlinks "s|$(sedQuote "$match")|$(sedQuote "$replace")|g" "$file"
        fi
    fi

    [[ "$file" =~ retroarch\.cfg$ ]] && retroarchIncludeToEnd "$file"
    return 0
}

## @fn iniUnset()
## @param key ini key to operate on
## @param value to Unset (key will be commented out, but the value can be changed also)
## @param file optional file to use another file than the one configured with iniConfig
## @param section optional section header within the file where the key will be found
## @brief Unset (comment out) a key / value pair in an ini file.
## @details The key does not have to exist - if it doesn't exist a new line will
## be added - eg. `# key = "value"`
##
## This function is useful for creating example configuration entries for users
## to manually enable later or if a configuration is to be disabled but left
## as an example.
function iniUnset() {
    iniProcess "unset" "$1" "$2" "$3" "$4"
}

## @fn iniSet()
## @param key ini key to operate on
## @param value to set
## @param file optional file to use another file than the one configured with iniConfig
## @param section optional section header within the file under which the line will be added
## @brief Set a key / value pair in an ini file.
## @details If the key already exists the existing line will be changed. If not
## a new line will be created.
function iniSet() {
    iniProcess "set" "$1" "$2" "$3" "$4"
}

## @fn iniDel()
## @param key ini key to operate on
## @param file optional file to use another file than the one configured with iniConfig
## @param section optional section header within the file where the key will be found
## @brief Delete a key / value pair in an ini file.
function iniDel() {
    iniProcess "del" "$1" "" "$2" "$3"
}

## @fn iniGet()
## @param key ini key to get the value of
## @param file optional file to use another file than the one configured with iniConfig
## @param section optional section header within the file under which the key should be found
## @brief Get the value of a key from an ini file.
## @details The value of the key will end up in the global ini_value variable.
function iniGet() {
    local key="$1"
    local file="$2"
    local section="$3"
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
        value_m="$quote*\([^$quote|\r]*\)$quote*"
    else
        value_m="\([^\r]*\)"
    fi

    # if section passed, search within section
    local file_temp
    if [[ ! -z "$section" ]]; then
        file_temp="$(awk "/$(sedQuote "$section")/,/^$/" "$file")"
        ini_value="$(echo "$file_temp" | sed -n "s/^[ |\t]*$key[ |\t]*$delim_strip[ |\t]*$value_m.*/\1/p" | tail -1)"
    else
        ini_value="$(sed -n "s/^[ |\t]*$key[ |\t]*$delim_strip[ |\t]*$value_m.*/\1/p" "$file" | tail -1)"
    fi
}

# @fn retroarchIncludeToEnd()
# @param file config file to process
# @brief Makes sure a `retroarch.cfg` file has the `#include` line at the end.
# @details Used in runcommand.sh and iniProcess to ensure the #include for the
# main retroarch.cfg is always at the end of a system `retroarch.cfg`. This
# is because when processing its config RetroArch will take the first value it
# finds, so any overrides need to be above the `#include` line where the global
# retroarch.cfg is included.
function retroarchIncludeToEnd() {
    local config="$1"

    [[ ! -f "$config" ]] && return

    local re="^#include.*retroarch\.cfg"

    # extract the include line (unless it is the last line in the file)
    # (remove blank lines, the last line and search for an include line in remaining lines)
    local include=$(sed '/^$/d;$d' "$config" | grep "$re")

    # if matched remove it and re-add it at the end
    if [[ -n "$include" ]]; then
        sed -i --follow-symlinks "/$re/d" "$config"
        # add newline if missing and the #include line
        sed -i --follow-symlinks '$a\' "$config"
        echo "$include" >>"$config"
    fi
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
        chown $user:$user "$file"
    fi
}

# arg 1: key, arg 2: value
function setAutoConf() {
    local key="$1"
    local value="$2"
    local file="$configdir/all/autoconf.cfg"

    iniConfig " = " '"' "$file"
    iniSet "$key" "$value"
    chown $user:$user "$file"
}

# arg 1: key
function getAutoConf(){
    local key="$1"

    iniConfig " = " '"' "$configdir/all/autoconf.cfg"
    iniGet "$key"

    [[ "$ini_value" == "1" ]] && return 0
    return 1
}

# escape special characters for sed
function sedQuote() {
    local string="$1"
    string="${string//\\/\\\\}"
    string="${string//|/\\|}"
    string="${string//[/\\[}"
    string="${string//]/\\]}"
    echo "$string"
}
