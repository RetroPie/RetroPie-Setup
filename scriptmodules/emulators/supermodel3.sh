#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="supermodel3"
rp_module_desc="Super Model 3 Emulator"
rp_module_help="Copy your Sega Model 3 roms to $romdir/arcade"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/model3emu-code-sinden/main/Docs/LICENSE.txt"
rp_module_repo="git https://github.com/DirtBagXon/model3emu-code-sinden.git :_get_branch_supermodel3"
rp_module_section="exp"
rp_module_flags="all !armv6 !armv7"

function _get_branch_supermodel3() {
    if isPlatform "x86"; then
        echo "main"
    else
        echo "arm"
    fi
}

function depends_supermodel3() {
    local depends=(libsdl2-dev libsdl2-net-dev libxi-dev libglu1-mesa-dev)
    # on KMS we need x11 to start the emulator
    isPlatform "kms" && depends+=(xorg matchbox-window-manager)
    getDepends "${depends[@]}"
}

function sources_supermodel3() {
    gitPullOrClone
}

function build_supermodel3() {
    make -f Makefiles/Makefile.UNIX clean
    make -f Makefiles/Makefile.UNIX NET_BOARD=1 VERBOSE=1 ARCH="" OPT="$__default_cflags"
    md_ret_require="bin/supermodel"
}

function install_supermodel3() {
    md_ret_files=(
        'bin/supermodel'
        'Config'
        'Docs/LICENSE.txt'
        'Docs/README.txt'
    )
    isPlatform "x86" && md_ret_files+=("Assets")
}

function configure_supermodel3() {

    mkRomDir "arcade"
    addSystem "arcade"

    local game_args="-vsync"
    local launch_prefix=""
    # launch the emulator with an X11 backend, has better scaling and mouse/lightgun support
    isPlatform "kms" && launch_prefix="XINIT:"

    addEmulator 0 "$md_id" "arcade" "${launch_prefix}$md_inst/supermodel.sh %ROM% $game_args"
    addEmulator 0 "$md_id-scaled" "arcade" "${launch_prefix}$md_inst/supermodel.sh %ROM% $game_args -res=%XRES%,%YRES%"
    if isPlatform "x86"; then
        # add a legacy3d entry for less powerful PC systems
        addEmulator 0 "$md_id-legacy3d" "arcade" "$md_inst/supermodel.sh %ROM% -legacy3d $game_args"
    fi

    [[ "$md_mode" == "remove" ]] && return

    local conf_dir="$md_conf_root/arcade/supermodel3"
    mkUserDir "$conf_dir"
    mkUserDir "$conf_dir/NVRAM"
    mkUserDir "$conf_dir/Saves"
    mkUserDir "$conf_dir/Config"
    isPlatform "x86" && mkUserDir "$conf_dir/Assets"

    # on upgrades keep the local config, but overwrite the game configs
    copyDefaultConfig "$md_inst/Config/Supermodel.ini" "$conf_dir/Config/Supermodel.ini"
    cp -f "$md_inst/Config/Games.xml" "$conf_dir/Config/"
    isPlatform "x86" && cp -fr "$md_inst/Assets" "$conf_dir"
    chown -R "$__user":"$__group" "$conf_dir"

    cat >"$md_inst/supermodel.sh" <<_EOF_
#!/usr/bin/env bash

commands="\${1%.*}.commands"

if [[ -f "\$commands" ]]; then
    params=\$(<"\$commands" tr -d '\r' | tr '\n' ' ')
fi

pushd $conf_dir
$md_inst/supermodel "\$@" \$params
popd
_EOF_
    chmod +x "$md_inst/supermodel.sh"
}
