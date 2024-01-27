#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mesa3d"
rp_module_desc="mesa3d - userspace library for mesa3d for panfrost and lima"
rp_module_licence="MIT https://www.mesa3d.org/license.html"
rp_module_repo="git https://gitlab.freedesktop.org/mesa/mesa.git mesa-23.3.4"
rp_module_section="depends"
rp_module_flags="armbian"

function depends_mesa3d() {
    local depends=(meson ninja-build libgbm-dev libdrm-dev libpciaccess-dev python3-mako libxml2-dev libzstd-dev pkg-config)

    getDepends "${depends[@]}"
}

function sources_mesa3d() {
    gitPullOrClone
}

function build_mesa3d() {
    rp_installModule "libdrm" "_autoupdate_"

    meson builddir -Dprefix=/usr/local -Doptimization=3 --buildtype=release -Db_pie=false -Dstrip=false -Dgallium-omx=disabled -Dpower8=disabled -Dcpp_rtti=false -Ddri3=disabled -Dllvm=disabled -Dgallium-opencl=disabled -Dglx=disabled -Dgallium-xa=disabled -Dshared-glapi=enabled -Dgallium-drivers=panfrost,lima -Dgallium-extra-hud=true -Ddri-drivers= -Dvulkan-drivers= -Dosmesa=false -Dopengl=true -Dplatforms= -Dgbm=enabled -Degl=enabled -Dgles1=enabled -Dgles2=enabled -Dgallium-xvmc=disabled -Dvalgrind=disabled -Dlibunwind=disabled -Dgallium-vdpau=disabled -Dlmsensors=disabled -Dzstd=enabled -Dglvnd=false
    ninja -C builddir

    md_ret_require="$md_build/builddir/src/gbm/libgbm.so.1.0.0"
}

function install_mesa3d() {
    ninja -C builddir install
    ldconfig
}