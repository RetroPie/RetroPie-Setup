#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="q3lite"
rp_module_desc="Q3lite: Updated id Tech 3 game engine for embedded Linux systems, running on GLES1.1 and SDL2"
rp_module_help="This port requires:\n1. Your original CD key;\n2. The pak0.pk3 file from the original disc.\n\nIt plays natively with keyboard and mouse, but you could use xboxdrv to map a gamepad instead."
rp_module_licence="GPL3 https://raw.githubusercontent.com/cdev-tux/q3lite/dev/COPYING.txt"
rp_module_section="opt"
rp_module_flags="!x86 !kms"

function depends_q3lite() {
    local depends=(libsdl2-dev libasound2-dev libudev-dev libibus-1.0-dev libevdev-dev libdbus-1-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)
    getDepends "${depends[@]}"
}

function sources_q3lite() {
    # before we start user requires the original game and acceptance of EULA for downloaded material
    dialog \
      --title "Installation Requirements" \
      --yes-label "Proceed" \
      --no-label "Abort" \
      --yesno \
      "\nTo install and run this port you will need to:\n\n \
1. Accept the terms of the EULA to download the pak files for the 1.32b point release;\n \
2. Have the pak0.pk3 file and CD key from your original copy of the game." \
      10 95 2>&1 >/dev/tty || return 1

    # capped at 10287a7 until Retropie upgrades to SDL2 v2.0.9
    gitPullOrClone "$md_build" https://github.com/cdev-tux/q3lite.git dev 10287a7

    # vero4k autodetection and generic SDL2 fix (affects RPi as well), not yet merged upstream
    applyPatch "$md_data/01_vero4k.diff"
}

function build_q3lite() {
    if isPlatform "rpi"; then
        # must define a platform_type
        local extra_params="PLATFORM=linux COMPILE_PLATFORM=linux PLATFORM_TYPE=raspberrypi"
        # but CFLAGS already defined by RP so skip them
        sed -i '/^\s*PI_CFLAGS/d' ./Makefile.q3lite
    fi

    make -j4 $extra_params \
      V=0 \
      BUILD_SERVER=1 \
      BUILD_CLIENT=1 \
      BUILD_BASEGAME=1 \
      BUILD_MISSIONPACK=1 \
      BUILD_GAME_SO=0 \
      BUILD_GAME_QVM=1 \
      BUILD_STANDALONE=0 \
      SERVERBIN=q3ded \
      CLIENTBIN=quake3 \
      BUILD_RENDERER_OPENGL2=0 \
      USE_OPENAL=0 \
      USE_OPENAL_DLOPEN=0 \
      USE_CURL=0 \
      USE_CURL_DLOPEN=0 \
      USE_CODEC_VORBIS=0 \
      USE_CODEC_OPUS=0 \
      USE_MUMBLE=0 \
      USE_VOIP=0 \
      USE_FREETYPE=0 \
      USE_INTERNAL_LIBS=1 \
      USE_INTERNAL_JPEG=1 \
      USE_INTERNAL_SPEEX=1 \
      USE_INTERNAL_ZLIB=1 \
      USE_RENDERER_DLOPEN=0 \
      USE_LOCAL_HEADERS=0 \
      Q3LITE_INSTALL_SDL=0 \
      clean release
}

function install_q3lite() {
    local q3_bin
    if isPlatform "rpi"; then
        q3_bin="armv7l"
    elif isPlatform "vero4k"; then
        q3_bin="vero4k"
    fi

    md_ret_files=(
        "build/release-linux-$q3_bin/q3ded.$q3_bin"
        "build/release-linux-$q3_bin/quake3.$q3_bin"
        "build/release-linux-$q3_bin/renderer_opengles1_$q3_bin.so"
        )
}

function configure_q3lite() {
    local q3_bin
    if isPlatform "rpi"; then
        q3_bin="armv7l"
    elif isPlatform "vero4k"; then
        q3_bin="vero4k"
    fi

    cp "$md_data/q3lite.sh" "$md_inst"
    chmod +x "$md_inst/q3lite.sh"

    addPort "$md_id" \
      "q3lite" \
      "Quake III Arena" \
      "$md_inst/q3lite.sh __platform=$__platform md_inst=$md_inst q3_bin=$q3_bin home=$home romdir=$romdir"

    mkRomDir "ports/q3lite"

    moveConfigDir "$home/.q3a" "$md_conf_root/q3lite"

    if [[ "$md_mode" == "install" ]]; then
        ln -snf "$romdir/ports/q3lite/baseq3" "$md_conf_root/q3lite/baseq3"
        ln -snf "$romdir/ports/q3lite/missionpack" "$md_conf_root/q3lite/missionpack"
        gameDataQ3Lite || return 1
    fi
}

## @fn gameDataQ3Lite()
## @param none
## @brief scroll install the required pk3 files
## @retval 0 if data install failed/abandoned
## @retval 1 if data install successfull
function gameDataQ3Lite() {
    local paks_missing=0

    # check if paks are already installed
    for pak in pak{1..8}.pk3; do
        [[ -e $romdir/ports/q3lite/baseq3/$pak ]] || paks_missing=1
    done

    # do we replacing existing paks?
    if (( ! paks_missing )); then
        dialog \
          --title "Quake 3 .pk3 download" \
          --yes-label "Replace" \
          --no-label "Keep" \
          --yesno \
          "\nYou already have the *.pk3 files installed:\n\n  Do you want to KEEP them, or download REPLACEments?\n" \
          10 95 2>&1 >/dev/tty && paks_missing=1
    fi

    # pak download after acceptance of EULA
    (( paks_missing )) && eulaQ3Lite && paksQ3Lite || return 1

    # original game data request/advisory
    [[ ! -e $romdir/ports/q3lite/baseq3/pak0.pk3 ]] && dialog --msgbox "\nYou still need to copy your original pak0.pk3 file to:\n\n$romdir/ports/q3lite/baseq3/" 10 60 2>&1 >/dev/tty
}

## @fn eulaQ3Lite()
## @param none
## @brief scroll through EULA and confirm acceptance
## @retval 0 if EULA accepted
## @retval 1 if EULA rejected
function eulaQ3Lite() {
    local eula_file="$md_build/misc/q3lite/Q3A_EULA.txt"

    # load the EULA to an array after line wrapping, formatting and removing illegal/control characters
    local eula_doc[1]=''
    mapfile eula_doc < <(cat $eula_file | fold -s -w 70 | grep -o "[[:print:][:space:]]*" | sed '/^[0-9]\./i\\')
    local doc_len=${#eula_doc[*]}

    # present each page in turn with PREV/NEXT/FINISH buttons as appropriate
    local page_len=17
    local page_num=0
    local yes_label
    local dialog_type
    local dialog_next=0
    local dialog_prev=1

    while [[ ! $page_num -gt $(($doc_len / $page_len)) ]]; do

        if [[ $page_num -eq 0 ]]; then
            dialog_type='msgbox'
        elif [[ $page_num -eq $(($doc_len / $page_len)) ]]; then
            dialog_type='yesno'
            yes_label='Finished'
        else
            dialog_type='yesno'
            yes_label='Next Page'
        fi

        dialog \
          --title "End User License Agreement" \
          --yes-label "$yes_label" \
          --no-label "Prev Page" \
          --ok-label "Next Page" \
          --"$dialog_type" \
          " ${eula_doc[*]:$page_num*$page_len:$page_len}" \
          22 76 2>&1 >/dev/tty

        case "$?" in
            $dialog_next)
                ((page_num++))
                ;;
            $dialog_prev)
                ((page_num--))
                ;;
        esac
    done

    # test for agreement to the EULA and return
    sleep 2
    dialog --title "End User License Agreement" --yes-label "Accept" --no-label "Reject" --yesno "\nDo you accept the terms of the EULA?" 7 40 2>&1 >/dev/tty
    return $?
}

## @fn paksQ3Lite()
## @param none
## @brief download the 1.32b point release paks
## @retval 0 if downloads successfull
## @retval 1 if downloads failed
function paksQ3Lite() {
    local q3_pt_rel="linuxq3apoint-1.32b-3.x86.run"
    local sha256="c36132c5556b35e01950f1e9c646235033a5130f87ad776ba2bc7becf4f4f186"
    local url_list=(https://github.com/nrempel/q3-server/raw/master/$q3_pt_rel \
      ftp://ftp.idsoftware.com/idstuff/quake3/linux/$q3_pt_rel \
      http://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/$q3_pt_rel \
      ftp://ftp.filearena.net/.pub1/gentoo/distfiles/$q3_pt_rel \
      ftp://ftp.gamers.org/pub/idgames/idstuff/quake3/linux/$q3_pt_rel)

    # find a working pak source and download
    for url in ${url_list[@]}; do
        wget -t 2 --timeout=10 "$url" 2>&1 | \
        stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
        dialog --gauge " Downloading 1.32b point release from:\n$url" 7 120 2>&1 >/dev/tty

        # check integrity of downloads
        if [[ $? -eq 0 ]] && [[ -f "$q3_pt_rel" ]]; then
            if [[ "$sha256" = $(sha256sum "$q3_pt_rel" | cut -d" " -f1) ]]; then
                # Success! Decompress the paks into rom folder
                dialog --infobox "\n 1.32b Point Release sha256sum verified" 5 50 2>&1 >/dev/tty
                sleep 2
                tail -c +8252 "linuxq3apoint-1.32b-3.x86.run" | tar xzvf - -C "$romdir/ports/q3lite" \--wildcards "*.pk3" 2>&1
                return 0
            else
                dialog --infobox "\n Bad Point Release sha256sum: trying different URL..." 5 60 2>&1 >/dev/tty
                sleep 2
            fi
        else
            dialog --infobox "\n Download timed out: trying different URL..." 5 50 2>&1 >/dev/tty
            sleep 2
        fi

        if [[ -f "$q3_pt_rel" ]]; then
            rm -f "$q3_pt_rel"
        fi
    done

    dialog --msgbox "\n 1.32b Point Release download has failed.\n Try obtaining manually or try again later..." 8 50 2>&1 >/dev/tty
    return 1
}

