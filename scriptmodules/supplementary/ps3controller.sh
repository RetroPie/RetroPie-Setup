#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ps3controller"
rp_module_desc="Install/Pair PS3 controller"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function depends_ps3controller() {
    getDepends bluez-utils bluez-compat bluez-hcidump checkinstall libusb-dev libbluetooth-dev joystick libusb-1.0-0-dev
}

function sources_ps3controller() {
    gitPullOrClone "$md_build" https://github.com/kLeZ/SixPair.git
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
    g++ -o sixpair main.cpp -lusb-1.0
    cd sixad
    make clean
    make
}

function install_ps3controller() {
    cd sixad
    checkinstall -y --fstrans=no
    insserv sixad

    # If a bluetooth dongle is connected set state up and enable pscan
    cat > "$md_inst/bluetooth.sh" << _EOF_
#!/bin/bash
if hcitool dev | grep -q "hci0"; then
    hciconfig hci0 up
    hciconfig hci0 pscan
fi
_EOF_

    chmod +x "$md_inst/bluetooth.sh"

    # If a PS3 controller is connected over usb check if bluetooth dongle exits and start sixpair
    cat > "$md_inst/ps3pair.sh" << _EOF_  
#!/bin/bash
if hcitool dev | grep -q "hci0"; then
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
led_n_auto 1
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

function remove_ps3controller() {
    service sixad stop
    insserv -r sixad
    dpkg --purge sixad
    rm -rf /var/lib/sixad/
    rm -f /etc/udev/rules.d/99-sixpair.rules
    rm -f /etc/udev/rules.d/10-local.rules
    rm -rf "$md_inst"
}

function pair_ps3controller() {
    if [[ ! -f "$rootdir/supplementary/ps3controller/sixpair" ]]; then
        local mode
        for mode in depends sources build install; do
            rp_callModule ps3controller $mode
        done
    fi

    printMsgs "dialog" "Please make sure that your Bluetooth dongle is connected to the Raspberry Pi and press ENTER."
    while true; do
        if hcitool dev | grep -q "hci0"; then
            hciconfig hci0 pscan
            break
        else
            dialog --backtitle "$__backtitle" --yesno "Can't find your Bluetooth dongle. Try again?" 22 76 2>&1 >/dev/tty
            case $? in
                0)
                    continue
                    ;;
                *)
                    return
                    ;;  
            esac
        fi
    done

    printMsgs "dialog" "Please connect your PS3 controller via USB-CABLE and press ENTER."
    while true; do
        if "$md_inst/sixpair" | grep -q "Setting master"; then
            break
        else
            dialog --backtitle "$__backtitle" --yesno "Can't find your PS3 Controller. Please check it is connected via USB. \n\nTry again?" 22 76 2>&1 >/dev/tty
            case $? in
                0)
                    continue
                    ;;
                *)
                    return
                    ;;  
            esac
        fi
    done

    printMsgs "dialog" "The driver and configuration tools for connecting PS3 controllers have been installed. \n\nPlease disconnect your PS3 controller from its USB connection, and press the PS button to connect via Bluetooth."
}

function configure_ps3controller() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Install/Pair PS3 controller"
            2 "Remove PS3 controller configurations"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    rp_callModule "$md_id" pair
                    ;;
                2)
                    rp_callModule "$md_id" remove
                    printMsgs "dialog" "Removed PS3 controller configurations"
                    ;;
            esac
        else
            break
        fi
    done

}
