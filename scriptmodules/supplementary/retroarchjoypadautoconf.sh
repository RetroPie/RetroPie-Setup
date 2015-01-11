rp_module_id="retroarchjoypadautoconf"
rp_module_desc="RetroArch-Joypad-AutoConfig"
rp_module_menus="4+"
rp_module_flags="nobin"

function sources_retroarchjoypadautoconf() {
    gitPullOrClone "$md_build" https://github.com/libretro/retroarch-joypad-autoconfig

}

function install_retroarchjoypadautoconf() {
    mkdir -p "$emudir/retroarch/configs/"
    cp udev/*.cfg "$emudir/retroarch/configs/"
    sudo chown -R $user:$user "$emudir/retroarch/configs"
}
