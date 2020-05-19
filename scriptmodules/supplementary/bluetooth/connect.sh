#!/usr/bin/env bash
configdir="CONFIGDIR"

source "ROOTDIR/lib/inifuncs.sh"

mode="$1"
if [[ -z "$mode" ]]; then
    iniConfig "=" '"' "$configdir/all/bluetooth.cfg"
    iniGet "connect_mode"
    [[ -n "$ini_value" ]] && mode="$ini_value"
fi

function connect() {
    local line
    local mac
    local conn
    while read line; do
        if [[ "$line" =~ ^(.+)\ \((.+)\)$ ]]; then
            mac="${BASH_REMATCH[2]}"
            conn=$(bt-device -i "$mac" | grep "Connected:" | tail -c 2 2>/dev/null)
            [[ "$conn" -eq 0 ]] && bt-device --connect "$mac" &>/dev/null
        fi
    done < <(bt-device --list)
}

case "$mode" in
    boot)
        connect
        ;;
    background)
        while true; do
            connect
            sleep 10
        done
esac

exit 0
