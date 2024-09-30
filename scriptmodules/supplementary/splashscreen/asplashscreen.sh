#!/bin/sh

ROOTDIR=""
DATADIR=""
REGEX_VIDEO=""
REGEX_IMAGE=""
CMD="vlc --intf dummy --quiet --no-video-title-show --play-and-exit"
CMD_OPTS=""

# Load user settings
. /opt/retropie/configs/all/splashscreen.cfg

do_start () {
    local config="/etc/splashscreen.list"
    local line
    local re="$REGEX_VIDEO\|$REGEX_IMAGE"
    local cmd="$CMD $CMD_OPTS"
    case "$RANDOMIZE" in
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

    cmd="$cmd --image-duration $delay"
    local pid
    if [ "$RANDOMIZE" = "disabled" ]; then
        tr "\n" "\0" <"$config" | xargs -0 $cmd & 2>/dev/null
        # get cmd pid (child of xargs)
        pid=`pgrep -P $!`
    else
        $cmd "$line" & 2>/dev/null
        pid=$!
    fi
    echo "$pid" >/dev/shm/rp-splashscreen.pid

    exit 0
}

case "$1" in
    start|"")
        do_start
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
