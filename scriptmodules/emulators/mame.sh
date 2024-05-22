#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mame"
rp_module_desc="MAME emulator"
rp_module_help="ROM Extensions: .zip .7z\n\nCopy your MAME roms to either $romdir/mame or\n$romdir/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/mamedev/mame/master/COPYING"
rp_module_repo="git https://github.com/mamedev/mame.git :_get_branch_mame"
rp_module_section="exp"
rp_module_flags="!mali !armv6 !:\$__gcc_version:-lt:7"

function _get_branch_mame() {
    # starting with 0.265, GCC 10.3 or later is required for full C++17 support
    if [[ "$__gcc_version" -lt 10 ]]; then
        echo "mame0264"
        return
    fi
    download https://api.github.com/repos/mamedev/mame/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_mame() {
    # Install required libraries required for compilation and running
    # Note: libxi-dev is required as of v0.210, because of flag changes for XInput
    local depends=(libfontconfig1-dev libsdl2-ttf-dev libflac-dev libxinerama-dev libxi-dev libpulse-dev)
    # build the MAME debugger only on X11 (desktop) platforms
    isPlatform "x11" && depends+=(qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools)

    getDepends "${depends[@]}"
}

function sources_mame() {
    gitPullOrClone
    # lzma assumes hardware crc support on arm which breaks when building on armv7
    isPlatform "armv7" && applyPatch "$md_data/lzma_armv7_crc.diff"
}

function build_mame() {
    # More memory is required for 64bit platforms
    if isPlatform "64bit"; then
        rpSwap on 10240
    else
        rpSwap on 8192
    fi

    local params=(NOWERROR=1 ARCHOPTS=-U_FORTIFY_SOURCE PYTHON_EXECUTABLE=python3 OPTIMIZE=2 USE_SYSTEM_LIB_FLAC=1)
    isPlatform "x11" && params+=(USE_QTDEBUG=1) || params+=(USE_QTDEBUG=0)
    # when building on ARM enable 'fsigned-char' for compiled code, fixes crashes in a few drivers
    isPlatform "arm" || isPlatform "aarch64" && params+=(ARCHOPTS_CXX=-fsigned-char)

    # tell the linker to remove debugging info
    LDFLAGS+=" -s"

    # workaround for linker crash on bullseye (use gold linker)
    if [[ "$__os_debian_ver" -eq 11 ]] && isPlatform "arm"; then
        LDFLAGS+=" -fuse-ld=gold -Wl,--long-plt" make "${params[@]}"
    else
        QT_SELECT=5 make "${params[@]}"
    fi

    rpSwap off
    md_ret_require="$md_build/mame"
}

function install_mame() {
    md_ret_files=(
        'artwork'
        'bgfx'
        'ctrlr'
        'docs'
        'hash'
        'hlsl'
        'ini'
        'language'
        'mame'
        'plugins'
        'roms'
        'samples'
        'uismall.bdf'
        'COPYING'
    )
}

function configure_mame() {
    local system="mame"

    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "arcade"
        mkRomDir "$system"

        # Create required MAME directories underneath the ROM directory
        local mame_sub_dir
        for mame_sub_dir in artwork cfg comments diff inp nvram samples scores snap sta; do
            mkRomDir "$system/$mame_sub_dir"
        done

        # Create a BIOS directory, where people will be able to store their BIOS files, separate from ROMs
        mkUserDir "$biosdir/$system"

        # Create the configuration directory for the MAME ini files
        moveConfigDir "$home/.mame" "$md_conf_root/$system"

        # Create new INI files if they do not already exist
        # Create MAME config file
        local temp_ini_mame="$(mktemp)"

        iniConfig " " "" "$temp_ini_mame"
        iniSet "rompath"            "$romdir/$system;$romdir/arcade;$biosdir/$system"
        iniSet "hashpath"           "$md_inst/hash"
        iniSet "samplepath"         "$romdir/$system/samples;$romdir/arcade/samples"
        iniSet "artpath"            "$romdir/$system/artwork;$romdir/arcade/artwork"
        iniSet "ctrlrpath"          "$md_inst/ctrlr"
        iniSet "pluginspath"        "$md_inst/plugins"
        iniSet "languagepath"       "$md_inst/language"

        iniSet "cfg_directory"      "$romdir/$system/cfg"
        iniSet "nvram_directory"    "$romdir/$system/nvram"
        iniSet "input_directory"    "$romdir/$system/inp"
        iniSet "state_directory"    "$romdir/$system/sta"
        iniSet "snapshot_directory" "$romdir/$system/snap"
        iniSet "diff_directory"     "$romdir/$system/diff"
        iniSet "comment_directory"  "$romdir/$system/comments"

        iniSet "skip_gameinfo" "1"
        iniSet "plugin" "hiscore"
        iniSet "samplerate" "44100"

        # Raspberry Pis show improved performance using accelerated mode which enables SDL_RENDERER_TARGETTEXTURE.
        # On RPI4 it uses OpenGL as a renderer, while on earlier RPIs it uses OpenGLES2 as the renderer. 
        # X86 Ubuntu by default uses OpenGL as a renderer, but SDL doesn't have target texture enabled as default.
        # Enabling accel will use target texture on X86 Ubuntu (and likely other X86 Linux platforms).
        iniSet "video" "accel"

        copyDefaultConfig "$temp_ini_mame" "$md_conf_root/$system/mame.ini"
        rm "$temp_ini_mame"

        # Create MAME UI config file
        local temp_ini_ui="$(mktemp)"
        iniConfig " " "" "$temp_ini_ui"
        iniSet "scores_directory" "$romdir/$system/scores"
        copyDefaultConfig "$temp_ini_ui" "$md_conf_root/$system/ui.ini"
        rm "$temp_ini_ui"

        # Create MAME Plugin config file
        local temp_ini_plugin="$(mktemp)"
        iniConfig " " "" "$temp_ini_plugin"
        iniSet "hiscore" "1"
        copyDefaultConfig "$temp_ini_plugin" "$md_conf_root/$system/plugin.ini"
        rm "$temp_ini_plugin"

        # Create MAME Hi Score config file
        local temp_ini_hiscore="$(mktemp)"
        iniConfig " " "" "$temp_ini_hiscore"
        iniSet "hi_path" "$romdir/$system/scores"
        copyDefaultConfig "$temp_ini_hiscore" "$md_conf_root/$system/hiscore.ini"
        rm "$temp_ini_hiscore"
    fi

    addEmulator 0 "$md_id" "arcade" "$md_inst/mame %BASENAME%"
    addEmulator 1 "$md_id" "$system" "$md_inst/mame %BASENAME%"

    addSystem "arcade"
    addSystem "$system"
}
