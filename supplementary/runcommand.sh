#!/bin/bash

# starttype==1: set video mode to VGA and run command
# starttype==2: keep existing video mode and run command
starttype=$1
shift

if [[ $starttype -eq 1 ]]; then
   	tvservice -e "CEA 1"
   	fbset -depth 8 && fbset -depth 16
    eval $@
    tvservice -p
    fbset -depth 8 && fbset -depth 16
elif [[ $starttype -eq 2 ]]; then
    eval $@
fi
