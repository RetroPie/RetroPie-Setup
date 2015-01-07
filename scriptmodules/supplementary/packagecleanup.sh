rp_module_id="packagecleanup"
rp_module_desc="Remove raspbian packages that are not needed for RetroPie"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_packagecleanup() {
    # remove PulseAudio since this is slowing down the whole system significantly. Cups is also not needed
    apt-get remove -y pulseaudio cups wolfram-engine sonic-pi
    apt-get -y autoremove
}