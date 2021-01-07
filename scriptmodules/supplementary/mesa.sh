#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mesa"
rp_module_desc="Mesa3d OpenGL and Vulkan Drivers"
rp_module_licence="MIT https://www.mesa3d.org/license.html"
rp_module_section="depends"
rp_module_flags="rpi4 x11"

# Based on instructions from: https://www.reddit.com/r/RetroPie/comments/egjqw2/how_to_manually_compile_newest_mesa_drivers_for/
# Research for Vulkan:
# https://blogs.igalia.com/apinheiro/2020/06/v3dv-quick-guide-to-build-and-run-some-demos/
# https://www.youtube.com/watch?v=TLzFPIoHhS8
# https://www.raspberrypi.org/blog/vulkan-update-merged-to-mesa/
# https://www.raspberrypi.org/forums/viewtopic.php?t=277125
# https://www.raspberrypi.org/forums/viewtopic.php?t=289168

function _latest_ver_mesa() {
    # This defines the Git tag / branch which will be used. Main repository is at:
    # https://gitlab.freedesktop.org/mesa/mesa/
    echo mesa-20.3.2
}

function depends_mesa() {
    #local depends=(meson ninja-build libgbm-dev libdrm-dev libpciaccess-dev)
    local depends=(vulkan-tools libxcb-shm0-dev)

    getDepends "${depends[@]}"
    
    # 1: Exit emulationstation (F4 or the command below should do it)
    # kill $(ps -ef|grep '/opt/retropie/supplementary/emulationstation/emulationstation'|grep -v grep|tail -1|awk '{print $2}')

    # 2: Run the following command to setup source code repositories on your pi:
    sed -i -e 's/#deb-src http:\/\/archive.raspberrypi.org\/debian\/.*/deb-src http:\/\/archive.raspberrypi.org\/debian\/ buster main/' /etc/apt/sources.list.d/raspi.list

    # 3: Run the following command to get the needed dependencies for building MESA from source:
    apt update
    apt build-dep mesa -y

    # 4: Run the following command to remove source code repositories on your pi:
    sed -i -e 's/deb-src http:\/\/archive.raspberrypi.org\/debian\/.*/#deb-src http:\/\/archive.raspberrypi.org\/debian\/ buster main/' /etc/apt/sources.list.d/raspi.list
    apt update
}

function sources_mesa() {
    # 5: Run the following command to clone the MESA git repo to your pi:
    gitPullOrClone "$md_build" https://gitlab.freedesktop.org/mesa/mesa/ "$(_latest_ver_mesa)"
}

function build_mesa() {
    #TODO: Research if there are any RPi specific optimization flags. Check mesa-drm.sh scriptmodule.
    #TODO: Also check https://github.com/anholt/mesa/wiki/Raspberry-Pi-cross-compile for optimization possibilities
    # 6: Create the build directory and change to that directory:
    #mkdir $md_build/builddir
    #cd /home/pi/mesa/build

    # 7: Now compile the new version of MESA:
    meson builddir --prefix="$md_inst" --libdir lib -Dplatforms=x11     -Dvulkan-drivers=broadcom -Ddri-drivers= -Dgallium-drivers=v3d,kmsro,vc4,virgl --buildtype debug
    ninja -C builddir
}

function install_mesa() {
    # 8: Install new MESA version (You'll see various warnings, these are safe and can be ignored)
    echo "Installing into $md_inst"
    cd builddir
    ninja install
    cd ..

    # The following line is to configure the location of Vulkan
    echo export VK_ICD_FILENAMES="$md_inst"/share/vulkan/icd.d/broadcom_icd.armv7l.json >> /home/pi/.profile
}
