#!/bin/sh

ROOTDIR=""
DATADIR=""
REGEX_VIDEO=""
REGEX_IMAGE=""

# Load user settings
. /opt/retropie/configs/all/splashscreen.cfg

is_fkms() {
    if grep -q okay /proc/device-tree/soc/v3d@7ec00000/status 2> /dev/null || grep -q okay /proc/device-tree/soc/firmwarekms@7e600000/status 2> /dev/null ; then
        return 0
    else
        return 1
    fi
}

do_start () {
    local config="/etc/splashscreen.list"
    local line
    local re="$REGEX_VIDEO\|$REGEX_IMAGE"
    local omxiv="/opt/retropie/supplementary/omxiv/omxiv"
    case "$RANDOMIZE" in
        disabled)
            line="$(head -1 "$config")"
            ;;
        retropie)
            line="$(find "$ROOTDIR/supplementary/splashscreen" -type f | grep "$re" | shuf -n1)"
            ;;
        custom)
            line="$(find "$DATADIR/splashscreens" -type f | grep "$re" | shuf -n1)"
            ;;
        all)
            line="$(find "$ROOTDIR/supplementary/splashscreen" "$DATADIR/splashscreens" -type f | grep "$re" | shuf -n1)"
            ;;
        list)
            line="$(cat "$config" | shuf -n1)"
            ;;
    esac
    if $(echo "$line" | grep -q "$REGEX_VIDEO"); then
        # wait for dbus
        while ! pgrep "dbus" >/dev/null; do
            sleep 1
        done
        omxplayer --no-osd -o both -b --layer 10001 "$line"
    elif $(echo "$line" | grep -q "$REGEX_IMAGE"); then
        if [ "$RANDOMIZE" = "disabled" ]; then
            local count=$(wc -l <"$config")
        else
            local count=1
        fi
        [ $count -eq 0 ] && count=1
        [ $count -gt 12 ] && count=12

        # Default duration is 12 seconds, check if configured otherwise
        [ -z "$DURATION" ] && DURATION=12
        local delay=$((DURATION/count))
        if [ "$RANDOMIZE" = "disabled" ]; then
            "$omxiv" --once -t $delay -b --layer 10001 -f "$config" >/dev/null 2>&1
        else
            "$omxiv" --once -t $delay -b --layer 10001 -r "$line" >/dev/null 2>&1
        fi
    fi
    exit 0
}

case "$1" in
    start|"")
        do_start &
        ;;
    restart|reload|force-reload)
        echo "Error: argument '$1' not supported" >&2
        exit 3
       ;;
    stop)
        # No-op
        ;;
    status)
        exit 0
        ;;
    *)
        echo "Usage: asplashscreen [start|stop]" >&2
        exit 3
        ;;
esac
