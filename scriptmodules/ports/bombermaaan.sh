#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="bombermaaan"
rp_module_desc="Bombermaaan - Classic bomberman game"
rp_module_licence="GPL3 https://raw.githubusercontent.com/bjaraujo/Bombermaaan/master/COPYING.txt"
rp_module_repo="git https://github.com/bjaraujo/Bombermaaan.git master"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_bombermaaan() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev
}

function sources_bombermaaan() {
    gitPullOrClone
    applyPatch "$md_data/01-cmake-sdl-mixer.diff"
}

function build_bombermaaan() {
    cd trunk
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst" -DLOAD_RESOURCES_FROM_FILES:BOOL=ON
    make
    mv bin/Bombermaaan bombermaaan
    md_ret_require="$md_build/trunk/bombermaaan"
}

function install_bombermaaan() {
    md_ret_files=(
        'trunk/bombermaaan'
        'trunk/levels'
        'trunk/res/images'
        'trunk/res/sounds'
    )
}

function configure_bombermaaan() {
    addPort "$md_id" "bombermaaan" "Bombermaaan" "$md_inst/bombermaaan"

    [[ "$mode" == "remove" ]] && return

    local file="$romdir/ports/Bombermaaan.sh"
    cat >"$file" << _EOF_
#!/usr/bin/env bash
pushd "$md_inst"
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ bombermaaan ""
popd
_EOF_
    chown "$__user":"$__group" "$file"
    chmod +x "$file"
}
