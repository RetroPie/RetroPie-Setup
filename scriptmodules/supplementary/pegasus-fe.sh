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
rp_module_desc="Pegasus: A cross platform, customizable graphical frontend (latest pre-built release)"
rp_module_help="Pegasus is a cross platform, customizable graphical frontend for launching emulators and managing your game collection.\nThis package installs the upstream pre-built binaries. Use this package on RaspiOS Buster or PC/x86 installations"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/pegasus-frontend/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="!mali frontend"

function depends_pegasus-fe() {
    local depends=(
        fontconfig
        gstreamer1.0-alsa
        gstreamer1.0-libav
        gstreamer1.0-plugins-good
        jq
        libsdl2-dev
        policykit-1
    )
    # show an error on 64bit ARMs, since there are no pre-built packages for it
    if isPlatform "arm" && hasFlag "64bit"; then
        md_ret_errors+=("There are no pre-build binaries for 64bit ARM systems! Try installing Pegasus with the ${md_id}-dev package")
        return 1
    fi
    getDepends "${depends[@]}"
}

function install_bin_pegasus-fe() {
    # get all asset urls for the latest continuous release
    local all_assets
    all_assets="$(download https://api.github.com/repos/mmatyas/pegasus-frontend/releases/tags/continuous -)" || return
    all_assets="$(echo "${all_assets}" | jq -r '.assets[] | .browser_download_url')"

    printMsgs "console" "Available releases:"
    printMsgs "console" "${all_assets}"

    # find out which platform's package we'll need
    local platform
    isPlatform "x11" && platform="x11"
    isPlatform "rpi" && platform="$__platform"
    if [[ -z "${platform}" ]]; then
        md_ret_errors+=("Sorry, Pegasus has no pre-built binaries for this platform. Consider installing the ${md_id}-dev package or reporting this on the RetroPie forum!")
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

    _add_launcher_pegasus-fe
}

function _add_launcher_pegasus-fe() {
# create launcher script
    cat > /usr/bin/pegasus-fe << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "Pegasus should not be run as root. If you used 'sudo pegasus-fe' please run without sudo."
    exit 1
fi

_EOF_

# on KMS platforms, add some additional setup commands
if isPlatform "kms"; then
    cat >> /usr/bin/pegasus-fe << _EOF_
# KMS setup
export QT_QPA_EGLFS_FORCE888=1  # improve gradients
export QT_QPA_EGLFS_KMS_ATOMIC=1  # use the atomic DRM API on Pi 4
export QT_QPA_PLATFORM=eglfs
export QT_QPA_QT_QPA_EGLFS_INTEGRATION=eglfs_kms

# find the right DRI card
for i in \$(find /sys/devices/platform -name "card?"); do
   node=\${i:0-1}
   case "\$i" in
   *gpu*)  card=\$node ;;
  esac
done

echo Using DRI card at /dev/dri/card\${card}
file="/tmp/pegasus_\$\$.eglfs.json"
echo "{ \"device\": \"/dev/dri/card\${card}\" }" > "\$file"
export QT_QPA_EGLFS_KMS_CONFIG="\$file"
_EOF_
fi

    cat >> /usr/bin/pegasus-fe << _EOF_
clear
"$md_inst/pegasus-fe" "\$@"

rm -f "/tmp/pegasus_\$\$.eglfs.json"
_EOF_

    chmod +x /usr/bin/pegasus-fe
}

function _update_themes_pegasus-fe() {
    # add some themes to Pegasus
    echo Installing themes
    declare themes=(
        "mmatyas/pegasus-theme-9999999-in-1"
        "mmatyas/pegasus-theme-es2-simple"
        "mmatyas/pegasus-theme-flixnet"
        "mmatyas/pegasus-theme-secretary"
    )
    local theme
    pushd "$home/.config/pegasus-frontend/themes" || return
    for theme in ${themes[@]}; do
        local path=${theme//"mmatyas/pegasus-theme-"/}
        gitPullOrClone "$path" "https://github.com/$theme"
    done
    popd
}
function remove_pegasus-fe() {
    rm -f /usr/bin/pegasus-fe
}

function configure_pegasus-fe() {
    moveConfigDir "$home/.config/pegasus-frontend" "$md_conf_root/all/pegasus-fe"

    # create external directories
    mkUserDir "$md_conf_root/all/pegasus-fe/scripts"
    mkUserDir "$md_conf_root/all/pegasus-fe/themes"

    [[ "$md_mode" == "remove" ]] && return

    # remove the other Pegasus package if it's installed
    if [[ "$md_id" == "pegasus-fe-dev" ]]; then
        rmDirExists "$rootdir/$md_type/pegasus-fe"
    else
        rmDirExists "$rootdir/$md_type/pegasus-fe-dev"
    fi
    # update themes
    _update_themes_pegasus-fe
}
