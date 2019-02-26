#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pegasus-fe"
rp_module_desc="Pegasus: A cross platform, customizable graphical frontend (latest alpha release)"
rp_module_licence="GPL3+ https://raw.githubusercontent.com/mmatyas/pegasus-frontend/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="!mali !kms frontend"

function depends_pegasus-fe() {
    local depends=(
        fontconfig
        gstreamer1.0-alsa
        gstreamer1.0-libav
        gstreamer1.0-plugins-good
        jq
        policykit-1
    )

    getDepends "${depends[@]}"
}

function install_bin_pegasus-fe() {
    # get all asset urls for the latest continuous release
    local all_assets
    all_assets="$(wget -q -O - https://api.github.com/repos/mmatyas/pegasus-frontend/releases/tags/continuous)" || return
    all_assets="$(echo "${all_assets}" | jq -r '.assets[] | .browser_download_url')"

    printMsgs "console" "Available releases:"
    printMsgs "console" "${all_assets}"

    # find out which platform's package we'll need
    local platform
    isPlatform "x11" && platform="x11"
    isPlatform "rpi" && platform="$__platform"
    if [[ -z "${platform}" ]]; then
        md_ret_errors+=("Sorry, Pegasus is not yet available for this platform. Consider reporting this on the forum!")
        return
    fi

    printMsgs "console" "Package platform: ${platform}"

    # select the url for the platform
    local asset_url
    asset_url="$(echo "${all_assets}" | grep ${platform})"

    if [[ -z "${asset_url}" ]]; then
        md_ret_errors+=("Looks like the latest Pegasus release is not yet available for this platform. This happens when the build is so fresh it's being uploaded right now, or when there's a technical problem on the download server. Either way, this is a temporary problem, so please try again in 1-2 minutes. If the problem persists, consider reporting it on the forum!")
        return
    fi

    # download and extract the package
    printMsgs "console" "Download URL: ${asset_url}"
    downloadAndExtract "${asset_url}" "$md_inst"

    # create launcher script
    cat > /usr/bin/pegasus-fe << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "Pegasus should not be run as root. If you used 'sudo pegasus-fe' please run without sudo."
    exit 1
fi

# save current tty/vt number for use with X so it can be launched on the correct tty
tty=\$(tty)
export TTY="\${tty:8:1}"

clear
"$md_inst/pegasus-fe" "\$@"
_EOF_
    chmod +x /usr/bin/pegasus-fe
}

function remove_pegasus-fe() {
    rm -f /usr/bin/pegasus-fe
}

function configure_pegasus-fe() {
    moveConfigDir "$home/.config/pegasus-frontend" "$md_conf_root/all/pegasus-fe"

    # create external directories
    mkUserDir "$md_conf_root/all/pegasus-fe/scripts"
    mkUserDir "$md_conf_root/all/pegasus-fe/themes"
}
