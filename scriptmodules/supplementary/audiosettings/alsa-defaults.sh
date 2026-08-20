#!/bin/sh

# Sets the default ALSA audio card to the 1st vc4-hdmi device found
# The ALSA configuration is written to '/etc/alsa/conf.d/99-retropie.conf'

CONF_FILE=/etc/alsa/conf.d/99-retropie.conf

# test if we don't already have the audio configured
if [ -f "$CONF_FILE" ]; then
    echo RetroPie audio card configuration already present, skipping configuration
    exit 0
fi

# test if we have any `vc4-hdmi` cards present, otherwise exit
card_index="$(grep vc4hdmi /proc/asound/cards | cut -d' ' -f 2 | head -n1)"
card_name="$(cat /proc/asound/card"${card_index}"/id)"
if [ -z "$card_index" ]; then
    echo No vc4-hdmi audio devices present, skipping configuration
fi

echo "Found a vc4-hdmi sound card on slot $card_index, configuring it"

tmpfile="$(mktemp)"
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
mv -f "$tmpfile" "$CONF_FILE" || {
    echo "Failed to save configuration file $CONF_FILE!"
    exit 1
}
chmod 0644 "$CONF_FILE"
echo "ALSA configuration saved in $CONF_FILE"
