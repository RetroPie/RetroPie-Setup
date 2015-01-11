## Overview

Parts of this recipe are based on [this tutorial](http://www.kaibader.de/homemade-minimal-raspberry-pi-raspbian-image/).

## Prerequisites

Install all needed packages on a Linux system, e.g.m with a Debian-based system:

``` bash
sudo apt-get install qemu-user-static binfmt-support fakeroot debootstrap git
```

Add support for armhf with this command:
``` bash
sudo echo "EXTRA_OPTS=\"-L/usr/lib/arm-linux-gnueabihf\"" > /etc/qemu-binfmt.conf
```

## Create a minimal Raspbian

Create essential directories:

``` bash
cd
mkdir raspi raspi/bootfs
cd raspi
```

Download a minimalistic list of Raspbian packages that will later go onto the root partition.

``` bash
fakeroot debootstrap --foreign --include=ca-certificates --arch=armhf testing rootfs http://archive.raspbian.com/raspbian
```

Download RetroPie-Setup Script, which also contains helper scripts for creating and maintaining the SD-card image:

``` bash
git clone git://github.com/petrockblog/RetroPie-Setup
```

Temporarily add some arm binaries to the root directory:

``` bash
cp $(which qemu-arm-static) rootfs/usr/bin
```

Now, start the actual installation process of the Raspian packages:

``` bash
sudo chown root.root rootfs -R
sudo chroot rootfs/ /debootstrap/debootstrap --second-stage --verbose
```

The following commands download and install some of the Raspberry Pi firmware files:

``` bash
git clone --depth=1 https://github.com/raspberrypi/firmware.git
sudo cp -r firmware/hardfp/opt/* rootfs/opt/
```

Use the stock kernel:

``` bash
mkdir -p rootfs/lib/modules/
sudo cp -r firmware/modules/* rootfs/lib/modules/
```

Create the boot partition (i.e. copy the necessary files):

``` bash
mkdir bootfs
cp -r firmware/boot/* bootfs/
```

Next we make some adaptions to the image files: set a new root password, hostname, adapt the sources list, etc.

__TO-BE-DONE: This has to be extended!__

``` bash
sudo chroot rootfs/ /usr/bin/passwd
echo "retropie" > rootfs/etc/hostname
echo "deb http://mirrordirector.raspbian.org/raspbian/ testing main contrib non-free rpi" >> rootfs/etc/apt/sources.list
sudo chroot rootfs/ apt-get update
sudo chroot rootfs/ apt-get install console-data console-common console-setup tzdata most locales keyboard-configuration
```

## Install RetroPie

Install required packages:

``` bash
sudo chroot rootfs/ apt-get install git dialog
```

__TO-BE-DONE: This has to be extended!__


## Clean Up

Now we can do some clean-up:

``` bash
sudo rm rootfs/usr/bin/qemu-arm-static
```

## Create Image

``` bash
cd ~/raspi
sudo /RetroPie-Setup/tools/sdcard/makeimage.sh retropie_vX.img rootfs small
```

## Syncronize Image with SD-Card

__TO-BE-DONE__

