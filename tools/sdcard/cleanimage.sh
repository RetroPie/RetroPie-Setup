#!/bin/bash
DEST="$1"
if [ ! -d "$DEST" ]; then
    echo "Directory doesn't exist"
    exit 1
fi
if [ ! -f "$DEST/boot/kernel.img" ]; then
    echo "$DEST doesn't look like a RPI filesystem"
    exit 1
fi

H="$DEST/home/pi"

# backup files
rm -rf "$DEST/boot.bak"

# etc / ssh leys
rm -f "$DEST/etc/mtab"
rm -f "$DEST/etc/ssh/ssh_host_"*

# caches / tmp files
rm -f "$DEST/var/swap"
rm -rf "$DEST/run/"*
rm -f "$DEST/var/backups/"*
rm -f "$DEST/var/cache/apt/"*.bin
rm -f "$DEST/var/cache/apt/archives/"*.deb
rm -f "$DEST/var/cache/apt/archives/partial/"*.deb
rm -f "$DEST/var/lib/"dhcp*/*
rm -rf "$DEST/tmp/"* "$DEST/tmp/".[a-z]*

# root / homedir
rm -f "$DEST/root/"*
rm -rf "$DEST/root/.ssh"
rm -rf "$DEST/root/.pulse"*
rm -rf "$H/.ssh"
echo -n "" > "$H/.bash_history"
echo -n "" > "$DEST/root/.bash_history"
chown 1000.1000 "$H/.bash_history" "$H/.bashrc"
rm -f "$H/.nano_history"
rm -rf "$H/.cache/"*
rm -rf "$H/RetroPie-Setup/logs/"*

# clean logs
rm -rf "$DEST/var/log/samba/"*
rm -rf "$DEST/var/log/"regen_ssh_keys.log
rm -f "$DEST/var/log/apt-queue"
rm -f "$DEST/var/log/aptitude"
rm -f "$DEST/var/log/"*.[0-9]*
rm -f "$DEST/var/log/Xorg"*
rm -rf "$DEST/var/log/hp"
rm -f "$DEST/var/log/"*/*
for file in "$DEST/var/log/"*.log; do
    echo -n "" >$file
done
for file in boot faillog dmesg btmp syslog messages udev debug lastlog wtmp; do
    echo -n "" >"$DEST/var/log/$file"
done

