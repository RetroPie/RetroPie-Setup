#!/bin/bash

IFS=';'

# Welcome
 dialog --backtitle "RetroPie Reference" --title "RetroPie Reference Utility Menu" \
    --yesno "\nThis utility provides common information about Retropie including information about Emulation Station, Retroarch, and ROM information.\n\nThis is a quick reference for the common items used.\n\nFor the most up-to-date information, visit the official RetroPie Wiki page for more information.\n\nDo you wish to continue?" \
    15 80 2>&1 > /dev/tty \
    || exit

function main_menu() {
    local choice

    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "What would you like to get information about?" 25 75 20 \
            1 "Emulation Station" \
            2 "RetroArch" \
            3 "Emulator and ROM information" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) emulationstation  ;;
            2) retroarch  ;;
            3) emulatorinfo  ;;
            *)  break ;;
        esac
    done
}

function emulationstation() {
dialog --infobox "...processing..." 3 20 ; sleep 2
infobox=""
infobox="${infobox}___________________________________________________________________________\n\n"
infobox="${infobox}\n"
infobox="${infobox}Emulation Station Common Assignments\n\n"
infobox="${infobox}DPAD          navigation\n"
infobox="${infobox}START         menu\n"
infobox="${infobox}SELECT        options\n"
infobox="${infobox}A BUTTON      select\n"
infobox="${infobox}B BUTTON      back\n"
infobox="${infobox}Y BUTTON      add to favorites\n"
infobox="${infobox}\n"
infobox="${infobox}You can easily change themes by pressing START > UI SETTINGS and scrolling down to the theme selection item.\n"
infobox="${infobox}\n"
infobox="${infobox}More themes are available to download by launching the RetroPie menu \"ES THEMES\" application.\n"

dialog --backtitle "Emulation Station Information" \
--title "Emulation Station Information" \
--msgbox "${infobox}" 30 80
}

function retroarch() {
dialog --infobox "...processing..." 3 20 ; sleep 2
infobox=""
infobox="${infobox}___________________________________________________________________________\n\n"
infobox="${infobox}\n"
infobox="${infobox}RetroArch Default Common Assignments\n\n"
infobox="${infobox}SELECT                 hotkey\n"
infobox="${infobox}SELECT+X               RGUI menu\n"
infobox="${infobox}SELECT+B               reset game\n"
infobox="${infobox}SELECT+START           exit game\n"
infobox="${infobox}SELECT+RIGHT SHOULDER  save game\n"
infobox="${infobox}SELECT+LEFT SHOULDER   load game\n"
infobox="${infobox}SELECT+RIGHT           input state slot increase\n"
infobox="${infobox}SELECT+LEFT            input state slot decrease\n"
infobox="${infobox}\n"

dialog --backtitle "RetroArch Information" \
--title "RetroArch Information" \
--msgbox "${infobox}" 25 80
}


function emulatorinfo() {
    local choice

    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "Which system would you like information on??" 25 75 20 \
            1 "Amstrad CPC" \
            2 "Apple II" \
            3 "Arcade" \
            4 "Atari 2600" \
            5 "Atari 5200" \
            6 "Atari 7800 ProSystem" \
            7 "Atari 800" \
            8 "Atari Lynx" \
            9 "Atari ST" \
            10 "Bandai Wonderswan" \
            11 "Bandai Wonderswan Color" \
            12 "ColecoVision" \
            13 "Commodore 64" \
            14 "Commodore Amiga" \
            15 "Commodore Amiga CD32" \
            16 "Daphne" \
            17 "Dragon 32" \
            18 "Final Burn Alpha" \
            19 "GCE Vectrex" \
            20 "Magnavox Odyssey" \
            21 "MAME Advance" \
            22 "MAME Libretro" \
            23 "MAME Mame4All" \
            24 "Mattel Intellivision" \
            25 "Microsoft MSX" \
            26 "Microsoft MSX2" \
            27 "NEC PC Engine" \
            28 "NEC PC Engine-CD" \
            29 "NEC SuperGrafx" \
            30 "NEC TurboGrafx 16" \
            31 "NEC TurboGrafx 16-CD" \
            32 "Nintendo 64" \
            33 "Nintendo DS" \
            34 "Nintendo Entertainment System" \
            35 "Nintendo Famicom Disk System" \
            36 "Nintendo Famicom System" \
            37 "Nintendo Game and Watch" \
            38 "Nintendo Game Boy" \
            39 "Nintendo Game Boy Advance" \
            40 "Nintendo Game Boy Color" \
            41 "Nintendo Super Famicom Disk System" \
            42 "Nintendo Virtual Boy" \
            43 "PC" \
            44 "ResidualVM" \
            45 "RetroPie" \
            46 "ScummVM" \
            47 "Sega 32X" \
            48 "Sega CD" \
            49 "Sega Dreamcast" \
            50 "Sega Gamegear" \
            51 "Sega Master System" \
            52 "Sega Mega Drive" \
            53 "Sega Mega Drive Japan" \
            54 "Sega SG-1000" \
            55 "Sharp X68000" \
            56 "Sinclair ZX Spectrum" \
            57 "SNK Neo Geo" \
            58 "SNK Neo Geo Pocket" \
            59 "SNK Neo Geo Pocket Color" \
            60 "Sony PlayStation" \
            61 "Sony PlayStation Portable" \
            62 "Sony PlayStation Portable Minis" \
            63 "Super Nintendo" \
            64 "Super Nintendo MSU-1" \
            65 "Tandy TRS-80" \
            66 "Tandy TRS-80 Color Computer" \
            67 "Tangerine Oric 1" \
            68 "Texas Instruments TI99/4A" \
            69 "Z-machine Infocom" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) show_detail "Amstrad CPC"   ;;
            2) show_detail "Apple II"   ;;
            3) show_detail "Arcade"   ;;
            4) show_detail "Atari 2600"   ;;
            5) show_detail "Atari 5200"   ;;
            6) show_detail "Atari 7800 ProSystem"   ;;
            7) show_detail "Atari 800"   ;;
            8) show_detail "Atari Lynx"   ;;
            9) show_detail "Atari ST"   ;;
            10) show_detail "Bandai Wonderswan"   ;;
            11) show_detail "Bandai Wonderswan Color"   ;;
            12) show_detail "ColecoVision"   ;;
            13) show_detail "Commodore 64"   ;;
            14) show_detail "Commodore Amiga"   ;;
            15) show_detail "Commodore Amiga CD32"   ;;
            16) show_detail "Daphne"   ;;
            17) show_detail "Dragon 32"   ;;
            18) show_detail "Final Burn Alpha"   ;;
            19) show_detail "GCE Vectrex"   ;;
            20) show_detail "Magnavox Odyssey"   ;;
            21) show_detail "MAME Advance"   ;;
            22) show_detail "MAME Libretro"   ;;
            23) show_detail "MAME Mame4All"   ;;
            24) show_detail "Mattel Intellivision"   ;;
            25) show_detail "Microsoft MSX"   ;;
            26) show_detail "Microsoft MSX2"   ;;
            27) show_detail "NEC PC Engine"   ;;
            28) show_detail "NEC PC Engine-CD"   ;;
            29) show_detail "NEC SuperGrafx"   ;;
            30) show_detail "NEC TurboGrafx 16"   ;;
            31) show_detail "NEC TurboGrafx 16-CD"   ;;
            32) show_detail "Nintendo 64"   ;;
            33) show_detail "Nintendo DS"   ;;
            34) show_detail "Nintendo Entertainment System"   ;;
            35) show_detail "Nintendo Famicom Disk System"   ;;
            36) show_detail "Nintendo Famicom System"   ;;
            37) show_detail "Nintendo Game and Watch"   ;;
            38) show_detail "Nintendo Game Boy"   ;;
            39) show_detail "Nintendo Game Boy Advance"   ;;
            40) show_detail "Nintendo Game Boy Color"   ;;
            41) show_detail "Nintendo Super Famicom Disk System"   ;;
            42) show_detail "Nintendo Virtual Boy"   ;;
            43) show_detail "PC"   ;;
            44) show_detail "ResidualVM"   ;;
            45) show_detail "RetroPie"   ;;
            46) show_detail "ScummVM"   ;;
            47) show_detail "Sega 32X"   ;;
            48) show_detail "Sega CD"   ;;
            49) show_detail "Sega Dreamcast"   ;;
            50) show_detail "Sega Gamegear"   ;;
            51) show_detail "Sega Master System"   ;;
            52) show_detail "Sega Mega Drive"   ;;
            53) show_detail "Sega Mega Drive Japan"   ;;
            54) show_detail "Sega SG-1000"   ;;
            55) show_detail "Sharp X68000"   ;;
            56) show_detail "Sinclair ZX Spectrum"   ;;
            57) show_detail "SNK Neo Geo"   ;;
            58) show_detail "SNK Neo Geo Pocket"   ;;
            59) show_detail "SNK Neo Geo Pocket Color"   ;;
            60) show_detail "Sony PlayStation"   ;;
            61) show_detail "Sony PlayStation Portable"   ;;
            62) show_detail "Sony PlayStation Portable Minis"   ;;
            63) show_detail "Super Nintendo"   ;;
            64) show_detail "Super Nintendo MSU-1"   ;;
            65) show_detail "Tandy TRS-80"   ;;
            66) show_detail "Tandy TRS-80 Color Computer"   ;;
            67) show_detail "Tangerine Oric 1"   ;;
            68) show_detail "Texas Instruments TI99/4A"   ;;
            69) show_detail "Z-machine Infocom"   ;;
            *)  break ;;
        esac
    done

}

function show_detail() {
dialog --infobox "...processing..." 3 20 ; sleep 2
system="${1}"
romsdir=`cat /home/pigaming/RetroPie/retropiemenu/emulator.info |grep "${system};" |cut -f2 -d ";"`
fileext=`cat /home/pigaming/RetroPie/retropiemenu/emulator.info |grep "${system};" |cut -f3 -d ";"`
emus=`cat /home/pigaming/RetroPie/retropiemenu/emulator.info |grep "${system};" |cut -f4 -d ";"`
bios=`cat /home/pigaming/RetroPie/retropiemenu/emulator.info |grep "${system};" |cut -f5 -d ";"`
bioslocation=`cat /home/pigaming/RetroPie/retropiemenu/emulator.info |grep "${system};" |cut -f6 -d ";"`
emus="$(echo "${emus}" | sed 's/,/\\n/g')"
bios="$(echo "${bios}" | sed 's/,/\\n/g')"
bioslocation="$(echo "${bioslocation}" | sed 's/,/\\n/g')"
infobox=""
infobox="${infobox}___________________________________________________________________________\n\n"
infobox="${infobox}\n"
infobox="${infobox}System:        ${system}\n\n"
infobox="${infobox}ROMS folder:   /home/pigaming/RetroPie/roms/${romsdir}\n\n"
infobox="${infobox}Emulators:     \n${emus}\n\n"
infobox="${infobox}BIOS file(s):  \n${bios}\n\n"
infobox="${infobox}BIOS location: \n${bioslocation}\n\n"
infobox="${infobox}ROM file extensions:\n${fileext}\n\n"

dialog --backtitle "RetroPie Emulator Information Utility" \
--title "RetroPie Emulator Information" \
--msgbox "${infobox}" 30 80
}


# Main

main_menu
