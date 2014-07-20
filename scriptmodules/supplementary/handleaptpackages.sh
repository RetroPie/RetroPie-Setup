rp_module_id="handleaptpackages"
rp_module_desc="Handle APT packages"
rp_module_menus="2+"

function install_handleaptpackages() {
    # remove PulseAudio since this is slowing down the whole system significantly. Cups is also not needed
    apt-get remove -y pulseaudio cups wolfram-engine
    apt-get -y autoremove
}