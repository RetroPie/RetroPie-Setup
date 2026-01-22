#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="box86"
rp_module_desc="Box86 emulator"
rp_module_help="Place your x86 binaries $romdir/box86"
rp_module_licence="MIT https://github.com/ptitSeb/box86/blob/master/LICENSE"
rp_module_section="exp"
rp_module_flags="rpi4 x11"

function _latest_ver_box86() {
    # This defines the Git tag / branch which will be used. Main repository is at:
    # https://github.com/ptitSeb/box86
    echo v0.2.0
    # The following is not working yet. Releases must be non-prerelease and non-draft.
    # wget -qO- https://api.github.com/repos/ptitSeb/box86/releases/latest | grep -m 1 tag_name | cut -d\" -f4
}

function depends_box86() {
    if compareVersions $__gcc_version lt 7; then
        md_ret_errors+=("Sorry, you need an OS with gcc 7 or newer to compile $md_id")
        return 1
    fi

    if compareVersions $__version lt 4.7.7; then
        md_ret_errors+=("Sorry, you need to be running RetroPie v4.7.7 or later")
        return 1
    fi

    if ! rp_isInstalled "mesa" ; then
        md_ret_errors+=("Sorry, you need to install the Mesa scriptmodule")
        return 1
    fi

    # Install required libraries required for compilation and running
    getDepends binfmt-support cmake gtk2-engines-murrine libncurses5 libncursesw5 libssl1.0.2 libglu1-mesa zenity mesa-utils libinput10 libxkbcommon-x11-0 matchbox-window-manager xorg

    # Restarting the binfmt service should eliminate the need to reboot the machine after installation.
    systemctl restart systemd-binfmt
    
    # X11 on RPi is currently using VMWare's LLVM GL Driver for some reason. That should be removed.
    # Recommended as per: https://www.raspberrypi.org/forums/viewtopic.php?t=196423
    apt remove -y xserver-xorg-video-fbturbo
}

function sources_box86() {
    gitPullOrClone "$md_build" https://github.com/ptitSeb/box86.git "$(_latest_ver_box86)"
}

function build_box86() {
    mkdir build
    cd build
    cmake .. -DARM_DYNAREC=1 -DRPI4=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make -j4
    cd ..
}

function install_box86() {
    md_ret_files=(
        'build/box86'
        'build/libdynarec.a'
        'LICENSE'
    )
}

function configure_box86() {
    local system="box86"

    update-binfmts --install i386 "$md_inst/${system}" --magic '\x7fELF\x01\x01\x01\x03\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x01\x00\x00\x00' --mask '\xff\xff\xff\xff\xff\xff\xff\xfc\xff\xff\xff\xff\xff\xff\xff\xff\xf8\xff\xff\xff\xff\xff\xff\xff'
}
