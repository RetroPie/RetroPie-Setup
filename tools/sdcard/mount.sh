#!/bin/bash
DEVICE="$1"
DEST="$2"
if [[ -z "$DEVICE" ]] || [[ -z "$DEST" ]]; then
    echo "$0 DEVICE/umount MOUNTPOINT"
    exit 1
fi
if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root."
    exit 1
fi
if [[ "$DEVICE" == "umount" ]]; then
    umount "$DEST/boot"
    umount "$DEST"
else
    DEVICE=$(readlink -f "$DEVICE")
    mount ${DEVICE}2 "$DEST"
    mount ${DEVICE}1 "$DEST/boot"
fi
