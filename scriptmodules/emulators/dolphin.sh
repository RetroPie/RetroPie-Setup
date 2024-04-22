#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dolphin"
rp_module_desc="Gamecube/Wii emulator Dolphin"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .rvz .wad .wbfs\n\nCopy your Gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dolphin-emu/dolphin/master/COPYING"
rp_module_repo="git https://github.com/dolphin-emu/dolphin.git master :_get_commit_dolphin"
rp_module_section="exp"
rp_module_flags="!all 64bit !:\$__gcc_version:-lt:8"

function _get_commit_dolphin() {
    local commit
    local has_qt6=$(apt-cache -qq madison qt6-base-private-dev | cut -d'|' -f1)
    # current HEAD of dolphin doesn't build without a C++20 capable compiler ..
    [[ "$__gcc_version" -lt 10 ]] && commit="f59f1a2a"
    # .. and without QT6
    [[ -z "$has_qt6" ]] && commit="b9a7f577"
    # support gcc 8.4.0 for Ubuntu 18.04
    [[ "$__gcc_version" -lt 9  ]] && commit="1c0ca09e"
    echo "$commit"
}

function depends_dolphin() {
    local depends=(cmake gettext pkg-config libao-dev libasound2-dev libavcodec-dev libavformat-dev libbluetooth-dev libenet-dev liblzo2-dev libminiupnpc-dev libopenal-dev libpulse-dev libreadline-dev libsfml-dev libsoil-dev libsoundtouch-dev libswscale-dev libusb-1.0-0-dev libxext-dev libxi-dev libxrandr-dev portaudio19-dev zlib1g-dev libudev-dev libevdev-dev libmbedtls-dev libcurl4-openssl-dev libegl1-mesa-dev liblzma-dev)
    # check if qt6 is available, otherwise use qt5
    local has_qt6=$(apt-cache -qq madison qt6-base-private-dev | cut -d'|' -f1)
    if [[ -n "$has_qt6" ]]; then
        depends+=(qt6-base-private-dev)
        # Older Ubuntu versions provide libqt6svg6-dev instead of Debian's qt6-svg-dev
        if [[ -n "$__os_ubuntu_ver" ]] && compareVersions "$__os_ubuntu_ver" lt 23.04; then
            depends+=(libqt6svg6-dev)
        else
            depends+=(qt6-svg-dev)
        fi
    else
        depends+=(qtbase5-private-dev)
    fi
    # on KMS use x11 to start the emulator
    isPlatform "kms" && depends+=(xorg matchbox-window-manager)

    # if using the latest version, add SDL2 as dependency, since it's mandatory
    [[ "$(_get_commit_dolphin)" == "" ]] && depends+=(libsdl2-dev)

    getDepends "${depends[@]}"
}

function sources_dolphin() {
    gitPullOrClone
}

function build_dolphin() {
    mkdir build
    cd build
    # use the bundled 'speexdsp' libs, distro versions before 1.2.1 trigger a 'cmake' error
    cmake .. -DBUNDLE_SPEEX=ON -DENABLE_AUTOUPDATE=OFF -DENABLE_ANALYTICS=OFF  -DUSE_DISCORD_PRESENCE=OFF -DCMAKE_INSTALL_PREFIX="$md_inst"
    make clean
    make
    md_ret_require="$md_build/build/Binaries/dolphin-emu"
}

function install_dolphin() {
    cd build
    make install
}

function configure_dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    local launch_prefix
    isPlatform "kms" && launch_prefix="XINIT-WM:"

    addEmulator 0 "$md_id" "gc" "$launch_prefix$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 1 "$md_id-gui" "gc" "$launch_prefix$md_inst/bin/dolphin-emu -b -e %ROM%"
    addEmulator 0 "$md_id" "wii" "$launch_prefix$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 1 "$md_id-gui" "wii" "$launch_prefix$md_inst/bin/dolphin-emu -b -e %ROM%"

    addSystem "gc"
    addSystem "wii"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.config/dolphin-emu" "$md_conf_root/gc/Config"
    mkUserDir "$md_conf_root/gc/Config"
    # preset a few options on a first installation
    if [[ ! -f "$md_conf_root/gc/Config/Dolphin.ini" ]]; then
        cat >"$md_conf_root/gc/Config/Dolphin.ini" <<_EOF_
[Display]
FullscreenDisplayRes = Auto
Fullscreen = True
RenderToMain = True
KeepWindowOnTop = True
[Interface]
ConfirmStop = False
[General]
ISOPath0 = "$home/RetroPie/roms/gc"
ISOPath1 = "$home/RetroPie/roms/wii"
ISOPaths = 2
[Core]
AutoDiscChange = True
_EOF_
    fi
    # use the GLES(3) render path on platforms where it's available
    if [[ ! -f "$md_conf_root/gc/Config/GFX.ini" ]] && isPlatform "gles3"; then
        cat >"$md_conf_root/gc/Config/GFX.ini" <<_EOF2_
[Settings]
PreferGLES = True
_EOF2_
    fi

    chown -R $user:$user "$md_conf_root/gc/Config"
}
