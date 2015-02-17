rp_module_id="modules"
rp_module_desc="Modules UInput, Joydev, ALSA"
rp_module_menus="2+"
rp_module_flags="nobin !odroid"

function install_modules() {
    sed -i '/snd_bcm2835/d' /etc/modules

    for module in uinput joydev snd-bcm2835; do
        modprobe $module
        if ! grep -q "$module" /etc/modules; then
            addLineToFile "$module" "/etc/modules"
        else
            echo "$module module already contained in /etc/modules"
        fi
    done
}
