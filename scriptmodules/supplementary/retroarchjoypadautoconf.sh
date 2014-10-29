rp_module_id="retroarchjoypadautoconf"
rp_module_desc="RetroArch-Joypad-AutoConfig"
rp_module_menus="4+"

function install_retroarchjoypadautoconf() {
    if [[ ! -d "$rootdir/emulators/RetroArch/configs/" ]]; then
        mkdir -p "$rootdir/emulators/RetroArch/configs/"
    fi
    gitPullOrClone "$rootdir/supplementary/retroarch-joypad-autoconfig" "https://github.com/libretro/retroarch-joypad-autoconfig" || return 1
    pushd "$rootdir/supplementary/retroarch-joypad-autoconfig" || return 1
    cd udev
    cp *.cfg "$rootdir/emulators/RetroArch/configs/"
    cd ..
    popd
}
