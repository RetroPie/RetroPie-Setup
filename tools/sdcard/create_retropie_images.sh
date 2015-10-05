#!/bin/bash
# SRC = unpacked raspbian filesystem including /boot folder (in our case a stripped down one)
# DEST = destination folder for images
SRC="$1"
DEST="$2"
VER="$3"
if [[ -z "$SRC" || -z "$DEST" || -z "$VER" ]]; then
    echo "$0 SRC DEST VERSION"
    exit 1
fi
for __platform in rpi1 rpi2; do

    cat >"$SRC/home/pi/install.sh" <<_EOF_
#!/bin/bash
cd ~/RetroPie-Setup
sudo __platform=$__platform __nodialog=1 ./retropie_packages.sh setup binaries
sudo __platform=$__platform __nodialog=1 ./retropie_packages.sh usbromservice enable
sudo __platform=$__platform __nodialog=1 ./retropie_packages.sh splashscreen install
sudo __platform=$__platform __nodialog=1 ./retropie_packages.sh splashscreen enable
_EOF_

    chmod a+x "$SRC/home/pi/install.sh"

    rm -rf "$SRC/home/pi/RetroPie-Setup"
    rm -rf "$SRC/home/pi/RetroPie"
    rm -rf "$SRC/opt/retropie"
    rm -rf "$SRC/etc/emulationstation"
    rm -rf "$SRC/home/pi/.emulationstation"
    rm -rf "$SRC/home/pi/"{.dosbox,.gngeo,.advance,.pulse-cookie}

    # we clone these repositories from outside of the chroot due to qemu chroot deadlocks with git
    pushd "$SRC/home/pi"
    git clone --depth 1 https://github.com/RetroPie/RetroPie-Setup.git
    chown -R 1000:1000 "$SRC/home/pi/RetroPie-Setup"
    popd

    # checkout splashscreens
    mkdir -p "$SRC/opt/retropie/supplementary"
    pushd "$SRC/opt/retropie/supplementary"
    git clone --depth 1 https://github.com/RetroPie/retropie-splashscreens.git splashscreen
    popd

    ./chroot.sh "$SRC" /home/pi/install.sh

    rm "$SRC/home/pi/install.sh"

    # generate image
    img="retropie-v$VER-$__platform"
    ./makeimage.sh "$DEST/${img}.img" "$SRC"
    gzip -f "$DEST/${img}.img"

    # move the original fstab out of the way, and create one with just proc in it for berryboot
    mv "$SRC/etc/fstab" "$SRC/etc/fstab.orig"
    echo "proc            /proc           proc    defaults          0       0" >"$SRC/etc/fstab"
    # generate berryboot squashfs from filesystem
    mksquashfs "$SRC" "$DEST/${img}-berryboot.img256" -comp lzo -e boot -e lib/modules -e etc/fstab
    mv "$SRC/etc/fstab.orig" "$SRC/etc/fstab"
done
