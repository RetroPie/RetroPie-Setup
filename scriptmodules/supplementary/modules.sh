rp_module_id="modules"
rp_module_desc="Modules UInput, Joydev, ALSA"
rp_module_menus="2+"

function install_modules() {
    modprobe uinput
    modprobe joydev

    for module in uinput joydev; do
        if ! grep -q "$module" /etc/modules; then
            addLineToFile "$module" "/etc/modules"
        else
            echo -e "$module module already contained in /etc/modules"
        fi
    done
}