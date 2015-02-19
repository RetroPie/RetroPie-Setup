rp_module_id="retroarchautoconf"
rp_module_desc="RetroArch-AutoConfigs"
rp_module_menus="2+"
rp_module_flags="nobin"

function sources_retroarchautoconf() {
    gitPullOrClone "$md_build" https://github.com/libretro/retroarch-joypad-autoconfig
}

function install_retroarchautoconf() {
    mkdir -p "$emudir/retroarch/configs/"
    cp "$scriptdir/supplementary/RetroArchConfigs/"*.cfg "$emudir/retroarch/configs/"
    cp -r $md_build/udev/* $emudir/retroarch/configs/
    sudo chown -R $user:$user $emudir/retroarch/configs/
}

function configure_retroarchautoconf() { 
    $scriptdir/supplementary/setAutoconfHotkeys.py
}
