#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="supermodel"
rp_module_desc="Sega Model 3 Arcade emulator (v0.3-WIP)"
rp_module_help="ROM Extensions: .zip\n\nCopy your Model 3 roms to $romdir/model3"
rp_module_licence="GPL3 http://svn.code.sf.net/p/model3emu/code/trunk/Docs/LICENSE.txt"
rp_module_section="exp"
rp_module_flags=""

function depends_supermodel() {
    getDepends subversion build-essential libsdl1.2-dev libglew2.0 zlib1g-dev
}

function sources_supermodel() {
    local revision="$1"
    [[ -z "$revision" ]] && revision="789"

    svn checkout https://svn.code.sf.net/p/model3emu/code/trunk "$md_build" -r "$revision"
}

function build_supermodel() {
    ln -s Makefiles/Makefile.UNIX Makefile
    make -j`nproc`
    cd bin
    mkdir -p Config NVRAM Saves
    cp ../Config/Supermodel.ini Config
    cp ../Config/Games.xml Config
    
    cd Config
    way="/opt/retropie/emulators/supermodel/bin/Config"
    if [[ -e $way/Supermodel.ini ]]; then
	mv Supermodel.ini Supermodel.ini.rp-dist
    fi

    md_ret_require="$md_build/bin/supermodel"
}

function install_supermodel() {
    md_ret_files=(
	'bin'
        'Docs/LICENSE.txt'
        'Docs/README.txt'
    )
}

function configure_supermodel() {
    #Find out Screen Resolution
    local Xaxis
    local Yaxis
    Xaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
    Yaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

    mkRomDir "model3"

    moveConfigDir "$md_inst/bin/Config" "$md_conf_root/model3/Config"
    moveConfigDir "$md_inst/bin/NVRAM" "$HOME/.model3/NVRAM"
    moveConfigDir "$md_inst/bin/Saves" "$HOME/.model3/Saves"

    chown -R $user:$user "$md_conf_root/model3/Config"
    chown -R $user:$user "$HOME/.model3"

    addEmulator 0 "$md_id-legacy3d" "model3" "$md_inst/supermodel.sh -res=$Xaxis,$Yaxis -fullscreen -legacy3d -quad-rendering %ROM%"
    addEmulator 0 "$md_id-new3d" "model3" "$md_inst/supermodel.sh -res=$Xaxis,$Yaxis -fullscreen -quad-rendering %ROM%"
    addEmulator 0 "$md_id-nv-optimus" "model3" "optirun $md_inst/supermodel.sh -res=$Xaxis,$Yaxis -fullscreen -quad-rendering %ROM%"

    addSystem "model3"

    local file="$md_inst/supermodel.sh"
    cat >"$file" << _EOF_
#!/bin/bash
pushd "$md_inst/bin"
./$md_id "\$@"
popd
_EOF_
    chmod +x "$file"
}
