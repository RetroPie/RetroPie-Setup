#!/bin/bash
NAME="$1"
ROOTFS="$2"
# 7802500 x 512b blocks (5,120,000 bytes less than 4GB for usb sticks that are undersized)
# SIZE=3994880000
SIZE=3418357760
[[ "$3" == "small" ]] && SIZE=1970000000
# mb sizes
OFF=4
BOOTSZ=60
# -1 to use the rest of the partition space
ROOTSZ=-1

[[ -z "$NAME" ]] || [[ -z "$ROOTFS" ]] && exit

ROOTFS="$(readlink -f $ROOTFS)"

get_part_byte_offset()
{
    PART=$1
    OFF=$(($2+1))
    parted -m "$NAME" unit b print | grep "^$PART" | cut -d: -f $OFF | sed -e "s/\([0-9]\+\)B/\1/g"
}

partitions_create()
{
    BOOTEND=$(($OFF+$BOOTSZ))
    if [[ $ROOTSZ == -1 ]]; then
        ROOTEND=-1
    else
        ROOTEND=$(($OFF+$BOOTSZ+$ROOTSZ))
    fi
    parted -s "$NAME" -- \
        mklabel msdos \
        mkpart primary fat16 $OFF $BOOTEND \
        set 1 boot on \
        mkpart primary $BOOTEND $ROOTEND
}

filesystems_create()
{
    mkfs.vfat -F 16 -n boot /dev/loop0
    mkfs.ext4 -L retropie /dev/loop1
}

# loop#, partition
loop_create()
{
    OFFSET=$(get_part_byte_offset $2 1)
    SIZE=$(get_part_byte_offset $2 3)
    losetup /dev/loop$1 --offset $OFFSET --sizelimit $SIZE "$NAME"
}

loop_delete()
{
    [[ -e /dev/loop$1 ]] && losetup -d /dev/loop$1 2>/dev/null
}

loop_mount()
{
    loop_create 0 1
    loop_create 1 2
}

partitions_unmount()
{
    for MPATH in dev proc boot ""; do
        [[ -d rootfs/$MPATH ]] && umount rootfs/$MPATH
    done
    [[ -d rootfs ]] && rmdir rootfs
}

loop_unmount()
{
    loop_delete 0
    loop_delete 1
}

cleanup()
{
    trap '' INT
    sleep 1
    partitions_unmount
    loop_unmount
    exit
}

trap cleanup INT

partitions_unmount
loop_unmount

echo "Creating image of size $SIZE bytes"
DDCOUNT=$((SIZE/512))
dd if=/dev/zero of="$NAME" bs=512 count=$DDCOUNT

echo "Partioning"
partitions_create ext4
loop_mount
echo "Creating filesystems"
filesystems_create ext4

[[ ! -d rootfs ]] && mkdir -p rootfs

echo "Mounting"
mount -t ext4 /dev/loop1 rootfs
mkdir rootfs/boot
mount -t vfat /dev/loop0 rootfs/boot

echo "RSyncing $ROOTFS to the image"
# if the owner is root use rsync, else assume we are storing ownerships in xattr and so use --fake-super
OWNER=$(stat -c %U $ROOTFS)
if [[ "$OWNER" == "root" ]]; then
    rsync --numeric-ids -a "$ROOTFS/" rootfs/
else
    rsync -a --numeric-ids --rsync-path="rsync --fake-super" buzz@localhost:$ROOTFS/ rootfs/
fi

echo "Unmounting / Cleaning up"
mount -o bind /dev rootfs/dev
mount -o bind /proc rootfs/proc

cleanup
