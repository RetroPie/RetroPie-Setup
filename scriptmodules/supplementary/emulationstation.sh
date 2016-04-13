#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation"
rp_module_desc="EmulationStation"
rp_module_menus="2+"

function depends_emulationstation() {
    local depends=(
        libboost-locale-dev libboost-system-dev libboost-filesystem-dev
        libboost-date-time-dev libfreeimage-dev libfreetype6-dev libeigen3-dev
        libcurl4-openssl-dev libasound2-dev cmake libsdl2-dev libsm-dev
        )

    isPlatform "x11" && depends+=(gnome-terminal)
    getDepends "${depends[@]}"
}

function sources_emulationstation() {
    local repo="$1"
    local branch="$2"
    [[ -z "$repo" ]] && repo="https://github.com/retropie/EmulationStation"
    [[ -z "$branch" ]] && branch="master"
    gitPullOrClone "$md_build" "$repo" "$branch"
    # make sure libMali.so can be found so we use OpenGL ES
    if isPlatform "mali"; then
        sed -i 's|/usr/lib/libMali.so|/usr/lib/arm-linux-gnueabihf/libMali.so|g' CMakeLists.txt
    fi
}

function build_emulationstation() {
    rpSwap on 512
    cmake . -DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/emulationstation"
}

function install_emulationstation() {
    md_ret_files=(
        'CREDITS.md'
        'emulationstation'
        'emulationstation.sh'
        'GAMELISTS.md'
        'README.md'
        'THEMES.md'
    )
}

function configure_inputconfig_emulationstation() {
    local es_config="$home/.emulationstation/es_input.cfg"

    # move the $home/emulationstation configuration dir and symlink it
    moveConfigDir "$home/.emulationstation"  "$configdir/all/emulationstation"

    # if there is no ES config (or empty file) create it with initial inputList element
    if [[ ! -s "$es_config" ]]; then
        echo "<inputList />" >"$es_config"
    fi

    # add our inputconfiguration.sh inputAction if it is missing
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputAction[@type='onfinish'])" "$es_config") -eq 0 ]]; then
        xmlstarlet ed -L -S \
            -s "/inputList" -t elem -n "inputActionTMP" -v "" \
            -s "//inputActionTMP" -t attr -n "type" -v "onfinish" \
            -s "//inputActionTMP" -t elem -n "command" -v "$md_inst/scripts/inputconfiguration.sh" \
            -r "//inputActionTMP" -v "inputAction" "$es_config"
    fi

    chown $user:$user "$es_config"
    mkdir -p "$md_inst/scripts"

    cp -rv "$scriptdir/scriptmodules/$md_type/emulationstation/"* "$md_inst/scripts/"
    chmod +x "$md_inst/scripts/inputconfiguration.sh"
    chown -R $user:$user "$md_inst/scripts"
}

function configure_emulationstation() {
    cat > /usr/bin/emulationstation << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "emulationstation should not be run as root. If you used 'sudo emulationstation' please run without sudo."
    exit 1
fi

if [[ "\$(uname --machine)" != *86* ]]; then
    if [[ -n "\$(pidof X)" ]]; then
        echo "X is running. Please shut down X in order to mitigate problems with losing keyboard input. For example, logout from LXDE."
        exit 1
    fi
fi

clear
pushd "$md_inst" >/dev/null
./emulationstation.sh "\$@"
popd >/dev/null

_EOF_
    if isPlatform "rpi"; then
        # make sure that ES has enough GPU memory
        iniConfig "=" "" /boot/config.txt
        iniSet "gpu_mem_256" 128
        iniSet "gpu_mem_512" 256
        iniSet "gpu_mem_1024" 256
        iniSet "overscan_scale" 1
    fi

    if isPlatform "x11"; then
        mkdir -p /usr/local/share/icons
        mkdir -p /usr/local/share/applications
        cp "$scriptdir/scriptmodules/$md_type/emulationstation/retropie.svg" "/usr/local/share/icons/"
        cat > /usr/local/share/applications/retropie.desktop << _EOF_
[Desktop Entry]
Type=Application
Exec=gnome-terminal --full-screen -e emulationstation
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[de_DE]=RetroPie
Name=rpie
Comment[de_DE]=RetroPie
Comment=retropie
Icon=/usr/local/share/icons/retropie.svg
Categories=Game
_EOF_
    fi

    chmod +x /usr/bin/emulationstation

    mkdir -p "/etc/emulationstation"

    configure_inputconfig_emulationstation
    
    addAutoConf es_swap_a_b 0
}

function remove_emulationstation() {
    rm -rfv "/etc/emulationstation" "$home/.emulationstation" "/usr/bin/emulationstation" "$configdir/emulationstation"
    if isPlatform "x11"; then
        rm -rfv "/usr/local/share/icons/retropie.svg" "/usr/local/share/applications/retropie.desktop"
    fi
}
