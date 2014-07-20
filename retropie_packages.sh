#!/usr/bin/env bash

#
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
#
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
#
#  Permission to use, copy, modify and distribute this work in both binary and
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

# global variables ==========================================================

__cmdid=()
__description=()
__menus=()
__dependencies=()
__sources=()
__build=()
__install=()
__configure=()
__package=()
__doPackages=0

rootdir="/opt/retropie"
user=$SUDO_USER
if [ -z "$user" ]
then
    user=$(whoami)
fi
home=$(eval echo ~$user)
romdir="$home/RetroPie/roms"
if [[ ! -d $romdir ]]; then
    mkdir -p $romdir
fi

__ERRMSGS=""
__INFMSGS=""
__doReboot=0

__default_cflags="-O2 -pipe -mfpu=vfp -march=armv6j -mfloat-abi=hard"
__default_asflags=""
__default_makeflags=""
__default_gcc_version="4.7"

[[ -z "${CFLAGS}"        ]] && export CFLAGS="${__default_cflags}"
[[ -z "${CXXFLAGS}" ]] && export CXXFLAGS="${__default_cflags}"
[[ -z "${ASFLAGS}"         ]] && export ASFLAGS="${__default_asflags}"
[[ -z "${MAKEFLAGS}" ]] && export MAKEFLAGS="${__default_makeflags}"

# check, if sudo is used
if [ $(id -u) -ne 0 ]; then
    printf "Script must be run as root. Try 'sudo $0'\n"
    exit 1
fi

# test if we are in a chroot
if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
  # make chroot identify as arm6l
  export QEMU_CPU=arm1176
  __chroot=1
else
  __chroot=0
fi


# ==============================================================================

function getScriptAbsoluteDir() {
    # @description used to get the script path
    # @param $1 the script $0 parameter
    local script_invoke_path="$1"
    local cwd=`pwd`

    # absolute path ? if so, the first character is a /
    if test "x${script_invoke_path:0:1}" = 'x/'
    then
        RESULT=`dirname "$script_invoke_path"`
    else
        RESULT=`dirname "$cwd/$script_invoke_path"`
    fi
}

function loadConfig() {
    # @description Routine for loading configuration files that contain key-value pairs in the format KEY="VALUE"
    # param  $1 Path to the configuration file relate to this file.
    local configfile=$1
    if test -e "$script_absolute_dir/$configfile"
    then
        . "$script_absolute_dir/$configfile"
        # echo "Loaded configuration file $script_absolute_dir/$configfile"
        return
    else
        echo "Unable to find configuration file $script_absolute_dir/$configfile"
        exit 1
    fi
}

# params: $1=ID, $2=description, $3=sources, $4=build, $5=install, $6=configure, $7=package
function rp_registerFunction() {
    __cmdid+=($1)
    __description[$1]=$2
    __menus[$1]=$3
    __dependencies[$1]=$4
    __sources[$1]=$5
    __build[$1]=$6
    __install[$1]=$7
    __configure[$1]=$8
    __package[$1]=$9
}

function rp_listFunctions() {
    local id

    echo -e "Command-ID: Description:\tList of available actions [sources|build|install|configure|package]"
    echo "--------------------------------------------------"
    for (( i = 0; i < ${#__cmdid[@]}; i++ )); do
        id=${__cmdid[$i]};
        echo -e "$id:\t${__description[$id]}:\t\c"
        fn_exists ${__dependencies[$id]} && echo -e "dependencies \c"
        fn_exists ${__sources[$id]} && echo -e "sources \c"
        fn_exists ${__build[$id]} && echo -e "build \c"
        fn_exists ${__install[$id]} && echo -e "install \c"
        fn_exists ${__configure[$id]} && echo -e "configure \c"
        fn_exists ${__package[$id]} && echo -e "package \c"
        echo ""
    done
    echo "=================================================="
}

function rp_printUsageinfo() {
    echo -e "Usage:\n$0 <ID1> [<ID2> ... <IDN>] [sources|build|install|configure|package]\nThis will run the actions sources, build, install, configure, and package automatically.\n"
    echo -e "Alternatively, $0 can be called as\n$0 <ID> [sources|build|install|configure|package]\n"
    echo -e "This is a list of valid commands:\n"
    rp_listFunctions
}

function rp_callFunction() {
    local __desc
    local __function=__$2[$1]
    case $2 in
        dependencies)
            __desc="Installing dependencies for"
            ;;
        sources)
            __desc="Getting sources for"
            ;;
        build)
            __desc="Building"
            ;;
        install)
            __desc="Installing"
            ;;
        configure)
            __desc="Configuring"
            ;;
    esac
    # echo "Checking, if function ${!__function} exists"
    fn_exists ${!__function} || return
    # echo "Printing function name"
    printMsg "$__desc ${__description[$1]}"
    # echo "Executing function"
    ${!__function}
}

function registerFunctions() {
    # register script functions

    # Emulator components (emulators.shinc)
    rp_registerFunction "100" "RetroArch                      " "2+"                          "depen_retroarch"        "sources_retroarch"       "build_retroarch"         "install_retroarch"         "configure_retroarch"        ""
    rp_registerFunction "101" "AdvMame                        " "2+"                          "depen_advmame"          "sources_advmame"         "build_advmame"           "install_advmame"           "configure_advmame"          ""
    rp_registerFunction "102" "Amiga emulator UAE4All         " "2+"                          ""                       "sources_uae4all"         "build_uae4all"           "install_uae4all"           "configure_uae4all"          ""
    rp_registerFunction "103" "Atari 800 emulator             " "2+"                          ""                       "sources_atari800"        "build_atari800"          "install_atari800"          "configure_atari800"         ""
    rp_registerFunction "104" "Armstrad CPC emulator          " "2+"                          ""                       "sources_cpc"             "build_cpc"               ""                          "configure_cpc"              ""
    rp_registerFunction "105" "DOS Emulator Dosbox            " "2+"                          ""                       ""                        ""                        "install_dosbox"            "configure_dosbox"           ""
    rp_registerFunction "106" "Atari2600 emulator STELLA      " "2+"                          ""                       ""                        ""                        "install_stella"            "configure_stella"           ""
    rp_registerFunction "107" "Macintosh emulator             " "2+"                          ""                       "sources_basilisk"        "build_basilisk"          "install_basilisk"          "configure_basilisk"         ""
    rp_registerFunction "108" "C64 emulator VICE              " "2+"                          ""                       "sources_vice"            "build_vice"              "install_vice"              "configure_vice"             ""
    rp_registerFunction "109" "C64 ROMs                       " "2+"                          ""                       ""                        ""                        "install_c64roms"           ""                           ""
    rp_registerFunction "110" "Duke3D Port                    " "2+"                          ""                       ""                        ""                        "install_eduke32"           ""                           ""
    rp_registerFunction "111" "GameBoy Advance emulator       " "2+"                          ""                       "sources_gpsp"            "build_gpsp"              ""                          "configure_gpsp"             ""
    rp_registerFunction "112" "NeoGeo emulator GnGeoPi        " "2+"                          ""                       "sources_gngeopi"         "build_gngeopi"           "install_gngeopi"           "configure_gngeopi"          ""
    rp_registerFunction "113" "Atari emulator Hatari          " "2+"                          ""                       ""                        ""                        "install_hatari"            ""                           ""
    rp_registerFunction "114" "MAME emulator MAME4All-Pi      " "2+"                          ""                       "sources_mame4all"        "build_mame4all"          ""                          "configure_mame4all"         ""
    rp_registerFunction "115" "Gamegear emulator Osmose       " "2+"                          ""                       "sources_osmose"          "build_osmose"            "install_osmose"            "configure_osmose"           ""
    rp_registerFunction "116" "Intellivision emulator         " "2+"                          ""                       "sources_jzint"           "build_jzint"             ""                          "configure_jzint"            ""
    rp_registerFunction "117" "Apple 2 emulator Linapple      " "2+"                          "depen_linapple"         "sources_linapple"        "build_linapple"          ""                          "configure_linapple"         ""
    rp_registerFunction "118" "N64 emulator MUPEN64Plus-RPi   " "2+"                          ""                       "sources_mupen64rpi"      "build_mupen64rpi"        ""                          "configure_mupen64rpi"       ""
    rp_registerFunction "119" "SNES emulator SNES9X-RPi       " "2+"                          "depen_snes9x"           "sources_snes9x"          "build_snes9x"            ""                          "configure_snes9x"           ""
    rp_registerFunction "120" "FBA emulator PiFBA             " "2+"                          ""                       "sources_pifba"           "build_pifba"             "install_pifba"             "configure_pifba"            ""
    rp_registerFunction "121" "SNES emulator PiSNES           " "2+"                          ""                       "sources_pisnes"          "build_pisnes"            ""                          "configure_pisnes"           ""
    rp_registerFunction "122" "DOS Emulator rpix86            " "2+"                          ""                       ""                        ""                        "install_rpix86"            "configure_rpix86"           ""
    rp_registerFunction "123" "ScummVM                        " "2+"                          ""                       ""                        ""                        "install_scummvm"           ""                           ""
    rp_registerFunction "124" "ZMachine                       " "2+"                          ""                       ""                        ""                        "install_zmachine"          ""                           ""
    rp_registerFunction "125" "ZXSpectrum emulator Fuse       " "2+"                          ""                       ""                        ""                        "install_zxspectrum"        ""                           ""
    rp_registerFunction "126" "ZXSpectrum emulator FBZX       " "2+"                          ""                       "sources_fbzx"            "build_fbzx"              ""                          ""                           ""
    rp_registerFunction "127" "MSX emulator OpenMSX           " "2+"                          "depen_msx"              "sources_openmsx"         "build_openmsx"           ""                          "configure_openmsx"          ""
    rp_registerFunction "128" "DOS emulator FastDosbox        " "2+"                          ""                       "sources_fastdosbox"      "build_fastdosbox"        "install_fastdosbox"        ""                           ""
    rp_registerFunction "129" "Megadrive/Genesis emulat. DGEN " "2+"                          ""                       "sources_dgen"            "build_dgen"              "install_dgen"              "configure_dgen"             ""

    # LibretroCore components (libretrocores.shinc)
    rp_registerFunction "200" "SNES LibretroCore PocketSNES   " "2+"                          ""                       "sources_pocketsnes"       "build_pocketsnes"       ""                          "configure_pocketsnes"       ""
    rp_registerFunction "201" "Genesis LibretroCore Picodrive " "2+"                          ""                       "sources_picodrive"        "build_picodrive"        "install_picodrive"         "configure_picodrive"        ""
    rp_registerFunction "202" "Atari 2600 LibretroCore Stella " "2+"                          ""                       "sources_stellalibretro"   "build_stellalibretro"   ""                          "configure_stellalibretro"   ""
    rp_registerFunction "203" "Cave Story LibretroCore        " "2+"                          ""                       "sources_cavestory"        "build_cavestory"        ""                          "configure_cavestory"        ""
    rp_registerFunction "204" "Doom LibretroCore              " "2+"                          ""                       "sources_doom"             "build_doom"             ""                          "configure_doom"             ""
    rp_registerFunction "205" "Gameboy Color LibretroCore     " "2+"                          ""                       "sources_gbclibretro"      "build_gbclibretro"      ""                          "configure_gbclibretro"      ""
    rp_registerFunction "206" "MAME LibretroCore              " "2+"                          ""                       "sources_mamelibretro"     "build_mamelibretro"     ""                          "configure_mamelibretro"     ""
    rp_registerFunction "207" "FBA LibretroCore               " "2+"                          "depen_fbalibretro"      "sources_fbalibretro"      "build_fbalibretro"      ""                          "configure_fbalibretro"      ""
    rp_registerFunction "208" "NES LibretroCore fceu-next     " "2+"                          ""                       "sources_neslibretro"      "build_neslibretro"      ""                          "configure_neslibretro"      ""
    rp_registerFunction "209" "Genesis/Megadrive LibretroCore " "2+"                          ""                       "sources_genesislibretro"  "build_genesislibretro"  ""                          "configure_genesislibretro"  ""
    rp_registerFunction "210" "TurboGrafx 16 LibretroCore     " "2+"                          ""                       "sources_turbografx16"     "build_turbografx16"     ""                          "configure_turbografx16"     ""
    rp_registerFunction "211" "Playstation 1 LibretroCore     " "2+"                          ""                       "sources_psxlibretro"      "build_psxlibretro"      ""                          "configure_psxlibretro"      ""
    rp_registerFunction "212" "Mednafen PCE Fast LibretroCore " "2+"                          ""                       "sources_mednafenpcefast"  "build_mednafenpcefast"  ""                          "configure_mednafenpcefast"  ""

    # Supplementary components (supplementary.shinc)
    rp_registerFunction "300" "Update APT packages            " "2+"                          ""                       ""                         ""                       "install_APTPackages"       ""                           ""
    rp_registerFunction "301" "Package Repository             " "2+"                          ""                       ""                         ""                       "install_PackageRepository" ""                           ""
    rp_registerFunction "302" "SDL 2.0.1                      " "2+"                          "depen_sdl"              "sources_sdl"              "build_sdl"              "install_sdl"               ""                           ""
    rp_registerFunction "303" "EmulationStation               " "2+"                          "depen_emulationstation" "sources_EmulationStation" "build_EmulationStation" "install_EmulationStation"  "configure_EmulationStation" "package_EmulationStation"
    rp_registerFunction "304" "EmulationStation Theme Simple  " "2+"                          ""                       ""                         ""                       "install_ESThemeSimple"     ""                           ""
    rp_registerFunction "305" "Video mode script 'runcommand' " "2+"                          ""                       ""                         ""                       "install_runcommand"        ""                           ""
    rp_registerFunction "306" "SNESDev                        " "3+configure"                 ""                       "sources_snesdev"          "build_snesdev"          "install_snesdev"           "configure_snesdev"          ""
    rp_registerFunction "307" "Xarcade2Jstick                 " "3+configure"                 ""                       "sources_xarcade2jstick"   "build_xarcade2jstick"   "install_xarcade2jstick"    "configure_xarcade2jstick"   ""
    rp_registerFunction "308" "RetroArch-AutoConfigs          " "2+"                          ""                       ""                         ""                       "install_retroarchautoconf" ""                           ""
    rp_registerFunction "309" "Bash Welcome Tweak             " "2+"                          ""                       ""                         ""                       "install_bashwelcometweak"  ""                           ""
    rp_registerFunction "310" "Samba ROM Shares               " "3+"                          ""                       ""                         ""                       "install_sambashares"       "configure_sambashares"      ""
    rp_registerFunction "311" "USB ROM Service                " "3+"                          ""                       ""                         ""                       "install_usbromservice"     "configure_usbromservice"    ""
    rp_registerFunction "312" "Enable/disable Splashscreen    " "3+"                          ""                       ""                         ""                       ""                          "configure_splashenable"     ""
    rp_registerFunction "313" "Select Splashscreen            " "3+"                          ""                       ""                         ""                       ""                          "configure_splashscreen"     ""
    rp_registerFunction "314" "RetroNetplay                   " "3+"                          ""                       ""                         ""                       ""                          "configure_retronetplay"     ""
    rp_registerFunction "315" "Modules UInput, Joydev, ALSA   " "2+"                          ""                       ""                         ""                       "install_modules"           ""                           ""
    rp_registerFunction "316" "Set avoid_safe_mode            " "2+"                          ""                       ""                         ""                       "install_setavoidsafemode"  ""                           ""
    rp_registerFunction "317" "Disable system timeouts        " "2+"                          ""                       ""                         ""                       "install_disabletimeouts"   ""                           ""
    rp_registerFunction "318" "Handle APT packages            " "2+"                          ""                       ""                         ""                       "install_handleaptpackages" ""                           ""
    rp_registerFunction "319" "Auto-start EmulationStation    " "3+"                          ""                       ""                         ""                       ""                          "configure_autostartemustat" ""
    rp_registerFunction "320" "Install XBox contr. 360 driver " "3+"                          ""                       ""                         ""                       "set_install_xboxdrv"       ""                           ""
    rp_registerFunction "321" "Install PS3 controller driver  " "3+"                          ""                       ""                         ""                       "set_installps3controller"  ""                           ""
    rp_registerFunction "322" "Register RetroArch controller  " "3+"                          ""                       ""                         ""                       "set_RetroarchJoyconfig"    ""                           ""
    rp_registerFunction "323" "Install SDL 2.0.1 binaries     " "2-"                          ""                       ""                         ""                       "install_libsdlbinaries"    ""                           ""
    rp_registerFunction "324" "Configure audio settings       " "3+"                          ""                       ""                         ""                       ""                          "configure_audiosettings"    ""
    rp_registerFunction "325" "ES-Config                      " "3+"                          ""                       ""                         ""                       "install_esconfig"          "configure_esconfig"         ""
    rp_registerFunction "326" "Gamecon driver                 " "3+install"                   ""                       ""                         ""                       "install_gamecondriver"     "configure_gamecondriver"    ""

}

# TODO python scripts (es-config)

# -------------------------------------------------------------

registerFunctions

scriptdir=$(dirname $0)
scriptdir=$(cd $scriptdir && pwd)

# load script modules
script_invoke_path="$0"
script_name=`basename "$0"`
getScriptAbsoluteDir "$script_invoke_path"
script_absolute_dir=$RESULT

source "scriptmodules/helpers.shinc"
source "scriptmodules/emulators.shinc"
source "scriptmodules/libretrocores.shinc"
source "scriptmodules/supplementary.shinc"

rps_checkNeededPackages git dialog gcc-4.7 g++-4.7

# set default gcc version
gcc_version $__default_gcc_version

[[ "$1" == "init" ]] && return

loadConfig "configs/retronetplay.cfg"

# ID scriptmode
if [[ $# -eq 1 ]]; then
    ensureRootdirExists
    id=$1
    for scriptmode in dependencies sources build install configure; do
        rp_callFunction $id $scriptmode
    done

# ID Type mode
elif [[ $# -eq 2 ]]; then
    ensureRootdirExists
    rp_callFunction $1 $2

# show usage information
else
    rp_printUsageinfo
fi

if [[ ! -z $__ERRMSGS ]]; then
    echo $__ERRMSGS >&2
fi

if [[ ! -z $__INFMSGS ]]; then
    echo $__INFMSGS
fi

