#!/bin/bash

# starttype==1: set video mode to VGA ONLY IF tvservice is in HDMI mode, and run command
# starttype==2: keep existing video mode and run command
# starttype==3: set video mode to VGA and run command
# starttype==4: set video mode to 720p60 ONLY IF tvservice is in HDMI mode and run command
# starttype==5: set video mode to 576p50 ONLY IF tvservice is in HDMI mode and run command
# starttype==6: set video mode to 720p50 ONLY IF tvservice is in HDMI mode and run command
# starttype==7: set video mode to sdtv PAL and run command
# starttype==8: set video mode to sdtv NTSC and run command


starttype=$1
shift

# set cpu governor profile performance 
echo "performance" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

if [[ $starttype -eq 1 && ! -z `tvservice -m CEA | egrep -w "mode 1"` ]] || [[ $starttype -eq 3 ]]; then
	tvservice -e "CEA 1"
   	fbset -depth 8 && fbset -depth 16
#	fbset -rgba 5,6,5
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 2 ]]; then
    eval $@
elif [[ $starttype -eq 4 && ! -z `tvservice -m CEA | egrep -w "mode 4"` ]]; then
	tvservice -e "CEA 4"
   	fbset -depth 8 && fbset -depth 16
#	fbset -rgba 5,6,5
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 5 && ! -z `tvservice -m CEA | egrep -w "mode 17"` ]]; then
	tvservice -e "CEA 17"
   	fbset -depth 8 && fbset -depth 16
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 6 && ! -z `tvservice -m CEA | egrep -w "mode 19"` ]]; then
	tvservice -e "CEA 19"
   	fbset -depth 8 && fbset -depth 16
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 7 ]]; then
	tvservice -c "PAL 4:3"
   	fbset -depth 8 && fbset -depth 16
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 8 ]]; then
	tvservice -c "NTSC 4:3"
   	fbset -depth 8 && fbset -depth 16
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
else
	eval $@
fi

# set cpu governor profile ondemand 
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

exit 0
