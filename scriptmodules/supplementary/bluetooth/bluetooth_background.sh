#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

registered_macs=("$@")

function contains() {
    local argc=$#
    local value=${!argc}
    for (( argi=1; argi < $argc; argi++ )); do
        if [ "${!argi}" == "$value" ]; then
            return 0
        fi
    done
    return 1
}

while true; do
    connected_macs=( $( hcitool con | grep -o -e '..:..:..:..:..:..' ) )
    disconnected_macs=()
    for mac in "${registered_macs[@]}"; do
        if contains ${connected_macs[@]} "$mac"; then 
            echo "$mac - connected"
        else
            disconnected_macs+=( "$mac" )
	fi
    done
    for mac in "${disconnected_macs[@]}"; do
        echo "$mac - disconnected"
        echo "connect $mac\nquit" | bluetoothctl >/dev/null 2>&1
    done
    sleep_seconds=5
    echo "Sleeping $sleep_seconds seconds..."
    sleep $sleep_seconds
done

