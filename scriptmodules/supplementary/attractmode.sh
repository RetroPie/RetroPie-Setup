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
rp_module_section="exp"
rp_module_flags="!mali"

function _addsystem_attractmode() {
    local attract_dir="$configdir/all/attractmode"
    [[ ! -d "$attract_dir" ]] && return 1

    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    local config="$attract_dir/emulators/$name.cfg"
    iniConfig " " "" "$config"
    # replace %ROM% with "[romfilename]" and convert to array
    command=(${command//%ROM%/\"[romfilename]\"})
    iniSet "executable" "${command[0]}"
    iniSet "args" "${command[*]:1}"

    iniSet "rompath" "$path"
    iniSet "system" "$fullname"
    #iniSet "info_source" "thegamesdb.net"

    # extensions separated by semicolon
    extensions="${extensions// /;}"
    iniSet "romext" "$extensions"

    chown $user:$user "$config"

    # if no gameslist, generate one
    if [[ ! -f "$attract_dir/romlists/$name.txt" ]]; then
        sudo -u $user attract --build-romlist "$name" -o "$name"
    fi

    local config="$attract_dir/attract.cfg"
    local tab=$'\t'
    if [[ -f "$config" ]] && ! grep -q "display$tab$name" "$config"; then
        cat >>"$config" <<_EOF_
display${tab}$name
${tab}layout               Basic
${tab}romlist              $name
_EOF_
        chown $user:$user "$config"
    fi
}

function depends_attractmode() {
    local depends=(
        cmake libflac-dev libogg-dev libvorbis-dev libopenal-dev libfreetype6-dev
        libudev-dev libjpeg-dev libudev-dev libavutil-dev libavcodec-dev
        libavformat-dev libavfilter-dev libswscale-dev libavresample-dev
        libfontconfig1-dev
    )
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}" 
}

function sources_attractmode() {
    isPlatform "rpi" && gitPullOrClone "$md_build/sfml-pi" "https://github.com/mickelson/sfml-pi"
    gitPullOrClone "$md_build/attract" "https://github.com/mickelson/attract"
    mkdir build
}

function build_attractmode() {
    if isPlatform "rpi"; then
        cd sfml-pi
        cmake . -DCMAKE_INSTALL_PREFIX="$md_inst/sfml" -DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libGLESv1_CM.so
        make clean
        make
        make install
        cd ..
    fi
    cd attract
    make clean
    local params=(prefix="$md_inst")
    isPlatform "rpi" && params+=(EXTRA_CFLAGS="$CFLAGS -I$md_inst/sfml/include -L$md_inst/sfml/lib")
    make "${params[@]}"

    # remove example configs
    rm -rf "$md_build/attract/config/emulators/"*

    md_ret_require="$md_build/attract/attract"
}

function install_attractmode() {
    mkdir -p "$md_inst"/{bin,share,share/attract}
    cp attract/attract "$md_inst/bin/"
    cp -R attract/config/* "$md_inst/share/attract"
}


function configure_attractmode() {
    moveConfigDir "$home/.attract" "$md_conf_root/all/attractmode"

    local config="$md_conf_root/all/attractmode/attract.cfg"
    if [[ ! -f "$config" ]]; then
        echo "general" >"$config"
        echo -e "\twindow_mode          fullscreen" >>"$config"
    fi

    mkUserDir "$md_conf_root/all/attractmode/emulators"
    cat >/usr/bin/attract <<_EOF_
#!/bin/bash
LD_LIBRARY_PATH="$md_inst/sfml/lib" "$md_inst/bin/attract" "\$@"
_EOF_
    chmod +x "/usr/bin/attract"

    local idx
    for idx in "${__mod_idx[@]}"; do
        if rp_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" && "$idx" != "$md_idx" ]]; then
            rp_callModule "$idx" configure
        fi
    done
}
