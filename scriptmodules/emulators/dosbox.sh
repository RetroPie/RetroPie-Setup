#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dosbox"
rp_module_desc="DOS emulator"
rp_module_help="ROM Extensions: .bat .com .exe .sh\n\nCopy your DOS games to $romdir/pc"
rp_module_licence="GPL2 https://sourceforge.net/p/dosbox/code-0/HEAD/tree/dosbox/trunk/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !kms"

function depends_dosbox() {
    local depends=(libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libasound2-dev libpng12-dev automake autoconf zlib1g-dev)
    isPlatform "rpi" && depends+=(timidity freepats)
    getDepends "${depends[@]}"
}

function sources_dosbox() {
    downloadAndExtract "$__archive_url/dosbox-r3876.tar.gz" "$md_build" 1
}

function build_dosbox() {
    local params=()
    ! isPlatform "x11" && params+=(--disable-opengl)
    ./autogen.sh
    ./configure --prefix="$md_inst" "${params[@]}"
    if isPlatform "arm"; then
        # enable dynamic recompilation for armv4
        sed -i 's|/\* #undef C_DYNREC \*/|#define C_DYNREC 1|' config.h
        if isPlatform "armv6"; then
            sed -i 's/C_TARGETCPU.*/C_TARGETCPU ARMV4LE/g' config.h
        else
            sed -i 's/C_TARGETCPU.*/C_TARGETCPU ARMV7LE/g' config.h
            sed -i 's|/\* #undef C_UNALIGNED_MEMORY \*/|#define C_UNALIGNED_MEMORY 1|' config.h
        fi
    fi
    make clean
    make
    md_ret_require="$md_build/src/dosbox"
}

function install_dosbox() {
    make install
    md_ret_require="$md_inst/bin/dosbox"
}

function configure_dosbox() {
    local needs_synth

    # needs software synth for midi
    isPlatform "rpi" && needs_synth=1

    mkRomDir "pc"
    rm -f "$romdir/pc/Start DOSBox.sh"
    cat > "$romdir/pc/+Start DOSBox.sh" << _EOF_
#!/bin/bash

[[ ! -n "\$(aconnect -o | grep -e TiMidity -e FluidSynth)" ]] && needs_synth="$needs_synth"

function midi_synth() {
    [[ "\$needs_synth" != "1" ]] && return

    case "\$1" in
        "start")
            timidity -Os -iAD &
            until [[ -n "\$(aconnect -o | grep TiMidity)" ]]; do
                sleep 1
            done
            ;;
        "stop")
            killall timidity
            ;;
        *)
            ;;
    esac
}

params=("\$@")
if [[ -z "\${params[0]}" ]]; then
    params=(-c "@MOUNT C $romdir/pc" -c "@C:")
elif [[ "\${params[0]}" == *.sh ]]; then
    bash "\${params[@]}"
    exit
elif [[ "\${params[0]}" == *.conf ]]; then
    params=(-userconf -conf "\${params[@]}")
else
    params+=(-exit)
fi

midi_synth start
"$md_inst/bin/dosbox" "\${params[@]}"
midi_synth stop
_EOF_
    chmod +x "$romdir/pc/+Start DOSBox.sh"
    chown $user:$user "$romdir/pc/+Start DOSBox.sh"

    local config_path=$(su "$user" -c "\"$md_inst/bin/dosbox\" -printconf")
    if [[ -f "$config_path" ]]; then
        iniConfig "=" "" "$config_path"
        iniSet "usescancodes" "false"
        iniSet "core" "dynamic"
        iniSet "cycles" "max"
        iniSet "scaler" "none"
        if isPlatform "rpi" || [[ -n "$(aconnect -o | grep -e TiMidity -e FluidSynth)" ]]; then
            iniSet "mididevice" "alsa"
            iniSet "midiconfig" "128:0"
        fi
    fi

    moveConfigDir "$home/.dosbox" "$md_conf_root/pc"

    addEmulator 1 "$md_id" "pc" "bash $romdir/pc/+Start\ DOSBox.sh %ROM%"
    addSystem "pc"
}
