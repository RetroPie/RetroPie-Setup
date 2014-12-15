#!/bin/bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi
#  with RetroArch, various cores, and EmulationStation (a graphical
#  front end).
#
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
#
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
#
#  Permission to use, copy, modify and distribute RetroPie-Setup in both binary and
#  source form, for non-commercial purposes, is hereby granted without fee,
#  providing that this license information and copyright notice appear with
#  all copies and any derived work.
#
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event shall the authors be held liable for any damages
#  arising from the use of this software.
#
#  RetroPie-Setup is freeware for PERSONAL USE only. Commercial users should
#  seek permission of the copyright holders first. Commercial use includes
#  charging money for RetroPie-Setup or software derived from RetroPie-Setup.
#
#  The copyright holders request that bug fixes and improvements to the code
#  should be forwarded to them so everyone can benefit from the modifications
#  in future versions.
#
#  Many, many thanks go to all people that provide the individual packages!!!
#
#  Raspberry Pi is a trademark of the Raspberry Pi Foundation.
#

pushd "/opt"

rootdir="./retropie"

filelist=()

filelist+=("$rootdir/supplementary/emulationstation")
filelist+=("$rootdir/supplementary/snesdev")
filelist+=("$rootdir/emulators")
filelist+=("$rootdir/libretrocores")

echo "Checking, if all directories/files exist"
tLen=${#filelist[@]}
doAbort=0
for (( i=0; i<${tLen}; i++ ));
do
    if [[ ! -d "${filelist[$i]}" && ! -f "${filelist[$i]}" ]]
    then
      echo "Cannot find directory ${filelist[$i]}."
      doAbort=1
    fi
done

if [[ $doAbort -eq 1 ]]; then
    exit
fi

echo "Creating the archive file"
tar -c -vf /home/pi/RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]} --exclude-vcs --exclude="*.o"

for (( i=1; i<${tLen}; i++ ));
do
    tar -r -vf /home/pi/RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]} --exclude-vcs --exclude="*.o"
done

echo "Compressing the archive file"
bzip2 /home/pi/RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."

popd
