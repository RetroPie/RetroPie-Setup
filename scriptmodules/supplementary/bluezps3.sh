rp_module_id="bluezps3"
rp_module_desc="Pair PS3 bluetooth controller (BLUEZ)"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_bluezps3() {
    getDepends inotify-tools
}

function register_bluezps3() {
        printMsgs "dialog" "Please connect your PS3 controller via USB-CABLE"
        # Wait max 60s until directories appear
        printMsgs "console" "Disconnect USB cable and press PS button. Timeout is 60 seconds."
        ps3_file=$(inotifywait -e create -r -t 60 /var/lib/bluetooth --format %w%f)

        if [[ -n $ps3_file ]]; then
            # Check if new device is a PS3 controller
            if [[ $(grep "Name=PLAYSTATION(R)3 Controller" "$ps3_file/info") ]]; then
                bluetoothctl << EOF
trust ${ps3_file##*/}
EOF
            fi
        else
            printMsgs "console" "No controller found after 60 seconds. Try unlpugging before pressing the PS button."
        fi
}

function configure_bluezps3() {
    # Check existing PS3 controllers
    # This might happen by pressing the PS button before starting inotifywait
    for file in $(find /var/lib/bluetooth/*/*/ -name info); do
        local bt_info=$(grep -e Name -e Trusted $file)
        # Ignore everything that isn't a PS3 controller
        if [[ $(echo $bt_info | grep "Name=PLAYSTATION(R)3 Controller") ]]; then
            if [[ $(echo $bt_info | grep "Trusted=false") ]]; then
                local ps3_mac=$(echo $file | cut -d"/" -f6)
                local not_trusted_macs="$ps3_mac\n$not_trusted_macs"
            fi
        fi
    done
    if [[ -n $not_trusted_macs ]]; then
        printMsgs "dialog" "The following Playstation(R) 3 controllers are not trusted. Please trust them manually using bluetoothctl.
$not_trusted_macs"
    fi

    register_bluezps3
    printMsgs "dialog" "Successfully registered PS3 controller"
}
