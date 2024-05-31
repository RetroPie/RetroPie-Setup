#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-scummvm"
rp_module_desc="ScummVM port for libretro"
rp_module_help="Copy your ScummVM games to $romdir/scummvm\n\nThe name of your game directories must be suffixed with '.svm' for direct launch in EmulationStation."
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/scummvm/master/COPYING"
rp_module_repo="git https://github.com/libretro/scummvm.git master"
rp_module_section="exp"

function depends_lr-scummvm() {
    getDepends zip
}

function sources_lr-scummvm() {
    gitPullOrClone
}

function build_lr-scummvm() {
    local gl_platform=OPENGL
    isPlatform "gles" && gl_platform=OPENGLES2
    cd backends/platform/libretro
    make clean
    make USE_MT32EMU=1 FORCE_${gl_platform}=1
    make datafiles
    md_ret_require="$md_build/backends/platform/libretro/scummvm_libretro.so"
}

function install_lr-scummvm() {
    md_ret_files=(
        "backends/platform/libretro/scummvm_libretro.so"
        "backends/platform/libretro/scummvm.zip"
        "COPYING"
    )
}

function configure_lr-scummvm() {
    addEmulator 0 "$md_id" "scummvm" "$md_inst/romdir-launcher.sh %ROM%"
    addSystem "scummvm"
    [[ "$md_mode" == "remove" ]] && return

    # ensure rom dir and system retroconfig
    mkRomDir "scummvm"
    defaultRAConfig "scummvm"

    # unpack the data files to system dir
    runCmd unzip -q -o "$md_inst/scummvm.zip" -d "$biosdir"
    chown -R $user:$user "$biosdir/scummvm"

    # basic initial configuration (if config file not found)
    if [[ ! -f "$biosdir/scummvm.ini" ]]; then
        echo "[scummvm]" > "$biosdir/scummvm.ini"
        iniConfig "=" "" "$biosdir/scummvm.ini"
        iniSet "extrapath" "$biosdir/scummvm/extra"
        iniSet "themepath" "$biosdir/scummvm/theme"
        iniSet "soundfont" "$biosdir/scummvm/extra/Roland_SC-55.sf2"
        iniSet "gui_theme" "scummremastered"
        iniSet "subtitles" "true"
        iniSet "multi_midi" "true"
        iniSet "gm_device" "fluidsynth"
        chown $user:$user "$biosdir/scummvm.ini"
    fi

    # enable speed hack core option if running in arm platform
    isPlatform "arm" && setRetroArchCoreOption "scummvm_speed_hack" "enabled"

    # create retroarch launcher for lr-scummvm with support for rom directories
    # containing svm files inside (for direct game directory launching in ES)
    cat > "$md_inst/romdir-launcher.sh" << _EOF_
#!/usr/bin/env bash
ROM=\$1; shift
SVM_FILES=()
[[ -d \$ROM ]] && mapfile -t SVM_FILES < <(compgen -G "\$ROM/*.svm")
[[ \${#SVM_FILES[@]} -eq 1 ]] && ROM=\${SVM_FILES[0]}
$emudir/retroarch/bin/retroarch \\
    -L "$md_inst/scummvm_libretro.so" \\
    --config "$md_conf_root/scummvm/retroarch.cfg" \\
    "\$ROM" "\$@"
_EOF_
    chmod +x "$md_inst/romdir-launcher.sh"
}
