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
__dependencies=()
__sources=()
__build=()
__install=()
__configure=()
__package=()
__doPackages=0

rootdir="/opt/retropie"
romdir="$home/RetroPie/roms"
if [[ ! -d $romdir ]]; then
    mkdir -p $romdir
fi

__ERRMSGS=""
__INFMSGS=""
__doReboot=0

__default_cflags="-O2 -pipe -mfpu=vfp -march=armv6j -mfloat-abi=hard"
__default_asflags=""
__default_gcc_version="4.7"

[[ -z "${CFLAGS}"        ]] && export CFLAGS="${__default_cflags}"
[[ -z "${CXXFLAGS}" ]] && export CXXFLAGS="${__default_cflags}"
[[ -z "${ASFLAGS}"         ]] && export ASFLAGS="${__default_asflags}"

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

function import() { 
    # @description importer routine to get external functionality.
    # @description the first location searched is the script directory.
    # @description if not found, search the module in the paths contained in $SHELL_LIBRARY_PATH environment variable
    # @param $1 the .shinc file to import, without .shinc extension
    module=$1

    if test "x$module" == "x"
    then
        echo "$script_name : Unable to import unspecified module. Dying."
        exit 1
    fi

    if test "x${script_absolute_dir:-notset}" == "xnotset"
    then
        echo "$script_name : Undefined script absolute dir. Did you remove getScriptAbsoluteDir? Dying."
        exit 1
    fi

    if test "x$script_absolute_dir" == "x"
    then
        echo "$script_name : empty script path. Dying."
        exit 1
    fi

    if test -e "$script_absolute_dir/$module.shinc"
    then
        # import from script directory
        . "$script_absolute_dir/$module.shinc"
        # echo "Loaded module $script_absolute_dir/$module.shinc"
        return
    elif test "x${SHELL_LIBRARY_PATH:-notset}" != "xnotset"
    then
        # import from the shell script library path
        # save the separator and use the ':' instead
        local saved_IFS="$IFS"
        IFS=':'
        for path in $SHELL_LIBRARY_PATH
        do
            if test -e "$path/$module.shinc"
            then
                . "$path/$module.shinc"
                return
            fi
        done
        # restore the standard separator
        IFS="$saved_IFS"
    fi
    echo "$script_name : Unable to find module $module."
    exit 1
}

function loadConfig() {
    # @description Routine for loading configuration files that contain key-value pairs in the format KEY="VALUE"
    # param  $1 Path to the configuration file relate to this file.
    local configfile=$1
    if test -e "$script_absolute_dir/$configfile"
    then
        . "$script_absolute_dir/$configfile"
        echo "Loaded configuration file $script_absolute_dir/$configfile"
        return
    else
        echo "Unable to find configuration file $script_absolute_dir/$configfile"
        exit 1
    fi
}

function rps_checkNeededPackages() {
    if [[ -z $(type -P git) || -z $(type -P dialog) ]]; then
        echo "Did not find needed packages 'git' and/or 'dialog'. I am trying to install these now."
        apt-get update
        apt-get install -y git dialog
        if [ $? == '0' ]; then
            echo "Successfully installed 'git' and/or 'dialog'."
        else
            echo "Could not install 'git' and/or 'dialog'. Aborting now."
            exit 1
        fi
    else
        echo "Found needed packages 'git' and 'dialog'."
    fi 
}

function rps_availFreeDiskSpace() {
    local __required=$1
    local __avail=`df -P $rootdir | tail -n1 | awk '{print $4}'`

    required_MB=`expr $__required / 1024`
    available_MB=`expr $__avail / 1024`

    if [[ "$__required" -le "$__avail" ]] || ask "Minimum recommended disk space ($required_MB MB) not available. Try 'sudo raspi-config' to resize partition to full size. Only $available_MB MB available at $rootdir continue anyway?"; then
        return 0;
    else
        exit 0;
    fi
}

# params: $1=ID, $2=description, $3=sources, $4=build, $5=install, $6=configure, $7=package
function rp_registerFunction() {
	__cmdid+=($1)
	__description[$1]=$2
    __dependencies[$1]=$3
	__sources[$1]=$4
	__build[$1]=$5
	__install[$1]=$6
	__configure[$1]=$7
	__package[$1]=$8
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
    echo -e "Alternatively, retropackages.sh can be called as\n./retropackages.sh <ID> [sources|build|install|configure|package]\n"
    echo -e "This is a list of valid commands:\n"
    rp_listFunctions
}

# -------------------------------------------------------------
rps_checkNeededPackages

user=$SUDO_USER
if [ -z "$user" ]
then
    user=$(whoami)
fi

# check, if sudo is used
if [ $(id -u) -ne 0 ]; then
    printf "Script must be run as root. Try 'sudo ./retropackages'\n"
    exit 1
fi   

scriptdir=`dirname $0`
scriptdir=`cd $scriptdir && pwd`

# load script modules
script_invoke_path="$0"
script_name=`basename "$0"`
getScriptAbsoluteDir "$script_invoke_path"
script_absolute_dir=$RESULT
home=$(eval echo ~$user)

import "scriptmodules/helpers"
import "scriptmodules/emulators"
import "scriptmodules/libretrocores"
import "scriptmodules/supplementary"

loadConfig "configs/retronetplay.cfg"

# ==========================================================================
# ==========================================================================

# register script functions
# rp_registerFunction "" "" "" "" "" "" ""

# Emulator components (emulators.shinc)
rp_registerFunction "100" "RetroArch                      " ""                       "sources_retroarch"       "build_retroarch"         "install_retroarch"         "configure_retroarch"        ""
rp_registerFunction "101" "AdvMame                        " "depen_advmame"          "sources_advmame"         "build_advmame"           "install_advmame"           "configure_advmame"          ""
rp_registerFunction "102" "Amiga emulator UAE4All         " ""                       "sources_uae4all"         "build_uae4all"           "install_uae4all"           "configure_uae4all"          ""
rp_registerFunction "103" "Atari 800 emulator             " ""                       "sources_atari800"        "build_atari800"          "install_atari800"          "configure_atari800"         ""
rp_registerFunction "104" "Armstrad CPC emulator          " ""                       "sources_cpc"             "build_cpc"               ""                          "configure_cpc"              ""
rp_registerFunction "105" "DOS Emulator Dosbox            " ""                       ""                        ""                        "install_dosbox"            "configure_dosbox"           ""
rp_registerFunction "106" "Atari2600 emulator STELLA      " ""                       ""                        ""                        "install_stella"            "configure_stella"           ""
rp_registerFunction "107" "Macintosh emulator             " ""                       "sources_basilisk"        "build_basilisk"          "install_basilisk"          "configure_basilisk"         ""
rp_registerFunction "108" "C64 emulator VICE              " ""                       "sources_vice"            "build_vice"              "install_vice"              "configure_vice"             ""
rp_registerFunction "109" "C64 ROMs                       " ""                       ""                        ""                        "install_c64roms"           ""                           ""
rp_registerFunction "110" "Duke3D Port                    " ""                       ""                        ""                        "install_eduke32"           ""                           ""
rp_registerFunction "111" "GameBoy Advance emulator       " ""                       "sources_gpsp"            "build_gpsp"              ""                          "configure_gpsp"             ""
rp_registerFunction "112" "NeoGeo emulator GnGeoPi        " ""                       "sources_gngeopi"         "build_gngeopi"           "install_gngeopi"           "configure_gngeopi"          ""
rp_registerFunction "113" "Atari emulator Hatari          " ""                       ""                        ""                        "install_hatari"            ""                           ""
rp_registerFunction "114" "MAME emulator MAME4All-Pi      " ""                       "sources_mame4all"        "build_mame4all"          ""                          "configure_mame4all"         ""
rp_registerFunction "115" "Gamegear emulator Osmose       " ""                       "sources_osmose"          "build_osmose"            "install_osmose"            "configure_osmose"           ""
rp_registerFunction "116" "Intellivision emulator         " ""                       "sources_jzint"           "build_jzint"             ""                          "configure_jzint"            ""
rp_registerFunction "117" "Apple 2 emulator Linapple      " ""                       "sources_linapple"        "build_linapple"          ""                          "configure_linapple"         ""
rp_registerFunction "118" "N64 emulator MUPEN64Plus-RPi   " ""                       "sources_mupen64rpi"      "build_mupen64rpi"        ""                          "configure_mupen64rpi"       ""
rp_registerFunction "119" "SNES emulator SNES9X-RPi       " "depen_snes9x"           "sources_snes9x"          "build_snes9x"            ""                          "configure_snes9x"           ""
rp_registerFunction "120" "FBA emulator PiFBA             " ""                       "sources_pifba"           "build_pifba"             "install_pifba"             "configure_pifba"            ""
rp_registerFunction "121" "SNES emulator PiSNES           " ""                       "sources_pisnes"          "build_pisnes"            ""                          "configure_pisnes"           ""
rp_registerFunction "122" "DOS Emulator rpix86            " ""                       ""                        ""                        "install_rpix86"            "configure_rpix86"           ""
rp_registerFunction "123" "ScummVM                        " ""                       ""                        ""                        "install_scummvm"           ""                           ""
rp_registerFunction "124" "ZMachine                       " ""                       ""                        ""                        "install_zmachine"          ""                           ""
rp_registerFunction "125" "ZXSpectrum emulator Fuse       " ""                       ""                        ""                        "install_zxspectrum"        ""                           ""
rp_registerFunction "126" "ZXSpectrum emulator FBZX       " ""                       "sources_fbzx"            "build_fbzx"              ""                          ""                           ""
rp_registerFunction "127" "MSX emulator OpenMSX           " "depen_msx"              "sources_openmsx"         "build_openmsx"           ""                          "configure_openmsx"          ""
rp_registerFunction "128" "DOS emulator FastDosbox        " ""                       "sources_fastdosbox"      "build_fastdosbox"        "install_fastdosbox"        ""                           ""

# LibretroCore components (libretrocores.shinc)
rp_registerFunction "200" "SNES LibretroCore PocketSNES   " ""                       "sources_pocketsnes"       "build_pocketsnes"       ""                          "configure_pocketsnes"       ""
rp_registerFunction "201" "Genesis LibretroCore Picodrive " ""                       "sources_picodrive"        "build_picodrive"        "install_picodrive"         "configure_picodrive"        ""
rp_registerFunction "202" "Atari 2600 LibretroCore Stella " ""                       "sources_stellalibretro"   "build_stellalibretro"   ""                          "configure_stellalibretro"   ""
rp_registerFunction "203" "Cave Story LibretroCore        " ""                       "sources_cavestory"        "build_cavestory"        ""                          "configure_cavestory"        ""
rp_registerFunction "204" "Doom LibretroCore              " ""                       "sources_doom"             "build_doom"             ""                          "configure_doom"             ""
rp_registerFunction "205" "Gameboy Color LibretroCore     " ""                       "sources_gbclibretro"      "build_gbclibretro"      ""                          "configure_gbclibretro"      ""
rp_registerFunction "206" "MAME LibretroCore              " ""                       "sources_mamelibretro"     "build_mamelibretro"     ""                          "configure_mamelibretro"     ""
rp_registerFunction "207" "FBA LibretroCore               " "depen_fbalibretro"      "sources_fbalibretro"      "build_fbalibretro"      ""                          "configure_fbalibretro"      ""
rp_registerFunction "208" "NES LibretroCore fceu-next     " ""                       "sources_neslibretro"      "build_neslibretro"      ""                          "configure_neslibretro"      ""
rp_registerFunction "209" "Genesis/Megadrive LibretroCore " ""                       "sources_genesislibretro"  "build_genesislibretro"  ""                          "configure_genesislibretro"  ""
rp_registerFunction "210" "TurboGrafx 16 LibretroCore     " ""                       "sources_turbografx16"     "build_turbografx16"     ""                          "configure_turbografx16"     ""
rp_registerFunction "211" "Playstation 1 LibretroCore     " ""                       "sources_psxlibretro"      "build_psxlibretro"      ""                          "configure_psxlibretro"      ""

# Supplementary components (supplementary.shinc)
rp_registerFunction "300" "Update APT packages            " ""                       ""                         ""                       "install_APTPackages"       ""                           ""
rp_registerFunction "301" "Package Repository             " ""                       ""                         ""                       "install_PackageRepository" ""                           ""
rp_registerFunction "302" "SDL 2.0.1                      " "depen_sdl"              "sources_sdl"              "build_sdl"              "install_sdl"               ""                           ""
rp_registerFunction "303" "EmulationStation               " "depen_emulationstation" "sources_EmulationStation" "build_EmulationStation" "install_EmulationStation"  "configure_EmulationStation" "package_EmulationStation"
rp_registerFunction "304" "EmulationStation Theme Simple  " ""                       ""                         ""                       "install_ESThemeSimple"     ""                           ""
rp_registerFunction "305" "Video mode script 'runcommand' " ""                       ""                         ""                       "install_runcommand"        ""                           ""
rp_registerFunction "306" "SNESDev                        " ""                       "sources_snesdev"          "build_snesdev"          "install_snesdev"           "configure_snesdev"          ""
rp_registerFunction "307" "Xarcade2Jstick                 " ""                       "sources_xarcade2jstick"   "build_xarcade2jstick"   "install_xarcade2jstick"    "configure_xarcade2jstick"   ""
rp_registerFunction "308" "RetroArch-AutoConfigs          " ""                       ""                         ""                       "install_retroarchautoconf" ""                           ""
rp_registerFunction "309" "Bash Welcome Tweak             " ""                       ""                         ""                       "install_bashwelcometweak"  ""                           ""
rp_registerFunction "310" "Samba ROM Shares               " ""                       ""                         ""                       "install_sambashares"       "configure_sambashares"      ""
rp_registerFunction "311" "USB ROM Service                " ""                       ""                         ""                       "install_usbromservice"     "configure_usbromservice"    ""
rp_registerFunction "312" "Enable/disable Splashscreen    " ""                       ""                         ""                       ""                          "configure_splashenable"     ""
rp_registerFunction "313" "Select Splashscreen            " ""                       ""                         ""                       ""                          "configure_splashscreen"     ""
rp_registerFunction "314" "RetroNetplay                   " ""                       ""                         ""                       ""                          "configure_retronetplay"     ""
rp_registerFunction "315" "Modules UInput, Joydev, ALSA   " ""                       ""                         ""                       "install_modules"           ""                           ""
rp_registerFunction "316" "Set avoid_safe_mode            " ""                       ""                         ""                       "install_setavoidsafemode"  ""                           ""
rp_registerFunction "317" "Disable system timeouts        " ""                       ""                         ""                       "install_disabletimeouts"   ""                           ""
rp_registerFunction "318" "Handle APT packages            " ""                       ""                         ""                       "install_handleaptpackages" ""                           ""
rp_registerFunction "319" "Auto-start EmulationStation    " ""                       ""                         ""                       ""                          "configure_autostartemustat" ""
rp_registerFunction "320" "Install XBox contr. 360 driver " ""                       ""                         ""                       "set_install_xboxdrv"       ""                           ""
rp_registerFunction "321" "Install PS3 controller driver  " ""                       ""                         ""                       "set_installps3controller"  ""                           ""
rp_registerFunction "322" "Register RetroArch controller  " ""                       ""                         ""                       "set_RetroarchJoyconfig"    ""                           ""
rp_registerFunction "323" "Install SDL 2.0.1 binaries     " ""                       ""                         ""                       "install_libsdlbinaries"    ""                           "" 
rp_registerFunction "324" "Configure audio settings       " ""                       ""                         ""                       ""                          "configure_audiosettings"    "" 

# TODO python scripts (es-config)

# ==========================================================================
# ==========================================================================


# ID mode
if [[ $# -eq 1 ]]; then
    ensureRootdirExists
	id=$1
    fn_exists ${__dependencies[$id]} && ${__dependencies[$id]}
    fn_exists ${__sources[$id]} && ${__sources[$id]}
	fn_exists ${__build[$id]} && ${__build[$id]}
	fn_exists ${__install[$id]} && ${__install[$id]}
	fn_exists ${__configure[$id]} && ${__configure[$id]}
	# fn_exists ${__package[$id]} && ${__package[$id]} packages are not built automatically
elif [[ $# -eq 2 ]]; then
    ensureRootdirExists
    id=$1
    if [ "$2" == "dependencies" ]; then
        fn_exists ${__dependencies[$id]} && ${__dependencies[$id]}
    fi
    if [ "$2" == "sources" ]; then
        fn_exists ${__sources[$id]} && ${__sources[$id]}
    fi
    if [ "$2" == "build" ]; then
        fn_exists ${__build[$id]} && ${__build[$id]}
    fi
    if [ "$2" == "install" ]; then
        fn_exists ${__install[$id]} && ${__install[$id]}
    fi
    if [ "$2" == "configure" ]; then
        fn_exists ${__configure[$id]} && ${__configure[$id]}
    fi
    if [ "$2" == "install" ]; then
        fn_exists ${__package[$id]} && ${__package[$id]}
    fi
else
    rp_printUsageinfo
fi
