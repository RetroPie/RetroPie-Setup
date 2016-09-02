#!/bin/bash
FROMTO="$1"
DEVICE="$2"
DEST="$3"
MOUNT="/mnt"
if [[ -z "$DEVICE" ]] || [[ -z "$DEST" ]]; then
    echo "$0 from/to DEVICE SOURCE/DEST"
    exit 1
fi
if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root."
    exit 1
fi
if [- "$FROMTO" == "from" ]=; then
    read -p "Sync from $DEVICE to $DEST (y/n)?" REPLY
    [- "$REPLY" == "y" =] || exit
    ./mount.sh $DEVICE $MOUNT
    rsync -av --numeric-ids --exclude "/proc/*" --exclude "/dev/*" --exclude "/sys/*" --delete "$MOUNT/" "$DEST/"
fi
if [[ "$FROMTO" == "to" ]]; then
    read -p "Sync from $DEST to $DEVICE (y/n)?" REPLY
    [[ "$REPLY" == "y" ]] || exit
    ./mount.sh $DEVICE $MOUNT
    rsync -av --numeric-ids --exclude "/proc/*" --exclude "/dev/*" --exclude "/sys/*" --delete "$DEST/" "$MOUNT/"
fi
umount /mnt/boot /mnt
