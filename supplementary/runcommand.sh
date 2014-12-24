#!/bin/bash

# starttype==1: set video mode to VGA ONLY IF tvservice is in HDMI mode, and run command
# starttype==2: keep existing video mode and run command
# starttype==3: set video mode to VGA and run command
# starttype==4: set video mode to 720p60 ONLY IF tvservice is in HDMI mode and run command
# starttype==5: set video mode to 576p50 ONLY IF tvservice is in HDMI mode and run command
# starttype==6: set video mode to 720p50 ONLY IF tvservice is in HDMI mode and run command
# starttype==7: set video mode to sdtv PAL and run command
# starttype==8: set video mode to sdtv NTSC and run command

dispmanx_conf="/opt/retropie/configs/all/dispmanx"

starttype=$1
shift

# set cpu governor profile performance
echo "performance" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

command="$@"
binary="`basename ${1/% */}`"
# if we have a dispmanx conf file and the current binary is in it (as a variable) and set to 1, change the library path to load dispmanx sdl first
if [ -f "$dispmanx_conf" ]; then
  source "$dispmanx_conf"
  [ ${!binary} -eq 1 ] && command="LD_LIBRARY_PATH=/opt/retropie/supplementary/sdl1dispmanx/lib $@"
fi

if [[ $starttype -eq 1 && ! -z `tvservice -m CEA | egrep -w "mode 1"` ]] || [[ $starttype -eq 3 ]]; then
    tvservice -e "CEA 1"
    fbset -depth 8 && fbset -depth 16
#   fbset -rgba 5,6,5
    eval $command
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 2 ]]; then
    eval $command
elif [[ $starttype -eq 4 && ! -z `tvservice -m CEA | egrep -w "mode 4"` ]]; then
    tvservice -e "CEA 4"
    fbset -depth 8 && fbset -depth 16
#   fbset -rgba 5,6,5
    eval $command
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 5 && ! -z `tvservice -m CEA | egrep -w "mode 17"` ]]; then
    tvservice -e "CEA 17"
    fbset -depth 8 && fbset -depth 16
    eval $command
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 6 && ! -z `tvservice -m CEA | egrep -w "mode 19"` ]]; then
    tvservice -e "CEA 19"
    fbset -depth 8 && fbset -depth 16
    eval $command
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 7 ]]; then
    tvservice -c "PAL 4:3"
    fbset -depth 8 && fbset -depth 16
    eval $command
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 8 ]]; then
    tvservice -c "NTSC 4:3"
    fbset -depth 8 && fbset -depth 16
    eval $command
    tvservice -p
    fbset -depth 8 && fbset -depth 16
else
    eval $command
fi

# set cpu governor profile ondemand
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

exit 0
