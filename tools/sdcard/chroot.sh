#!/bin/bash
DEST="$1"
CMD="$2"

if [[ ! -f "$DEST/boot/kernel.img" ]]; then
    echo "$DEST doesn't seem to be a pi chroot"
    exit 1
fi

mkdir -p $DEST/run/resolvconf
echo -e "nameserver 8.8.8.8" >$DEST/etc/resolv.conf
rm $DEST/etc/ld.so.preload

mount -o bind /proc $DEST/proc
mount -o bind /dev $DEST/dev

export QEMU_CPU=arm1176

cp /usr/bin/qemu-arm-static $DEST/usr/bin
if [[ -z "$CMD" ]]; then
    HOME="/home/pi" chroot --userspec 1000:1000 $DEST
else
    HOME="/home/pi" chroot --userspec 1000:1000 $DEST $CMD
fi
rm $DEST/usr/bin/qemu-arm-static

cat /dev/null >$DEST/etc/resolv.conf
echo "/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so" >$DEST/etc/ld.so.preload
rm -rf $DEST/run/resolvconf

umount -l $DEST/proc
umount -l $DEST/dev
sleep 1

if [[ "$DEST" == "/mnt" ]]; then
    umount /mnt/boot /mnt
fi
