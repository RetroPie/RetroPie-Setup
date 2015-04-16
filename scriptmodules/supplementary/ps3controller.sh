#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="ps3controller"
rp_module_desc="Install PS3 controller driver"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_ps3controller() {
    getDepends bluez-utils bluez-compat bluez-hcidump checkinstall libusb-dev libbluetooth-dev joystick
}

function sources_ps3controller() {
    wget -nv http://www.pabr.org/sixlinux/sixpair.c -O "$md_build/sixpair.c"
    wget -O- -q http://sourceforge.net/projects/qtsixa/files/QtSixA%201.5.1/QtSixA-1.5.1-src.tar.gz | tar -xvz --strip-components=1
    patch -p1 <<\_EOF_
--- a/sixad/shared.h	2011-10-12 03:37:38.000000000 +0300
+++ b/sixad/shared.h	2012-08-14 19:30:12.190379004 +0300
@@ -18,6 +18,8 @@
 #ifndef SHARED_H
 #define SHARED_H
 
+#include <unistd.h>
+
 struct dev_led {
     bool enabled;
     bool anim;
_EOF_

    sed -i 's/strcpy(dev_name, "PLAYSTATION(R)3 Controller (");/strcpy(dev_name, "PLAYSTATION(R)3 Controller");/g' "$md_build/sixad/uinput.cpp"
    sed -i 's/strcat(dev_name, mac);//g' "$md_build/sixad/uinput.cpp"
    sed -i 's/strcat(dev_name, ")");//g' "$md_build/sixad/uinput.cpp"
 }

function build_ps3controller() {
    gcc -o sixpair sixpair.c -lusb
    cd sixad
    make clean
    make
}

function install_ps3controller() {
    cd sixad
    checkinstall -y --fstrans=no
    update-rc.d sixad defaults

    # If a bluetooth dongle is connected set state up and enable pscan
    cat > "$md_inst/bluetooth.sh" << _EOF_
#!/bin/bash
/usr/bin/hciconfig hci0 up
if hciconfig | grep -q "BR/EDR"; then
    hciconfig hci0 pscan
fi
_EOF_

    chmod +x "$md_inst/bluetooth.sh"

    # If a PS3 controller is connected over usb check if bluetooth dongle exits and start sixpair
    cat > "$md_inst/ps3pair.sh" << _EOF_  
#!/bin/bash
if hciconfig | grep -q "BR/EDR"; then
    hciconfig hci0 pscan
    $md_inst/sixpair
fi
_EOF_

    chmod +x "$md_inst/ps3pair.sh"

    # udev rule for bluetooth dongle
    cat > "/etc/udev/rules.d/10-local.rules" << _EOF_  
# Set bluetooth power up
ACTION=="add", KERNEL=="hci0", RUN+="$md_inst/bluetooth.sh"
_EOF_

    # udev rule for ps3 controller usb connection
    cat > "/etc/udev/rules.d/99-sixpair.rules" << _EOF_
# Pair if PS3 controller is connected
DRIVER=="usb", SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="0268", RUN+="$md_inst/ps3pair.sh"
_EOF_
    
    # add default sixad settings
    cat > "/var/lib/sixad/profiles/default" << _EOF_
enable_leds 1
enable_joystick 1
enable_input 0
enable_remote 0
enable_rumble 1
enable_timeout 0
led_n_auto 0
led_n_number 0
led_anim 1
enable_buttons 1
enable_sbuttons 0
enable_axis 1
enable_accel 0
enable_accon 0
enable_speed 0
enable_pos 0
_EOF_
    
    # Start sixad daemon
    /etc/init.d/sixad start

    md_ret_files=(
        'sixpair'
    )
}

function configure_ps3controller() {
    printMsgs "dialog" "Please make sure that your Bluetooth dongle is connected to the Raspberry Pi and press ENTER."
    if ! hciconfig | grep -q "BR/EDR"; then
        printMsgs "dialog" "Cannot find the Bluetooth dongle. Please try to (re-)connect it and try again."
        break
    else
        hciconfig hci0 pscan
    fi

    printMsgs "dialog" "Please connect your PS3 controller via USB-CABLE and press ENTER."
    if $md_inst/sixpair | grep -q "Setting master"; then
        printMsgs "dialog" "Cannot find the PS3 controller via USB-connection. Please try to (re-)connect it and try again."
        break
    fi

    printMsgs "dialog" "The driver and configuration tools for connecting PS3 controllers have been installed. Please visit https://github.com/petrockblog/RetroPie-Setup/wiki/Setting-up-a-PS3-controller for further information."
}
