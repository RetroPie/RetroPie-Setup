#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pegasus-fe-dev"
rp_module_desc="Pegasus: A cross platform, customizable graphical frontend (lastest master)"
rp_module_help="Pegasus is a cross platform, customizable graphical frontend for launching emulators and managing your game collection.\nThis package provides source installation on platforms not covered by the upstream project pre-built binaries (i.e. ARM 64bit)."
rp_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/pegasus-frontend/master/LICENSE.md"
rp_module_section="exp"
rp_module_repo="git https://github.com/mmatyas/pegasus-frontend master"
rp_module_flags="!mali frontend"

function depends_pegasus-fe-dev() {
    if [[ "$__os_debian_ver" -lt 11 ]]; then
        md_ret_errors+=("Pegasus (dev) requires Debian 11 (bullseye) or later. Please install the 'pegasus-fe' package instead.")
        return 1
    fi

    if [[ -n "$__os_ubuntu_ver" ]] && compareVersions "$__os_ubuntu_ver" lt 22.04; then
        md_ret_errors+=("Pegasus (dev) requires Ubuntu 22.04 or later. Please install the 'pegasus-fe' package instead.")
        return 1
    fi

    local depends=(
        fontconfig
        gstreamer1.0-alsa
        gstreamer1.0-libav
        gstreamer1.0-plugins-good
        libqt5multimedia5-plugins
        libsdl2-dev
        pkg-config
        policykit-1
        qml-module-qtgraphicaleffects qml-module-qtmultimedia qml-module-qtqml
        qml-module-qtqml-models2
        qml-module-qtquick-controls qml-module-qtquick-controls2
        qml-module-qtquick-layouts qml-module-qtquick-templates2
        qml-module-qtquick-window2 qml-module-qtquick2
        qml-module-qt-labs-qmlmodels qml-module-qtquick-shapes
    )
    # Qt build dependencies
    depends+=(qtbase5-private-dev qtdeclarative5-dev qtmultimedia5-dev libqt5svg5-dev qttools5-dev)
    getDepends "${depends[@]}"
}

function sources_pegasus-fe-dev() {
    gitPullOrClone
    # on KMS, apply a patch to fix lanching games
    isPlatform "kms" && applyPatch "$md_build/etc/rpi4/kms_launch_fix.diff"
}

function build_pegasus-fe-dev() {
    rm -fr release && mkdir -p release
    pushd release
    qmake .. QMAKE_CXXFLAGS+="$__cxxflags" QMAKE_LIBS_LIBDL=-ldl USE_SDL_GAMEPAD=1 USE_SDL_POWER=1 INSTALLDIR="$md_inst"
    make
    md_ret_require=(
        "$md_build/release/src/app/pegasus-fe"
    )
}

function install_pegasus-fe-dev() {
    make -C release install
    _add_launcher_pegasus-fe
}

function remove_pegasus-fe-dev() {
    remove_pegasus-fe
}

function configure_pegasus-fe-dev() {
    configure_pegasus-fe
}
