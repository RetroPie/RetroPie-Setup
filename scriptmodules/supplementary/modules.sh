rp_module_id="modules"
rp_module_desc="Modules UInput, Joydev, ALSA"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_modules() {
    modprobe uinput
    modprobe joydev
    modprobe snd_bcm2835

    for module in uinput joydev snd_bcm2835; do
        if ! grep -q "$module" /etc/modules; then
            echo -e "Adding module $module to /etc/modules"
            addLineToFile "$module" "/etc/modules"
        else
            echo -e "$module module already contained in /etc/modules"
        fi
    done
}