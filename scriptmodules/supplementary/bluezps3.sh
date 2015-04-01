rp_module_id="bluezps3"
rp_module_desc="Pair PS3 bluetooth controller (BLUEZ)"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_bluezps3() {
    getDepends inotify-tools
}

function configure_bluezps3() {  
    printMsgs "dialog" "Please connect your PS3 controller via USB-CABLE, press PS button and ENTER."
    # Wait max 60s until directories appear
    inotifywait -e create -r -t 60 /var/lib/bluetooth
    # Trust every ps3 controller
    for file in $(grep -l "Name=PLAYSTATION(R)3 Controller" /var/lib/bluetooth/*/*/info); do
        sed -i "s/Trusted=false/Trusted=true/g" $file
    done

    printMsgs "dialog" "Please restart."
}
