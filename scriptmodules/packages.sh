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
    local desc

    echo -e "Command-ID: Description:\tList of available actions [sources|build|install|configure|package]"
    echo "--------------------------------------------------"
    for (( i = 0; i < ${#__cmdid[@]}; i++ )); do
        id=${__cmdid[$i]};
        desc=$(printf "%-32s" "${__description[$id]}")
        echo -e "$id:\t$desc:\t\c"
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

function registerModule() {
    local module_idx="$1"
    local module_path="$2"
    local rp_module_id=""
    local rp_module_desc=""
    local rp_module_menus=""
    local var
    local error=0
    source $module_path
    for var in rp_module_id rp_module_desc rp_module_menus; do
        if [[ "${!var}" == "" ]]; then
            echo "Module $module_path is missing valid $var"
            error=1
        fi
    done
    [[ $error -eq 1 ]] && exit 1
    rp_registerFunction "$module_idx" "$rp_module_desc" "$rp_module_menus" \
        "depen_$rp_module_id" \
        "sources_$rp_module_id" \
        "build_$rp_module_id" \
        "install_$rp_module_id" \
        "configure_$rp_module_id" \
        "package_$rp_module_id"
}

function registerModuleDir() {
    local module_idx="$1"
    local module_dir="$2"
    for module in `find "$scriptdir/scriptmodules/$2" -maxdepth 1 -name "*.sh" | sort`; do
        registerModule $module_idx "$module"
        ((module_idx++))
    done
}

function registerAllModules() {
    registerModuleDir 100 "emulators" 
    registerModuleDir 200 "libretrocores" 
    #registerModuleDir 300 "supplementary"
}


function registerFunctions() {
    # register script functions

    # Supplementary components (supplementary.sh)
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