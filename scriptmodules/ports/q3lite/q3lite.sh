#!/bin/bash

# parse input for Retropie variables as key=value pairs
for arg  do
    set -- $(echo $arg | tr '=' ' ')
    key=$1
    value=$2

    case "$key" in
        __platform)
            __platform=$value
            ;;
        md_inst)
            md_inst=$value
            ;;
        q3_bin)
            q3_bin=$value
            ;;
        home)
            home=$value
            ;;
        romdir)
            romdir=$value
            ;;
    esac
done

# check that the user installed pak0.pk3 is present
if [[ -e "$romdir/ports/q3lite/baseq3/pak0.pk3" ]]; then
    # launch q3lite with the best configuration for the platform
    # these can be refined with user feedback
    case "$__platform" in
        rpi*)
            $md_inst/quake3.$q3_bin +set com_hunkMegs 192 +set com_zoneMegs 24 +set com_soundMegs 16 +set fs_homepath $home/.q3a +set vm_ui 2 +set vm_cgame 2 +set com_protocol 68
            ;;
        vero4k)
            $md_inst/quake3.$q3_bin +set com_hunkMegs 256 +set com_zoneMegs 48 +set com_soundMegs 32 +set fs_homepath $home/.q3a +set vm_ui 2 +set vm_cgame 2 +set com_protocol 68
            ;;
        *)
            $md_inst/quake3.$q3_bin +set com_hunkMegs 192 +set com_zoneMegs 24 +set com_soundMegs 16 +set fs_homepath $home/.q3a +set vm_ui 2 +set vm_cgame 2 +set com_protocol 68
            ;;
    esac
else
    dialog  --title "Q3lite runtime error!" --infobox "\nYou still need to copy your original pak0.pk3 file to:\n\n$romdir/ports/q3lite/baseq3/\n\nQuiting in 10s" 10 60 2>&1 >/dev/tty
    sleep 10
fi
