#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="audiosettings"
rp_module_desc="Configure audio settings"
rp_module_section="config"
rp_module_flags="!all rpi"

function depends_audiosettings() {
    if [[ "$md_mode" == "install" ]]; then
        getDepends alsa-utils
    fi
}

function gui_audiosettings() {
    # Check if the internal audio is enabled
    if [[ `aplay -ql | grep bcm2835 | wc -l` < 1 ]]; then
        printMsgs "dialog" "On-board audio disabled or not present"
        return
    fi

    # The list of ALSA cards/devices depends on the 'snd-bcm2385' module parameter 'enable_compat_alsa'
    # * enable_compat_alsa: true  - single soundcard, output is routed based on the `numid` control
    # * enable_compat_alsa: false - one soundcard per output type (HDMI/Headphones)
    # If PulseAudio is enabled, then try to configure it and leave ALSA alone
    if _pa_cmd_audiosettings systemctl -q --user is-enabled pulseaudio.socket; then
        _pulseaudio_audiosettings
    elif aplay -l | grep -q "bcm2835 ALSA"; then
        _bcm2835_alsa_compat_audiosettings
    else
        _bcm2835_alsa_internal_audiosettings
    fi
}

function _bcm2835_alsa_compat_audiosettings() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Set audio output (ALSA - compat)" 22 86 16)
    local hdmi="HDMI"

    # the Pi 4 has 2 HDMI ports, so number them
    isPlatform "rpi4" && hdmi="HDMI 1"

    local options=(
        1 "Auto"
        2 "Headphones - 3.5mm jack"
        3 "$hdmi"
    )
    # add 2nd HDMI port on the Pi4
    isPlatform "rpi4" && options+=(4 "HDMI 2")
    options+=(
        M "Mixer - adjust output volume"
        R "Reset to default"
    )
    # If PulseAudio is installed, add an option to enable it
    hasPackage "pulseaudio" && options+=(P "Enable PulseAudio")

    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                amixer cset numid=3 0
                alsactl store
                printMsgs "dialog" "Set audio output to Auto"
                ;;
            2)
                amixer cset numid=3 1
                alsactl store
                printMsgs "dialog" "Set audio output to Headphones - 3.5mm jack"
                ;;
            3)
                amixer cset numid=3 2
                alsactl store
                printMsgs "dialog" "Set audio output to $hdmi"
                ;;
            4)
                amixer cset numid=3 3
                alsactl store
                printMsgs "dialog" "Set audio output to HDMI 2"
                ;;
            M)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                /etc/init.d/alsa-utils reset
                alsactl store
                rm -f "$home/.asoundrc"
                printMsgs "dialog" "Audio settings reset to defaults"
                ;;
            P)
                _toggle_pulseaudio_audiosettings "on"
                printMsgs "dialog" "PulseAudio enabled"
                ;;
        esac
    fi
}

function _bcm2835_alsa_internal_audiosettings() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Set audio output (ALSA)" 22 86 16)
    local options=()
    local card_index
    local card_label

    # Get the list of Pi internal cards
    while read card_no card_label; do
        options+=("$card_no" "$card_label")
    done < <(aplay -ql | sed -En -e '/^card/ {s/^card ([0-9]+).*\[(bcm2835 |vc4-)([^]]*)\].*/\1 \3/; s/hdmi[- ]?/HDMI /i; p}')
    options+=(
        M "Mixer - adjust output volume"
        R "Reset to default"
    )

    # If PulseAudio is installed, add an option to enable it
    hasPackage "pulseaudio" && options+=(P "Enable PulseAudio")

    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            [0-9])
                _asoundrc_save_audiosettings $choice ${options[$((choice*2+1))]}
                printMsgs "dialog" "Set audio output to ${options[$((choice*2+1))]}"
                ;;
            M)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                /etc/init.d/alsa-utils reset
                alsactl store
                rm -f "$home/.asoundrc"
                printMsgs "dialog" "Audio settings reset to defaults"
                ;;
            P)
                _toggle_pulseaudio_audiosettings "on"
                printMsgs "dialog" "PulseAudio enabled"
                ;;
        esac
    fi
}

# configure the default ALSA soundcard based on chosen card index and type
function _asoundrc_save_audiosettings() {
    [[ -z "$1" ]] && return

    local card_index=$1
    local card_type=$2
    local tmpfile="$(mktemp)"

    if isPlatform "kms" && ! isPlatform "dispmanx" && [[ $card_type == "HDMI"* ]]; then
        # when the 'vc4hdmi' driver is used instead of 'bcm2835_audio' for HDMI,
        # the 'hdmi:vchdmi[-idx]' PCM should be used for converting to the native IEC958 codec
        # adds a volume control since the default configured mixer doesn't work
        # (default configuration is at /usr/share/alsa/cards/vc4-hdmi.conf)
        local card_name="$(cat /proc/asound/card${card_index}/id)"
        cat << EOF > "$tmpfile"
pcm.hdmi${card_index} {
  type asym
  playback.pcm {
    type plug
    slave.pcm "hdmi:${card_name}"
  }
}
ctl.!default {
  type hw
  card $card_index
}
pcm.softvolume {
    type           softvol
    slave.pcm      "hdmi${card_index}"
    control.name  "HDMI Playback Volume"
    control.card  ${card_index}
}

pcm.softmute {
    type softvol
    slave.pcm "softvolume"
    control.name "HDMI Playback Switch"
    control.card ${card_index}
    resolution 2
}

pcm.!default {
    type plug
    slave.pcm "softmute"
}
EOF
    else
    cat << EOF > "$tmpfile"
pcm.!default {
  type asym
  playback.pcm {
    type plug
    slave.pcm "output"
  }
}
pcm.output {
  type hw
  card $card_index
}
ctl.!default {
  type hw
  card $card_index
}
EOF
    fi

    mv "$tmpfile" "$home/.asoundrc"
    chown "$user:$user" "$home/.asoundrc"
}

function _pulseaudio_audiosettings() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Set audio output (PulseAudio)" 22 86 16)
    local options=()
    local sink_index
    local sink_label

    # Check if PulseAudio is running, otherwise 'pacmd' will not work
    if ! _pa_cmd_audiosettings pacmd stat>/dev/null; then
        printMsgs "dialog" "PulseAudio is enabled, but not running\nAudio settings cannot be set right now"
        return
    fi
    while read sink_index sink_label; do
        options+=("$sink_index" "$sink_label")
    done < <(_pa_cmd_audiosettings pacmd list-sinks | \
            awk -F [:=] '/index/ { idx=$2;
                         do {getline} while($0 !~ "alsa.name");
                         gsub(/"|bcm2835[^a-zA-Z]+/, "", $2);
                         print idx,$2 }'
            )

    options+=(
        M "Mixer - adjust output volume"
        R "Reset to default"
        P "Disable PulseAudio"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            [0-9])
                _pa_cmd_audiosettings pactl set-default-sink $choice
                rm -f "$home/.asoundrc"
                printMsgs "dialog" "Set audio output to ${options[$((choice*2+1))]}"
                ;;
            M)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                rm -fr "$home/.config/pulse"
                /etc/init.d/alsa-utils reset
                alsactl store
                printMsgs "dialog" "Audio settings reset to defaults"
                ;;
            P)
                _toggle_pulseaudio_audiosettings "off"
                printMsgs "dialog" "PulseAudio disabled"
                ;;
        esac
    fi
}

function _toggle_pulseaudio_audiosettings() {
    local state=$1

    if [[ "$state" == "on" ]]; then
        _pa_cmd_audiosettings systemctl --user unmask pulseaudio.socket
        _pa_cmd_audiosettings systemctl --user start  pulseaudio.service
    fi

    if [[ "$state" == "off" ]]; then
        _pa_cmd_audiosettings systemctl --user mask pulseaudio.socket
        _pa_cmd_audiosettings systemctl --user stop pulseaudio.service
    fi
}

# Run PulseAudio commands as the calling user
function _pa_cmd_audiosettings() {
    [[ -n "$@" ]] && sudo -u "$user" XDG_RUNTIME_DIR=/run/user/$SUDO_UID "$@" 2>/dev/null
}
