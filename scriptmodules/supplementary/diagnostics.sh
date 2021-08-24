#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="diagnostics"
rp_module_desc="Create diagnostic information for the running setup"
rp_module_section="core"
rp_module_flags=""

depends_diagnostics() {
    getDepends evemu-tools zip inxi
}

function _package_info_diagnostics() {
    local section
    for section in core main opt driver exp depends; do
        local id
        for id in $(rp_getSectionIds $section); do
            local type="${__mod_info[$id/vendor]}"
            if rp_isInstalled "$id"; then
                echo "== $id ($type) =="
                local pkg_info="$(rp_getInstallPath $id)/retropie.pkg"
                [[ -f "$pkg_info" ]] && cat "$pkg_info"
            fi
        done
    done
}

function gui_diagnostics() {
    local options
    local cmd
    local tmpdir
    local upload_dir=https://doctor.retropie.org.uk/
    local zipname=`openssl rand -hex 2 | tr [a-z] [A-Z]`_`date -u +"%Y-%m-%d"`.zip

    dialog --title "Diagnostic utility" --colors --yes-label "Run" --no-label "Cancel" --yesno "\nThis diagnostic utility will collect various information from your setup and pack it into a single file.\n\nThe information helps diagnose various issues and can by the RetroPie support team or support forums.\n\nAfter collecting the necessary data, you can choose to upload it to the RetroPie file sharing server or save it in order to upload it manually.\n\nPress \ZbRun\ZB and wait a few seconds for the diagnostics file to be generated." 20 60 2>&1 >/dev/tty || exit

    tmpdir="$(TMPDIR=/dev/shm mktemp -d)"
    _generate_diagnostics "$tmpdir" >/dev/null 2>&1
    pushd "$tmpdir"
    zip --quiet -r /dev/shm/$zipname .

    cmd=(dialog --backtitle "$__backtitle" --cancel-label "Exit" --no-label "Exit" --colors --menu "Diagnostics file created: \Zb$zipname\ZB\nChoose an option below:" 22 60 16)
    options=(
        1 "Upload the file to RetroPie support site"
        2 "Save the file in the '$home' folder"
        3 "Save the file in the 'roms' folder"
    )
    isPlatform "arm" && [[ -d /boot ]] && options+=(4 "Save the file in the 'boot' folder")

    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                local ret
                runCurl --silent --show-error -T "/dev/shm/$zipname" "$upload_dir" &>/dev/null
                ret="$?"
                if [[ "$ret" -eq 0 ]]; then
                    printMsgs "dialog" "File uploaded to $upload_dir$zipname.zip\n\nThe file will be deleted automatically in 2 days."
                else
                    printMsgs "dialog" "File could not be uploaded:\n\n$__NET_ERRMSG"
                fi
                ;;
            2)
                cp -f /dev/shm/$zipname "$home"
                printMsgs "dialog" "File $zipname saved in \n\n$home"
                ;;
            3)
                cp -f /dev/shm/$zipname "$romdir"
                printMsgs "dialog" "File $zipname saved in \n\n$romdir"
                ;;
            4)
                cp -f /dev/shm/$zipname "/boot"
                printMsgs "dialog" "File $zipname saved in \n\n/boot"
                ;;
        esac
     fi
     rm -fr "$tmpdir"
}

function _raspi_diagnostics() {
    cp /boot/config.txt config.txt
    cp /boot/cmdline.txt cmdline.txt
    cp /etc/rpi-issue rpi-issue.txt
    vcgencmd version > firmware_version.txt
    tvservice -s     > tvservice-status.txt
    (tvservice -m CEA && tvservice -m DMT) > tvservice-videomodes.txt

    # Get EDID info from HDMI, if connected
    (tvservice -l | grep HDMI) && tvservice -d hdmi-edid.dat

    # Get EEPROM config and info for PI4
    if isPlatform "rpi4"; then
        rpi-eeprom-update > rpi-eeprom-info.txt
        rpi-eeprom-config > rpi-eeprom-conf.txt
    fi
    # Get video info for KMS platforms
    isPlatform "kms" && "$rootdir/supplementary/mesa-drm/modetest" -r 2>/dev/null > drm-modetest-info.txt
}

function _audio_diagnostics() {
    [[ -f "$home/.asoundrc" ]] && cp "$home/.asoundrc" user_asoundrc.txt
    aplay -lL > aplay_output.txt
    if _pa_cmd_audiosettings systemctl -q --user is-enabled pulseaudio.socket; then
        pacmd list-sinks > pulseaudio.txt
    fi
}

function _retropie_diagnostics() {
    echo "RetroPie-Setup version: $__version ($(git -C "$scriptdir" log -1 --pretty=format:%h))" > version-git.txt
    echo "Origin: "                              >  git-info.txt
    git -C "$scriptdir" config remote.origin.url >> git-info.txt
    echo "Branches: "                            >> git-info.txt
    git -C "$scriptdir" branch -v                >> git-info.txt
    _package_info_diagnostics > packages.txt

    # Get the last 3 log files
    mkdir -p logs
    local log_file
    for log_file in `ls -tr1 "$scriptdir/logs/" | tail -n 3`; do
        cp "$scriptdir/logs/$log_file" logs/
    done

    # Add RetroPie specific configuration files
    mkdir -p config
    cp "$configdir/"all/{autoconf,backends,bluetooth,dispmanx,platforms,runcommand,splashscreen,videomodes}.cfg config/
    _filter_info_diagnostics "$configdir/all/autostart.sh" config/autostart.sh

}

function _input_diagnostics() {
    cat /proc/bus/input/devices > input_devices.txt
    local dev
    for dev in /dev/input/event*; do
        evemu-describe "$dev"        > "evemu-info-$(basename $dev).txt"
        udevadm info -q all "$dev"   > "udev-info-$(basename $dev).txt"
    done
}

function _system_diagnostics() {
    inxi --audio --repos --usb --machine --system --filter --admin -CSG -c 11 --tty > inxi_sysinfo.txt
    lsmod             > kernel-modules.txt
    cat /proc/cmdline > boot-cmdline.txt
    dpkg -l           > dpkg-info.txt
    dmesg | _filter_info_diagnostics - > dmesg-filtered.txt
}

function _es_diagnostics() {
    cp "$home/.emulationstation/"{es_settings,es_input}.cfg .
    head -n 12 "$home/.emulationstation/es_log.txt" > es_log_short.txt
}

function _bluetooth_diagnostics {
    rfkill list all > rfkill.txt
    hciconfig -a    > hciconfig.txt
    bt-device -l    > bt-devices.txt
    journalctl -u bluetooth --utc -o short > bluetooth-service-log.txt
    if isPlatform "rpi" ; then
        journalctl -u 'bthelper*' --utc -o short > bthelper-service-log.txt
    fi
}

function _emulator_diagnostics {
    _filter_info_diagnostics /dev/shm/runcommand.log > runcommand.log
    # Copy the main retroarch.cfg and each lr- system's config
    local dir
    mkdir retroarch
    while read config; do
        dir=${config%/*}
        dir=${dir//$configdir\//}
        cp -f "$configdir/$dir/retroarch.cfg" "retroarch/${dir}_retroarch.cfg"
    done < <(find "$configdir" -type f -regex ".*/retroarch.cfg" | sort)
    # Copy the joypad configuration profiles
    cp -af "$configdir/all/retroarch-joypads" .
    popd retroarch
}

function _generate_diagnostics() {
    local logdir="$1"
    local modules=(system es input retropie audio bluetooth emulator)
    isPlatform "rpi" && modules+=(raspi)
    isPlatform "odroid " && modules+=(odroid)
    isPlatform "x11" && modules+=(x11)

    [[ ! -d "$logdir" ]] && return 1
    export LC_ALL=C
    export TZ=UTC
    for module in ${modules[@]}; do
        if fnExists "_${module}_diagnostics"; then
            mkdir -p "$logdir/$module"
            pushd "$logdir/$module"
            "_${module}_diagnostics"
            popd
        fi
    done
    chown -R "$user" "$logdir"
}

function _filter_info_diagnostics() {
    local filters=(
        "s/([0-9]{1,3}\.){3}[0-9]{1,3}/<filter>/g;"   # IPv4 addresses
        "/attempting to login/d;"                     # RetroAchievements username
        )
    [[ "$user" != "pi" ]] && filters+=("s#/$user#/<filter>#g;")

    sed -E "${filters[*]}" "$1" 2>/dev/null
}
