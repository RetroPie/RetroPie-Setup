#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="attractmode"
rp_module_desc="Attract Mode emulator frontend"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mickelson/attract/master/License.txt"
rp_module_repo="git https://github.com/mickelson/attract master"
rp_module_section="exp"
rp_module_flags="!mali frontend"

function _get_configdir_attractmode() {
    echo "$configdir/all/attractmode"
}

function _add_system_attractmode() {
    local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" || ! -f /usr/bin/attract ]] && return 0

    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    # replace any / characters in fullname
    fullname="${fullname//\/}"

    local config="$attract_dir/emulators/$fullname.cfg"
    iniConfig " " "" "$config"
    # replace %ROM% with "[romfilename]" and convert to array
    command=(${command//%ROM%/\"[romfilename]\"})
    iniSet "executable" "${command[0]}"
    iniSet "args" "${command[*]:1}"

    iniSet "rompath" "$path"
    iniSet "system" "$fullname"

    # extensions separated by semicolon
    extensions="${extensions// /;}"
    iniSet "romext" "$extensions"

    # snap path
    local snap="snap"
    [[ "$name" == "retropie" ]] && snap="icons"
    iniSet "artwork flyer" "$path/flyer"
    iniSet "artwork marquee" "$path/marquee"
    iniSet "artwork snap" "$path/$snap"
    iniSet "artwork wheel" "$path/wheel"

    chown $user:$user "$config"

    # if no gameslist, generate one
    if [[ ! -f "$attract_dir/romlists/$fullname.txt" ]]; then
        sudo -u $user attract --build-romlist "$fullname" -o "$fullname"
    fi

    local config="$attract_dir/attract.cfg"
    local tab=$'\t'
    if [[ -f "$config" ]] && ! grep -q "display$tab$fullname" "$config"; then
        cp "$config" "$config.bak"
        cat >>"$config" <<_EOF_
display${tab}$fullname
${tab}layout               Basic
${tab}romlist              $fullname
_EOF_
        chown $user:$user "$config"
    fi
}

function _del_system_attractmode() {
    local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" ]] && return 0

    local fullname="$1"
    local name="$2"

    # Don't remove an empty system
    [[ -z "$fullname" ]] && return 0

    # replace any / characters in fullname
    fullname="${fullname//\/}"

    rm -rf "$attract_dir/romlists/$fullname.txt"

    local tab=$'\t'
    # remove display block from "^display$tab$fullname" to next "^display" or empty line keeping the next display line
    sed -i "/^display$tab$fullname/,/^display\|^$/{/^display$tab$fullname/d;/^display\$/!d}" "$attract_dir/attract.cfg"
}

function _add_rom_attractmode() {
    local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" ]] && return 0

    local system_name="$1"
    local system_fullname="$2"
    local path="$3"
    local name="$4"
    local desc="$5"
    local image="$6"

    local config="$attract_dir/romlists/$system_fullname.txt"

    # remove extension
    path="${path/%.*}"

    if [[ ! -f "$config" ]]; then
        echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons" >"$config"
    fi

    # if the entry already exists, remove it
    if grep -q "^$path;" "$config"; then
        sed -i "/^$path/d" "$config"
    fi

    echo "$path;$name;$system_fullname;;;;;;;;;;;;;;" >>"$config"
    chown $user:$user "$config"
}

function depends_attractmode() {
    local depends=(
        cmake libflac-dev libcurl4-openssl-dev libogg-dev libvorbis-dev libopenal-dev libfreetype6-dev
        libudev-dev libjpeg-dev libudev-dev libavutil-dev libavcodec-dev
        libavformat-dev libavfilter-dev libswscale-dev libswresample-dev
        libfontconfig1-dev
    )
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "kms" && depends+=(libegl1-mesa-dev libgl-dev libglu1-mesa-dev libdrm-dev libgbm-dev)
    isPlatform "x11" && depends+=(libsfml-dev)
    getDepends "${depends[@]}"
}

function sources_attractmode() {
    gitPullOrClone "$md_build/attract"
    isPlatform "rpi" && gitPullOrClone "$md_build/sfml-pi" "https://github.com/mickelson/sfml-pi"
}

function build_attractmode() {
    if isPlatform "rpi"; then
        local params
        cd sfml-pi
        isPlatform "videocore" && params="-DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libbrcmEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libbrcmGLESv2.so"
        isPlatform "kms" && params="-DSFML_DRM=1"
        cmake . -DCMAKE_INSTALL_PREFIX="$md_inst/sfml" $params
        make clean
        make
        cd ..
    fi
    cd attract
    make clean
    local params=(prefix="$md_inst")
    isPlatform "videocore" && params+=(USE_GLES=1 EXTRA_CFLAGS="$CFLAGS -I$md_build/sfml-pi/include -L$md_build/sfml-pi/lib")
    isPlatform "kms" && params+=(USE_DRM=1 EXTRA_CFLAGS="$CFLAGS -I$md_build/sfml-pi/include -L$md_build/sfml-pi/lib")
    isPlatform "rpi" && params+=(USE_MMAL=1)
    make "${params[@]}"

    # remove example configs
    rm -rf "$md_build/attract/config/emulators/"*

    md_ret_require="$md_build/attract/attract"
}

function install_attractmode() {
    make -C sfml-pi install
    mkdir -p "$md_inst"/{bin,share,share/attract}
    cp -v attract/attract "$md_inst/bin/"
    cp -Rv attract/config/* "$md_inst/share/attract"
}

function remove_attractmode() {
    rm -f /usr/bin/attract
}

function configure_attractmode() {
    moveConfigDir "$home/.attract" "$md_conf_root/all/attractmode"

    [[ "$md_mode" == "remove" ]] && return

    local config="$md_conf_root/all/attractmode/attract.cfg"
    if [[ ! -f "$config" ]]; then
        echo "general" >"$config"
        echo -e "\twindow_mode          fullscreen" >>"$config"
    fi

    mkUserDir "$md_conf_root/all/attractmode/emulators"
    cat >/usr/bin/attract <<_EOF_
#!/bin/bash
MODETEST=/opt/retropie/supplementary/mesa-drm/modetest
if [[ -z "\$DISPLAY" && -f "\$MODETEST" && ! "\$1" =~ build-romlist ]]; then
    MODELIST="\$(\$MODETEST -r 2>/dev/null)"
    default_mode="\$(echo "\$MODELIST" | grep -Em1 "^Mode:.*(driver|userdef).*crtc" | cut -f 2 -d ' ')"
    default_vrefresh="\$(echo "\$MODELIST" | grep -Em1 "^Mode:.*(driver|userdef).*crtc" | cut -f 4 -d ' ')"
    echo "Using default video mode: \$default_mode @ \$default_vrefresh"

    [[ ! -z "\$default_mode" ]] && export SFML_DRM_MODE="\$default_mode"
    [[ ! -z "\$default_vrefresh" ]] && export SFML_DRM_REFRESH="\$default_vrefresh"
fi
LD_LIBRARY_PATH="$md_inst/sfml/lib" "$md_inst/bin/attract" "\$@"
_EOF_
    chmod +x "/usr/bin/attract"

    local id
    for id in "${__mod_id[@]}"; do
        if rp_isInstalled "$id" && [[ -n "${__mod_info[$id/section]}" ]] && ! hasFlag "${__mod_info[$id/flags]}" "frontend"; then
            rp_callModule "$id" configure
        fi
    done
}
