#!/bin/bash
D="$1"
if [[ ! -d "$D" ]]; then
    echo "Directory doesn't exist"
    exit 1
fi
if [[ ! -f "$D/boot/kernel.img" ]]; then
    echo "Directory doesn't seem to be a pi chroot"
    exit 1
fi

H="$D/home/pi"

# etc / ssh leys
rm -f $D/etc/mtab
rm -f $D/etc/ssh/ssh_host_*

# caches / tmp files
rm -f $D/var/swap
rm -rf $D/run/*
rm -f $D/var/backups/*
rm -f $D/var/cache/apt/*.bin
rm -f $D/var/cache/apt/archives/*.deb
rm -f $D/var/cache/apt/archives/partial/*.deb
rm -f $D/var/lib/dhcp*/*
rm -rf $D/tmp/* $D/tmp/.[a-z]*

# root / homedir
rm -f $D/root/*
rm -rf $D/root/.ssh
rm -rf $D/root/.pulse*
rm -rf $H/.ssh
echo -n "" > $H/.bash_history
echo -n "" > $D/root/.bash_history
chown 1000.1000 $H/.bash_history $H/.bashrc
rm -f $H/.nano_history
rm -rf $H/.cache/*

# clean logs
rm -rf $D/var/log/samba/*
rm -f $d/var/log/regen_ssh_keys.log
rm -f $D/var/log/apt-queue
rm -f $D/var/log/aptitude
rm -f $D/var/log/*.[0-9]*
rm -f $D/var/log/Xorg*
rm -rf $D/var/log/hp
rm -f $D/var/log/*/*
for file in $D/var/log/*.log; do
    echo -n "" >$file
done
for file in boot faillog dmesg btmp syslog messages udev debug lastlog wtmp; do
    echo -n "" >$D/var/log/$file
done

