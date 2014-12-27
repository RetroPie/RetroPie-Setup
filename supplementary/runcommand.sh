#!/bin/bash

# reqmode==0: run command
# reqmode==1: set video mode to 640x480 (4:3) or 720x480 (16:9) @60hz, and run command
# reqmode==4: set video mode to 1024x768 (4:3) or 1280x720 (16:9) @60hz, and run command

# reqmode=="CEA-#": set video mode to CEA mode #
# reqmode=="DMT-#": set video mode to DMT mode #
# reqmode=="PAL/NTSC-RATIO": set mode to SD output with RATIO of 4:3 / 16:10 or 16:9

# note that mode switching only happens if the monitor reports the modes as available (via tvservice)
# and the requested mode differs from the currently active mode

reqmode="$1"
[[ -z "$reqmode" ]] && exit 1
shift

command="$@"
[[ -z "$command" ]] && exit 1

# get current mode / aspect ratio
status=$(tvservice -s)
currentmode=$(echo "$status" | grep -oE "(CEA|DMT) \([0-9]+\)")
currentmode=${currentmode/\(/}
currentmode=${currentmode/\)/}
aspect=$(echo "$status" | grep -oE "(16:9|4:3)")

declare -A mode
sd=0
switch=0

mode[1-4:3]="CEA 1"
mode[1-16:9]="CEA 1"
mode[4-16:9]="CEA 4"
mode[4-4:3]="DMT 16"

# if user provided a specific mode, then let's try and use that else use a mode from our array
if [[ "$reqmode" =~ ^(DMT|CEA)-[0-9]+$ ]]; then
    newmode=(${reqmode//-/ })
elif [[ "$reqmode" =~ ^(PAL|NTSC)-(4:3|16:10|16:9)$ ]]; then
    newmode=(${reqmode//-/ })
    sd=1
else
    newmode=(${mode[${reqmode}-${aspect}]})
fi

# if we have a new mode and it is different from the current mode then switch
if [ "$newmode" != "" ] && [ "${newmode[*]}" != "$currentmode" ]; then
    if [ $sd -eq 1 ]; then
        tvservice -c "${newmode[*]}"
        switch=1
    else
        hasmode=$(tvservice -m ${newmode[0]} | grep -w "mode ${newmode[1]}")
        if [ "${newmode[*]}" != "" ] && [ "$hasmode" != "" ]; then
            tvservice -e "${newmode[*]}"
            switch=1
        fi
    fi
fi

# if we have a dispmanx conf file and the current binary is in it (as a variable) and set to 1,
# change the library path to load dispmanx sdl first
dispmanx_conf="/opt/retropie/configs/all/dispmanx"
binary="`basename ${1/% */}`"
if [ -f "$dispmanx_conf" ]; then
  source "$dispmanx_conf"
  [ "${!binary}" = "1" ] && command="LD_LIBRARY_PATH=/opt/retropie/supplementary/sdl1dispmanx/lib $@"
fi

# if we switched mode - delay 1 sec, then reset framebuffer
if [ $switch -eq 1 ]; then
  sleep 1
  fbset -depth 8 && fbset -depth 16
fi

# switch to performance cpu governor
echo "performance" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >/dev/null

# run command
eval $command

# switch to ondemand cpu governor
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >/dev/null

# if we switched mode - restore preferred mode, delay 1 sec and reset framebuffer
if [ $switch -eq 1 ]; then
    tvservice -p
    sleep 1
    fbset -depth 8 && fbset -depth 16
fi

exit 0