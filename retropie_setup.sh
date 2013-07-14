#!/bin/bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi 
#  with RetroArch, various cores, and EmulationStation (a graphical 
#  front end).
# 
#  (c) Copyright 2012  Florian Müller (petrockblock@gmail.com)
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

__ERRMSGS=""
__INFMSGS=""
__doReboot=0

# HELPER FUNCTIONS ###

function ask()
{   
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function addLineToFile()
{
    if [[ -f "$2" ]]; then
        cp "$2" ./temp
        sudo mv "$2" "$2.old"
    fi
    echo "$1" >> ./temp
    sudo mv ./temp "$2"
    echo "Added $1 to file $2"
}

# arg 1: key, arg 2: value, arg 3: file
# make sure that a key-value pair is set in file
# key = value
function ensureKeyValue()
{
    if [[ -z $(egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "$1 = ""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3`
        sed $3 -i -e "s|$toreplace|$1 = ""$2""|g"
    fi     
}

# make sure that a key-value pair is NOT set in file
# # key = value
function disableKeyValue()
{
    if [[ -z $(egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "# $1 = ""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1 = ""?[+|-]?[0-9]*[a-z]*"""? $3`
        sed $3 -i -e "s|$toreplace|# $1 = ""$2""|g"
    fi     
}

# arg 1: key, arg 2: value, arg 3: file
# make sure that a key-value pair is set in file
# key=value
function ensureKeyValueShort()
{
    if [[ -z $(egrep -i "#? *$1\s?=\s?""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "$1=""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1\s?=\s?""?[+|-]?[0-9]*[a-z]*"""? $3`
        sed $3 -i -e "s|$toreplace|$1=""$2""|g"
    fi     
}

# make sure that a key-value pair is NOT set in file
# # key=value
function disableKeyValueShort()
{
    if [[ -z $(egrep -i "#? *$1=""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "# $1=""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1=""?[+|-]?[0-9]*[a-z]*"""? $3`
        sed $3 -i -e "s|$toreplace|# $1=""$2""|g"
    fi     
}

# ensures pair of key ($1)-value ($2) in file $3
function ensureKeyValueBootconfig()
{
    if [[ -z $(egrep -i "#? *$1=[+|-]?[0-9]*[a-z]*" $3) ]]; then
        # add key-value pair
        echo "$1=$2" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1=[+|-]?[0-9]*[a-z]*" $3`
        sed $3 -i -e "s|$toreplace|$1=$2|g"
    fi     
}

function printMsg()
{
    echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$1\n= = = = = = = = = = = = = = = = = = = = =\n"
}

function rel2abs() {
  cd "$(dirname $1)" && dir="$PWD"
  file="$(basename $1)"

  echo $dir/$file
}

function checkForInstalledAPTPackage()
{
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
    echo Checking for somelib: $PKG_OK
    if [ "" == "$PKG_OK" ]; then
        echo "NOT INSTALLED: $1"
    else
        echo "installed: $1"
    fi    
}

function checkFileExistence()
{
    if [[ -f "$1" ]]; then
        ls -lh "$1" >> "$rootdir/debug.log"
    else
        echo "$1 does NOT exist." >> "$rootdir/debug.log"
    fi
}

# clones or updates the sources of a repository $2 into the directory $1
function gitPullOrClone()
{
    if [[ -d "$1/.git" ]]; then
        pushd "$1"
        git pull
    else
        rm -rf "$1" # makes sure that the directory IS empty
        mkdir -p "$1"
        git clone --depth=0 "$2" "$1"
        pushd "$1"
    fi
}

# END HELPER FUNCTIONS ###

function availFreeDiskSpace()
{
    local __required=$1
    local __avail=`df -P $rootdir | tail -n1 | awk '{print $4}'`

    if [[ "$__required" -le "$__avail" ]] || ask "Minimum recommended disk space (500 MB) not available. Try 'sudo raspi-config' to resize partition to full size. Only $__avail available at $rootdir continue anyway?"; then
        return 0;
    else
        exit 0;
    fi
}

function install_rpiupdate()
{
    # install latest rpi-update script (to enable firmware update)
    printMsg "Installing latest rpi-update script"
    # make sure that certificates are installed
    apt-get install -y ca-certificates
    wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
}

function run_rpiupdate()
{
    printMsg "Starting rpi-update script"
    /usr/bin/rpi-update
    __doReboot=1
    chmod 777 /dev/fb0
    ensureKeyValueShort "gpu_mem" "128" "/boot/config.txt"
}

# update APT repositories
function update_apt() 
{
    printMsg "Updating APT-GET database"
    apt-get -y update
}

# upgrade APT packages
function upgrade_apt()
{
    printMsg "Performing APT-GET upgrade"
    apt-get -y upgrade
    chmod 777 /dev/fb0
    ensureKeyValueShort "gpu_mem" "128" "/boot/config.txt"
}

# add user $user to groups "video", "audio", and "input"
function add_to_groups()
{
    printMsg "Adding user $user to groups video, audio, and input."
    add_user_to_group $user video
    add_user_to_group $user audio
    add_user_to_group $user input
}

# add user $1 to group $2, create the group if it doesn't exist
function add_user_to_group()
{
    if [ -z $(egrep -i "^$2" /etc/group) ]
    then
      sudo addgroup $2
    fi
    sudo adduser $1 $2
}

# make sure ALSA, uinput, and joydev modules are active
function ensure_modules()
{
    printMsg "Enabling ALSA, uinput, and joydev modules permanently"
    sudo modprobe snd_bcm2835
    sudo modprobe uinput
    sudo modprobe joydev

    if ! grep -q "uinput" /etc/modules; then
        addLineToFile "uinput" "/etc/modules"
    else
        echo -e "uinput module already contained in /etc/modules"
    fi
    if ! grep -q "joydev" /etc/modules; then
        addLineToFile "joydev" "/etc/modules"
    else
        echo -e "joydev module already contained in /etc/modules"
    fi    
}

# needed by SDL for working joypads
function exportSDLNOMOUSE()
{
    printMsg "Exporting SDL_NOMOUSE=1 permanently to $home/.bashrc"
    export SDL_NOMOUSE=1
    if ! grep -q "export SDL_NOMOUSE=1" $home/.bashrc; then
        echo -e "\nexport SDL_NOMOUSE=1" >> $home/.bashrc
    else
        echo -e "SDL_NOMOUSE=1 already contained in $home/.bashrc"
    fi    
}

# make sure that all needed packages are installed
function installAPTPackages()
{
    printMsg "Making sure that all needed packaged are installed"
    apt-get install -y libsdl1.2-dev screen scons libasound2-dev pkg-config libgtk2.0-dev \
                        libboost-filesystem-dev libboost-system-dev zip python-imaging \
                        libfreeimage-dev libfreetype6-dev libxml2 libxml2-dev libbz2-dev \
                        libaudiofile-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev \
                        joystick fbi gcc-4.7 automake1.4 libcurl4-openssl-dev  libzip-dev \
                        build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev \
                        libvorbis-dev libpng12-dev libvpx-dev freepats subversion \
                        libboost-serialization-dev libboost-thread-dev libsdl-ttf2.0-dev \
                        cmake g++-4.7 unrar-free p7zip p7zip-full
                        # libgles2-mesa-dev

    # remove PulseAudio since this is slowing down the whole system significantly
    apt-get remove -y pulseaudio
    apt-get -y autoremove
}

# remove all packages that are installed by the RetroPie Setup Script
function removeAPTPackages()
{
    printMsg "Making sure that all packages that are installed by the script are removed."
    apt-get remove -y libsdl1.2-dev screen scons libasound2-dev pkg-config libgtk2.0-dev \
                        libboost-filesystem-dev libboost-system-dev zip python-imaging \
                        libfreeimage-dev libfreetype6-dev libxml2 libxml2-dev libbz2-dev \
                        libaudiofile-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev \
                        joystick fbi gcc-4.7 automake1.4 libcurl4-openssl-dev  libzip-dev \
                        build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev \
                        libvorbis-dev libpng12-dev libvpx-dev freepats subversion \
                        libboost-serialization-dev libboost-thread-dev libsdl-ttf2.0-dev \
                        cmake g++-4.7 unrar-free p7zip p7zip-full
                        # libgles2-mesa-dev

    apt-get -y autoremove   

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Successfully removed APT packages. For a complete uninstall you need to delete the 'RetroPie' folder on your own." 22 76
}

# start SNESDev on boot and configure RetroArch input settings
function enableSplashscreenAtStart()
{
    clear
    printMsg "Enabling custom splashscreen on boot."

    chmod +x "$scriptdir/supplementary/asplashscreen/asplashscreen"
    cp "$scriptdir/supplementary/asplashscreen/asplashscreen" /etc/init.d/

    cp "$scriptdir/supplementary/asplashscreen/splashscreen.png" /etc/

    # This command installs the init.d script so it automatically starts on boot
    insserv /etc/init.d/asplashscreen
    # not-so-elegant hack for later re-enabling the splashscreen
    update-rc.d asplashscreen enable

}

# disable start SNESDev on boot and remove RetroArch input settings
function disableSplashscreenAtStart()
{
    clear
    printMsg "Disabling custom splashscreen on boot."

    update-rc.d asplashscreen disable

}

# Show dialogue for enabling/disabling SNESDev on boot
function enableDisableSplashscreen()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable custom splashscreen on boot."
             2 "Enable custom splashscreen on boot")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) disableSplashscreenAtStart
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Disabled custom splashscreen on boot." 22 76    
                            ;;
            2) enableSplashscreenAtStart
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Enabled custom splashscreen on boot." 22 76    
                            ;;
        esac
    else
        break
    fi    
}

# prepare folder structure for emulator, cores, front end, and roms
function prepareFolders()
{
    printMsg "Creating folder structure for emulator, front end, cores, and roms"

    pathlist=()
    pathlist+=("$rootdir/roms")
    pathlist+=("$rootdir/roms/atari2600")
    pathlist+=("$rootdir/roms/basiliskii")
    pathlist+=("$rootdir/roms/c64")
    pathlist+=("$rootdir/roms/cavestory")
    pathlist+=("$rootdir/roms/doom")
    pathlist+=("$rootdir/roms/duke3d/")
    pathlist+=("$rootdir/roms/esconfig/")
    pathlist+=("$rootdir/roms/gamegear")
    pathlist+=("$rootdir/roms/gb")
    pathlist+=("$rootdir/roms/gba")
    pathlist+=("$rootdir/roms/gbc")
    pathlist+=("$rootdir/roms/intellivision")
    pathlist+=("$rootdir/roms/mame")
    pathlist+=("$rootdir/roms/mastersystem")
    pathlist+=("$rootdir/roms/megadrive")
    pathlist+=("$rootdir/roms/nes")
    pathlist+=("$rootdir/roms/pcengine")
    pathlist+=("$rootdir/roms/psx")
    pathlist+=("$rootdir/roms/psp")
    pathlist+=("$rootdir/roms/snes")
    pathlist+=("$rootdir/roms/zxspectrum")
    pathlist+=("$rootdir/roms/fba")
    pathlist+=("$rootdir/roms/amiga")
    pathlist+=("$rootdir/roms/neogeo")
    pathlist+=("$rootdir/roms/scummvm")
    pathlist+=("$rootdir/roms/x86")
    pathlist+=("$rootdir/roms/zmachine")
    pathlist+=("$rootdir/emulatorcores")
    pathlist+=("$rootdir/emulators")
    pathlist+=("$rootdir/supplementary")

    for elem in "${pathlist[@]}"
    do
        if [[ ! -d $elem ]]; then
            mkdir -p $elem
            chown $user $elem
            chgrp $user $elem
        fi
    done    
}

# settings for RetroArch
function configureRetroArch()
{
    printMsg "Configuring RetroArch"

    if [[ ! -f "$rootdir/configs/all/retroarch.cfg" ]]; then
        mkdir -p "$rootdir/configs/all/"
        mkdir -p "$rootdir/configs/atari2600/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/atari2600/retroarch.cfg
        mkdir -p "$rootdir/configs/cavestory/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/cavestory/retroarch.cfg
        mkdir -p "$rootdir/configs/doom/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/doom/retroarch.cfg
        mkdir -p "$rootdir/configs/gb/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/gb/retroarch.cfg
        mkdir -p "$rootdir/configs/gbc/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/gbc/retroarch.cfg
        mkdir -p "$rootdir/configs/gamegear/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/gamegear/retroarch.cfg
        mkdir -p "$rootdir/configs/mame/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/mame/retroarch.cfg
        mkdir -p "$rootdir/configs/mastersystem/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/mastersystem/retroarch.cfg
        mkdir -p "$rootdir/configs/nes/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/nes/retroarch.cfg
        mkdir -p "$rootdir/configs/pcengine/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/pcengine/retroarch.cfg
        mkdir -p "$rootdir/configs/psx/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/psx/retroarch.cfg
        mkdir -p "$rootdir/configs/snes/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/snes/retroarch.cfg
        mkdir -p "$rootdir/configs/fba/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/fba/retroarch.cfg
        cp /etc/retroarch.cfg "$rootdir/configs/all/"
    fi

    ensureKeyValue "system_directory" "$rootdir/emulatorcores/" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "video_aspect_ratio" "1.33" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$rootdir/configs/all/retroarch.cfg"

    # enable hotkey ("select" button)
    ensureKeyValue "input_exit_emulator" "escape" "$rootdir/configs/all/retroarch.cfg"

    # enable and configure rewind feature
    ensureKeyValue "rewind_enable" "true" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "rewind_buffer_size" "10" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "rewind_granularity" "2" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_rewind" "r" "$rootdir/configs/all/retroarch.cfg"

    # configure keyboard mappings
    ensureKeyValue "input_player1_a" "x" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_b" "z" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_y" "a" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_x" "s" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_start" "enter" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_select" "rshift" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_l" "q" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_r" "w" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_left" "left" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_right" "right" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_up" "up" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_down" "down" "$rootdir/configs/all/retroarch.cfg"
}

# install RetroArch emulator
function install_retroarch()
{
    printMsg "Installing RetroArch emulator"
    gitPullOrClone "$rootdir/emulators/RetroArch" git://github.com/libretro/RetroArch.git
    ./configure
    make
    sudo make install
    cp $scriptdir/supplementary/retroarch-zip "$rootdir/emulators/RetroArch/"
    if [[ ! -f "/usr/local/bin/retroarch" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile and install RetroArch."
    fi  
    popd
}

function configure_advmame()
{
    $rootdir/emulators/advancemame-0.94.0/installdir/bin/advmame
    mv /root/.advance/ /home/$user/
    echo 'device_video_clock 5 - 50 / 15.62 / 50 ; 5 - 50 / 15.73 / 60' >> /home/$user/.advance/advmame.rc
    chmod -R a+rwX /home/$user/.advance/
    chown -R $user /home/$user/.advance/
}

# install AdvanceMAME emulator
install_advmame()
{
    printMsg "Installing AdvMAME emulator"

    wget -O advmame.tar.gz http://downloads.sourceforge.net/project/advancemame/advancemame/0.94.0/advancemame-0.94.0.tar.gz

    apt-get -y install libsdl1.2-dev gcc-4.7
    export CC=gcc-4.7
    export GCC=g++-4.7

    tar xzvf advmame.tar.gz -C "$rootdir/emulators/"
    pushd "$rootdir/emulators/advancemame-0.94.0"
    sed 's/MAP_SHARED | MAP_FIXED,/MAP_SHARED,/' <advance/linux/vfb.c >advance/linux/temp.c
    mv advance/linux/temp.c advance/linux/vfb.c
    sed 's/misc_quiet\", 0/misc_quiet\", 1/' <advance/osd/global.c >advance/osd/temp.c
    mv advance/osd/temp.c advance/osd/global.c 
sed '
/#include <string>/ i\
#include <stdlib.h>
' <advance/d2/d2.cc >advance/d2/temp.cc
    mv advance/d2/temp.cc advance/d2/d2.cc
    ./configure --prefix="$rootdir/emulators/advancemame-0.94.0/installdir"
    sed 's/LDFLAGS=-s/LDFLAGS=-s -lm -Wl,--no-as-needed/' <Makefile >Makefile.temp
    mv Makefile.temp Makefile
    make
    make install
    popd

    configure_advmame
    unset CC
    unset GCC
}

function ensureEntryInSMBConf()
{
    comp=`cat /etc/samba/smb.conf | grep "\[$1\]"`
    if [ "$comp" == "[$1]" ]; then
      echo "$1 already contained in /etc/samba/smb.conf."
    else
    chmod 666 /etc/samba/smb.conf
    tee -a /etc/samba/smb.conf <<HDHD
[$1]
comment = $1
path = $rootdir/roms/$2
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777
read only = no
browseable = yes
force user = $user
public = yes
HDHD
    fi
    chmod 644 /etc/samba/smb.conf
}

# install and configure SAMBA shares for each ROM directory of the emulators
configureSAMBA()
{
    clear
    printMsg "Installing and configuring SAMBA shares."
    apt-get update
    apt-get install -y samba samba-common-bin

    ensureEntryInSMBConf "AMIGA" "amiga"
    ensureEntryInSMBConf "APPLE2" "apple2"
    ensureEntryInSMBConf "ATARI2600" "atari2600"
    ensureEntryInSMBConf "BASILISKII" "basiliskii"
    ensureEntryInSMBConf "C64" "c64"
    ensureEntryInSMBConf "DOOM" "doom"
    ensureEntryInSMBConf "DUKE3D" "duke3d"
    ensureEntryInSMBConf "GAMEGEAR" "gamegear"
    ensureEntryInSMBConf "FBA" "fba"
    ensureEntryInSMBConf "GB" "gb"
    ensureEntryInSMBConf "GBA" "gba"
    ensureEntryInSMBConf "GBC" "gbc"
    ensureEntryInSMBConf "INTELLIVISION" "intellivision"
    ensureEntryInSMBConf "MAME" "mame"
    ensureEntryInSMBConf "MASTERSYSTEM" "mastersystem"
    ensureEntryInSMBConf "MEGADRIVE" "megadrive"
    ensureEntryInSMBConf "NEOGEO" "neogeo"
    ensureEntryInSMBConf "NES" "nes"
    ensureEntryInSMBConf "X86" "x86"
    ensureEntryInSMBConf "PCENGINE" "pcengine"
    ensureEntryInSMBConf "PSX" "psx"
    ensureEntryInSMBConf "PPSSPP" "psp"
    ensureEntryInSMBConf "SNES" "snes"
    ensureEntryInSMBConf "SCUMMVM" "scummvm"
    ensureEntryInSMBConf "ZMACHINE" "zmachine"
    ensureEntryInSMBConf "ZXSPECTRUM" "zxspectrum"

    /etc/init.d/samba restart

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "The SAMBA shares can be accessed with a guest account" 22 76    

}

# install Amiga emulator
install_amiga()
{
    printMsg "Installing Amiga emulator"
    if [[ -d "$rootdir/emulators/uae4all" ]]; then
        rm -rf "$rootdir/emulators/uae4all"
    fi
    wget http://darcelf.free.fr/uae4all-src-rc3.chip.tar.bz2
    tar -jxvf uae4all-src-rc3.chip.tar.bz2 -C "$rootdir/emulators/"
    pushd "$rootdir/emulators/uae4all"
    if [[ ! -f /opt/vc/include/interface/vmcs_host/vchost_config.h ]]; then
        touch /opt/vc/include/interface/vmcs_host/vchost_config.h
    fi
    touch /opt/vc/include/interface/vmcs_host/vchost_config.h
    make
    chown -R $user "$rootdir/emulators/uae4all"
    chgrp -R pi "$rootdir/emulators/uae4all"
    if [[ ! -f "$rootdir/emulators/uae4all/uae4all" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Amiga emulator."
    fi  
    mkdir "roms"
    popd  
    rm uae4all-src-rc3.chip.tar.bz2  

    __INFMSGS="$__INFMSGS The Amiga emulator can be started from command line with '$rootdir/emulators/uae4all/uae4all'. Note that you must manually copy a Kickstart rom with the name 'kick.rom' to the directory $rootdir/emulators/uae4all/."
}

# install Atari 2600 core
function install_atari2600()
{
    printMsg "Installing Atari 2600 RetroArch core"
    gitPullOrClone "$rootdir/emulatorcores/stella-libretro" git://github.com/libretro/stella-libretro.git
    # remove msse and msse2 flags from Makefile, just a hack here to make it compile on the Raspberry
    sed 's|-msse2 ||g;s|-msse ||g' Makefile >> Makefile.rpi
    make -f Makefile.rpi
    if [[ -z `find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 2600 core."
    fi  
    popd    
}

function install_stella()
{
    printMsg "Installing Atari 2600 emulator Stella"
    apt-get install -y stella
}

function install_basiliskII()
{
    printMsg "Installing Basilisk II"
    gitPullOrClone "$rootdir/emulators/basiliskii" git://github.com/cebix/macemu.git
    cd BasiliskII/src/Unix
    ./autogen.sh
    ./configure --prefix="$rootdir/emulators/basiliskii/installdir" --enable-sdl-video --enable-sdl-audio --disable-vosf --disable-jit-compiler
    make
    make install
    touch $rootdir/roms/basiliskii/Start.txt
    if [[ -z "$rootdir/emulators/basiliskii/installdir/bin/BasiliskII" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile BasiliskII."
    else
        configure_cavestory
    fi  
    popd
}

# install C64 ROMs
function install_c64roms()
{
    printMsg "Retrieving Commodore 64 ROMs"
    wget http://www.zimmers.net/anonftp/pub/cbm/crossplatform/emulators/VICE/old/vice-1.5-roms.tar.gz
    tar -xvzf vice-1.5-roms.tar.gz
    mkdir -p "$rootdir/emulators/vice-2.3.dfsg/installdir/lib/vice/"
    cp -a vice-1.5-roms/data/* "$rootdir/emulators/vice-2.3.dfsg/installdir/lib/vice/"
    rm -rf vice-1.5-roms
    rm -rf vice-1.5-roms.tar.gz    
}

# Install VICE C64 Emulator
function install_viceC64()
{
    printMsg "Install VICE Commodore 64 core"
    if [[ -d "$rootdir/emulators/vice-2.3.dsfg" ]]; then
        rm -rf "$rootdir/emulators/vice-2.3.dsfg"
    fi
    if dpkg-query -Wf'${db:Status-abbrev}' vice 2>/dev/null | grep -q '^i'; then
        printf 'Package vice is already installed - removing package\n' "${1}"
        apt-get remove -y vice
    fi
    printMsg "Installing vice"
    pushd "$rootdir/emulators"
    echo 'deb-src http://mirrordirector.raspbian.org/raspbian/ wheezy main contrib non-free rpi' >> /etc/apt/sources.list
    apt-get update
    apt-get build-dep -y vice
    apt-get install -y libxaw7-dev automake checkinstall
    apt-get source vice
    cd vice-2.3.dfsg
    ./configure --prefix="$rootdir/emulators/vice-2.3.dfsg/installdir" --enable-sdlui --with-sdlsound
    make    
    make install
    popd
    install_c64roms    
}

# configure NXEngine / Cave Story core
function configure_cavestory()
{
    if [[ ! -d $rootdir/roms/cavestory ]]; then
        mkdir -p $rootdir/roms/cavestory
    fi
    touch $rootdir/roms/cavestory/Start.txt    
}

# install NXEngine / Cave Story core
function install_cavestory()
{
    printMsg "Installing NXEngine / Cave Story"
    gitPullOrClone "$rootdir/emulatorcores/nxengine-libretro" git://github.com/libretro/nxengine-libretro.git
    make
    if [[ -z `find $rootdir/emulatorcores/nxengine-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NXEngine / Cave Story core."
    else
        configure_cavestory
    fi  
    popd
}

# configure DGEN
function configureDGEN()
{
    chmod 777 /dev/fb0

    if [[ ! -f "$rootdir/configs/all/dgenrc" ]]; then
        mkdir -p "$rootdir/configs/all/"
        cp $rootdir/emulators/dgen-sdl/sample.dgenrc $rootdir/configs/all/dgenrc 
    fi

    chown -R $user $rootdir/configs/all/
    chgrp -R $user $rootdir/configs/all/

    ensureKeyValue "joy_pad1_a" "joystick0-button0" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_b" "joystick0-button1" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_c" "joystick0-button2" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_x" "joystick0-button3" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_y" "joystick0-button4" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_z" "joystick0-button5" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_mode" "joystick0-button6" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad1_start" "joystick0-button7" $rootdir/configs/all/dgenrc

    ensureKeyValue "joy_pad2_a" "joystick1-button0" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_b" "joystick1-button1" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_c" "joystick1-button2" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_x" "joystick1-button3" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_y" "joystick1-button4" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_z" "joystick1-button5" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_mode" "joystick1-button6" $rootdir/configs/all/dgenrc
    ensureKeyValue "joy_pad2_start" "joystick1-button7" $rootdir/configs/all/dgenrc
}

# install DGEN (Megadrive/Genesis emulator)
function install_dgen()
{
    printMsg "Installing Megadrive/Genesis emulator"
    if [[ -d "$rootdir/emulators/dgen" ]]; then
        rm -rf "$rootdir/emulators/dgen"
    fi   
    wget http://downloads.sourceforge.net/project/dgen/dgen/1.32/dgen-sdl-1.32.tar.gz
    tar xvfz dgen-sdl-1.32.tar.gz -C "$rootdir/emulators/"
    mv "$rootdir/emulators/dgen-sdl-1.32" "$rootdir/emulators/dgen-sdl"
    pushd "$rootdir/emulators/dgen-sdl"
    mkdir "installdir" # only used for creating the binaries archive
    ./configure --disable-opengl
    make
    make install DESTDIR=$rootdir/emulators/dgen-sdl/installdir
    make install
    if [[ ! -f "$rootdir/emulators/dgen-sdl/dgen" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile DGEN emulator."
    fi  
    popd
    rm dgen-sdl-1.32.tar.gz
}

function configure_doom()
{
    mkdir -p $rootdir/roms/doom/
    cp $rootdir/emulatorcores/libretro-prboom/prboom.wad $rootdir/roms/doom/
}

# install Doom WADs emulator core
function install_doom()
{
    printMsg "Installing Doom core"
    gitPullOrClone "$rootdir/emulatorcores/libretro-prboom" git://github.com/libretro/libretro-prboom.git
    make
    if [[ -z `find $rootdir/emulatorcores/libretro-prboom/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Doom core."
    fi  
    popd
    configure_doom
}

#install eDuke32
function install_eduke32()
{
    printMsg "Installing eDuke32"
    if [[ -d "$rootdir/emulators/eduke32" ]]; then
        rm -rf "$rootdir/emulators/eduke32"
    fi
    mkdir -p $rootdir/emulators/eduke32
    pushd "$rootdir/emulators/eduke32"
    printMsg "Downloading eDuke core"
    wget http://repo.berryboot.com/eduke32_2.0.0rpi+svn2789_armhf.deb       
    printMsg "Downloading eDuke32 Shareware files"
    wget http://apt.duke4.net/pool/main/d/duke3d-shareware/duke3d-shareware_1.3d-23_all.deb 
    if [[ ! -f "$rootdir/emulators/eduke32/eduke32_2.0.0rpi+svn2789_armhf.deb" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully install eDuke32 core."
    else
        printMsg "Installing eDuke32"
        sudo dpkg -i *duke*.deb
        cp /usr/share/games/eduke32/DUKE.RTS $rootdir/roms/duke3d/
        cp /usr/share/games/eduke32/duke3d.grp $rootdir/roms/duke3d/
    fi
    popd
    rm -rf "$rootdir/emulators/eduke32"
}


# install Game Boy Advance emulator gpSP
function install_gba()
{
    printMsg "Installing Game Boy Advance emulator gpSP"
    gitPullOrClone "$rootdir/emulators/gpsp" git://github.com/DPRCZ/gpsp.git
    cd raspberrypi

    #if we are on the 256mb model, we will never have enough RAM to compile gpSP with compiler optimization
    #if this is the case, use sed to remove the -O3 in the Makefile (line 20, "CFLAGS     += -O3 -mfpu=vfp")
    local RPiRev=`grep 'Revision' /proc/cpuinfo | cut -d " " -f 2`
    if [ $RPiRev == "00d" ] || [ $RPiRev == "000e" ] || [ $RPiRev == "000f" ]; then
    	#RAM = 512mb, we're good
    	echo "512mb Pi, no de-optimization fix needed."
    else
	#RAM = 256mb, need to compile unoptimized
    	echo "Stripping -O[1..3] from gpSP Makefile to compile unoptimized on 256mb Pi..."
    	sed -i 's/-O[1..3]//g' Makefile
    fi

    #gpSP is missing an include in the Makefile
    if [[ ! -z `grep '-I/opt/vc/include/interface/vmcs_host/linux' Makefile` ]]; then
	   echo "Skipping adding missing include to gpSP Makefile."
    else
	   echo "Adding -I/opt/vc/include/interface/vmcs_host/linux to Makefile"
	   sed -i '23iCFLAGS     += -I/opt/vc/include/interface/vmcs_host/linux' Makefile
    fi

    make
    if [[ -z `find $rootdir/emulators/gpsp/ -name "gpsp"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Game Boy Advance emulator."
    fi
    popd
}

# install Game Boy Color emulator core
function install_gbc()
{
    printMsg "Installing Game Boy Color core"
    gitPullOrClone "$rootdir/emulatorcores/gambatte-libretro" git://github.com/libretro/gambatte-libretro.git
    make -C libgambatte -f Makefile.libretro
    if [[ -z `find $rootdir/emulatorcores/gambatte-libretro/libgambatte/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Game Boy Color core."
    fi      
    popd
}

# install MAME emulator core
function install_mame()
{
    printMsg "Installing MAME core"
    gitPullOrClone "$rootdir/emulatorcores/imame4all-libretro" git://github.com/libretro/imame4all-libretro.git
    make -f makefile.libretro ARM=1
    if [[ -z `find $rootdir/emulatorcores/imame4all-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile MAME core."
    fi      
    popd
}

# install FBA emulator core
function install_fba()
{
    printMsg "Installing FBA core"
    gitPullOrClone "$rootdir/emulatorcores/fba-libretro" git://github.com/libretro/fba-libretro.git
    apt-get install -y --force-yes cpp-4.5 gcc-4.5 g++-4.5
    (
        cd $rootdir/emulatorcores/fba-libretro/svn-current/trunk/
        CC=gcc-4.5 CXX=g++-4.5 make -f makefile.libretro
    )
    mv svn-current/trunk/*libretro*.so $rootdir/emulatorcores/fba-libretro/
    if [[ -z `find $rootdir/emulatorcores/fba-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile FBA core."
    fi
    popd
}

# configure NeoGeo
function configureNeogeo()
{
    mkdir /home/$user/.gngeo/
    cp $rootdir/emulators/gngeo-0.7/sample_gngeorc /home/$user/.gngeo/gngeorc
    chown -R $user /home/$user/.gngeo/
    chgrp -R $user /home/$user/.gngeo/

    sed -i -e "s/effect none/effect scale2x/g" /home/$user/.gngeo/gngeorc
    sed -i -e "s/fullscreen false/fullscreen true/g" /home/$user/.gngeo/gngeorc
    sed -i -e "s|rompath /usr/games/lib/xmame|rompath $rootdir/RetroPie/emulators/gngeo-0.7/installdir/share/gngeo/romrc.d|g" /home/$user/.gngeo/gngeorc

    chmod 777 /dev/fb0

    mkdir "$rootdir/emulators/gngeo-0.7/neogeo-bios"
    __INFMSGS="$__INFMSGS You need to copy NeoGeo BIOS files to the folder '$rootdir/emulators/gngeo-0.7/neogeo-bios/'."    
}

# configure AdvanceMenu
function configure_advancemenu()
{
    printMsg "Configuring AdvanceMenu"

    mkdir -p "/home/$user/.advance/"
    cp "$scriptdir/supplementary/advmenu.rc" "/home/$user/.advance/"

    cat >> "/home/$user/.advance/advmenu.rc" << _EOF_

emulator "Atari 2600" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/atari2600/retroarch.cfg %p"
emulator_roms "Atari 2600" "$rootdir/roms/atari2600"

emulator "Doom" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/libretro-prboom/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/doom/retroarch.cfg %p"
emulator_roms "Doom" "$rootdir/roms/doom"

emulator "eDuke32" generic "/usr/local/bin/eduke32" "%p"

emulator "Gameboy Advance" generic "$rootdir/emulators/gpsp/gpsp" "%p"
emulator_roms "Gameboy Advance" "$rootdir/roms/gba"

emulator "Gameboy Color" generic "-L `find $rootdir/emulatorcores/gambatte-libretro/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gbc/retroarch.cfg %p"
emulator_roms "Gameboy Color" "$rootdir/roms/gbc"

emulator "Sega Game Gear" generic "$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose" "%p -joy -tv -fs"
emulator_roms "Sega Game Gear" "$rootdir/roms/gamegear"

emulator "IntelliVision" generic "$rootdir/emulators/jzintv-1.0-beta4/bin/jzintv" "-z1 -f1 -q %p"
emulator_roms "IntelliVision" "$rootdir/roms/intellivision"

emulator "MAME" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/imame4all-libretro/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/mame/retroarch.cfg %p"
emulator_roms "MAME" "$rootdir/roms/mame"

emulator "ScummVM" generic "scummvm"
emulator_roms "ScummVM" "$rootdir/roms/scummvm"

emulator "Sega Master System" generic "$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose" "%p -joy -tv -fs"
emulator_roms "Sega Master System" "$rootdir/roms/mastersystem"

emulator "Sega Mega Drive / Genesis" generic "$rootdir/emulators/dgen-sdl/dgen" "-f %p"
emulator_roms "Sega Mega Drive / Genesis" "$rootdir/roms/megadrive"

emulator "NeoGeo" generic "$rootdir/emulators/gngeo-0.7/src/gngeo" "-i $rootdir/roms/neogeo -B $rootdir/emulators/gngeo-0.7/neogeo-bios %p" 
emulator_roms "NeoGeo" "$rootdir/roms/neogeo"

emulator "Nintendo Entertainment System" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/fceu-next/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/nes/retroarch.cfg %p"
emulator_roms "Nintendo Entertainment System" "$rootdir/roms/nes"

emulator "PC Engine/TurboGrafx 16" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/mednafen-pce-libretro/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/pcengine/retroarch.cfg %p"
emulator_roms "PC Engine/TurboGrafx 16" "$rootdir/roms/pcengine"

emulator "Sony Playstation 1" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/pcsx_libretro/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/psx/retroarch.cfg %p"
emulator_roms "Sony Playstation 1" "$rootdir/roms/psx"

emulator "Super Nintendo" generic "/usr/local/bin/retroarch" "-L `find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so"` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/snes/retroarch.cfg %p"
emulator_roms "Super Nintendo" "$rootdir/roms/snes"

_EOF_

}

# install AdvanceMenu
function install_advancemenu()
{
    printMsg "Installing Advance Menu"

    dialog --title "AdvanceMenu" --clear \
    --yesno "It is important that you have set GPU memory to 16 MB (e.g., via the raspi-config script). Do you want to continue?" 22 76

    case $? in
      0)

        wget http://downloads.sourceforge.net/project/advancemame/advancemenu/2.5.0/advancemenu-2.5.0.tar.gz
        tar xvfz advancemenu-2.5.0.tar.gz -C "$rootdir/supplementary/"

        apt-get install -y gcc-4.7
        export CC=gcc-4.7   
        export GCC=g++-4.7    

        pushd "$rootdir/supplementary/advancemenu-2.5.0/"
        ./configure
        sed -i -e "s| -march=native||g" Makefile
        make
        make install
        popd

        configure_advancemenu
        rm advancemenu-2.5.0.tar.gz
        unset CC
        unset GCC

        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Remember to increase the GPU memory again (e.g., via the raspi-config script)!" 22 76    

     ;;
      *)
        ;;
    esac

}

# install NeoGeo emulator GnGeo-Pi
function install_GnGeoPi()
{
    printMsg "Installing GnGeo-Pi emulator"
    if [[ -d "$rootdir/emulators/gngeo-pi-0.85" ]]; then
        rm -rf "$rootdir/emulators/gngeo-pi-0.85"
    fi
    gitPullOrClone "$rootdir/emulators/gngeo-pi-0.85" https://github.com/ymartel06/GnGeo-Pi.git
    pushd "$rootdir/emulators/gngeo-pi-0.85/gngeo"
    chmod +x configure
    ./configure --host=arm-linux --target=arm-linux --disable-i386asm --prefix="$rootdir/emulators/gngeo-pi-0.85/installdir"
    make
    make install
    if [[ ! -f "$rootdir/emulators/gngeo-pi-0.85/installdir/arm-linux-gngeo" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile GnGeo-Pi emulator."
    fi      
    popd
}

# install NeoGeo emulator
function install_neogeo()
{
    printMsg "Installing NeoGeo emulator"
    if [[ -d "$rootdir/emulators/gngeo" ]]; then
        rm -rf "$rootdir/emulators/gngeo"
    fi

    # GnGeo
    wget http://gngeo.googlecode.com/files/gngeo-0.7.tar.gz
    tar xvfz gngeo-0.7.tar.gz -C $rootdir/emulators/
    pushd "$rootdir/emulators/gngeo-0.7"
    ./configure --host=arm-linux --target=arm-linux --disable-i386asm --prefix="$rootdir/emulators/gngeo-0.7/installdir"
    make
    make install

    if [[ ! -f "$rootdir/emulators/gngeo-0.7/src/gngeo" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NeoGeo emulator."
    fi          
    popd
    rm gngeo-0.7.tar.gz

}

# install NES emulator core
function install_nes()
{
    printMsg "Installing NES core"
    gitPullOrClone "$rootdir/emulatorcores/fceu-next" git://github.com/libretro/fceu-next.git
    pushd fceumm-code
    make -f Makefile.libretro
    popd
    if [[ -z `find $rootdir/emulatorcores/fceu-next/fceumm-code/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NES core."
    fi      
    popd
}

# install Sega Mega Drive/Mastersystem/Game Gear emulator OsmOse
function install_megadrive()
{
    printMsg "Installing Mega Drive/Mastersystem/Game Gear emulator OsmMose"

    wget https://dl.dropbox.com/s/z6l69wge8q1xq7r/osmose-0.8.1%2Brpi20121122.tar.bz2?dl=1 -O osmose.tar.bz2
    tar -jxvf osmose.tar.bz2 -C "$rootdir/emulators/"
    pushd "$rootdir/emulators/osmose-0.8.1+rpi20121122/"
    make clean
    make
    if [[ ! -f "$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile OsmMose."
    fi      
    popd
    rm osmose.tar.bz2
}

# install Intellivision Emulator jzintv
function install_intellivision()
{
    printMsg "Installing Intellivision emulator jzintv"
    wget http://spatula-city.org/~im14u2c/intv/dl/jzintv-1.0-beta4-src.zip -O jzintv.zip
    unzip -n jzintv.zip -d "$rootdir/emulators/"
    pushd "$rootdir/emulators/jzintv-1.0-beta4/src/"
    mkdir "$rootdir/emulators/jzintv-1.0-beta4/bin"
    cat > "pi.diff" << _EOF_
65c
 OPT_FLAGS = -O3 -fomit-frame-pointer -fprefetch-loop-arrays -march=armv6 -mfloat-abi=hard -mfpu=vfp
.
_EOF_

    patch -e Makefile pi.diff
    make clean
    make
    if [[ ! -f "$rootdir/emulators/jzintv-1.0-beta4/bin/jzintv" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile jzintv."
    else
        __INFMSGS="$__INFMSGS You need to copy Intellivision BIOS files to the folder '/usr/local/share/jzintv/rom'."
    fi      
    popd
    rm jzintv.zip
}

# configure Lineapple emulator
function configure_linapple()
{
    if [[ ! -d $rootdir/roms/apple2 ]]; then
        mkdir -p $rootdir/roms/apple2
    fi
    cat > "$rootdir/emulators/linapple-src_2a/Start.sh" << _EOF_
#!/bin/bash
pushd $rootdir/emulators/linapple-src_2a
./linapple
popd
_EOF_
    chmod +x "$rootdir/emulators/linapple-src_2a/Start.sh"
    touch $rootdir/roms/apple2/Start.txt

    pushd "$rootdir/emulators/linapple-src_2a"
    sed -i -r -e "s|[^I]?Joystick 0[^I]?=[^I]?[0-9]|\tJoystick 0\t=\t1|g" linapple.conf
    sed -i -r -e "s|[^I]?Joystick 1[^I]?=[^I]?[0-9]|\tJoystick 1\t=\t1|g" linapple.conf
    popd
    chgrp -R $user $rootdir
    chown -R $user $rootdir  
}

# install Linapple emulator
function install_linapple()
{
    printMsg "Installing Apple II emulator (Linapple)"
    if [[ -d "$rootdir/emulators/apple2" ]]; then
        rm -rf "$rootdir/emulators/apple2"
    fi   
    wget http://downloads.sourceforge.net/project/linapple/linapple/linapple-2a/linapple-src_2a.tar.bz2
    tar -jxvf linapple-src_2a.tar.bz2 -C "$rootdir/emulators/"
    pushd "$rootdir/emulators/linapple-src_2a/src"
    make
    popd    
    configure_linapple
    rm linapple-src_2a.tar.bz2
}

# install Sega Mega Drive/Mastersystem/Game Gear libretro emulator core
function install_megadriveLibretro()
{
    printMsg "Installing Mega Drive/Mastersystem/Game Gear core (Libretro core)"
    gitPullOrClone "$rootdir/emulatorcores/Genesis-Plus-GX" git://github.com/libretro/Genesis-Plus-GX.git
    make -f Makefile.libretro 
    if [[ ! -f `find $rootdir/emulatorcores/Genesis-Plus-GX/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Genesis core."
    fi      
    popd
}

# install Playstation emulator core
function install_psx()
{
    printMsg "Installing PCSX core"
    gitPullOrClone "$rootdir/emulatorcores/pcsx_rearmed" git://github.com/libretro/pcsx_rearmed.git
    ./configure --platform=libretro
    make
    if [[ -z `find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Playstation core."
    fi      
    popd
}

# install SNES emulator core
function install_snes()
{
    printMsg "Installing SNES core"
    gitPullOrClone "$rootdir/emulatorcores/pocketsnes-libretro" git://github.com/ToadKing/pocketsnes-libretro.git
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch $rootdir/emulatorcores/pocketsnes-libretro/src/ppu.cpp
    make
    if [[ -z `find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES core."
    fi      
    popd
}

# configure SNES emulator core settings
function configure_snes()
{
    printMsg "Configuring SNES core"

    # DISABLE rewind feature for SNES core due to the speed decrease
    ensureKeyValue "rewind_enable" "false" "$rootdir/configs/snes/retroarch.cfg"
}

# install SNES9X emulator
function install_snes9x()
{
    if [[ -d "$rootdir/emulators/snes9x-rpi" ]]; then
        rm -rf "$rootdir/emulators/snes9x-rpi"
    fi        
    gitPullOrClone "$rootdir/emulators/snes9x-rpi" https://github.com/chep/snes9x-rpi.git
    make
    if [[ -z `grep "mode \"320x240\"" /etc/fb.modes` ]]; then
        echo -e "mode \"320x240\"\ngeometry 320 240 656 512 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" | cat - /etc/fb.modes > temp && mv temp /etc/fb.modes
    fi
    if [[ ! -f "$rootdir/emulators/snes9x-rpi/snes9x" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES9X."
    fi      
    popd
}

# install PiSNES emulator
function install_pisnes()
{
    if [[ -d "$rootdir/emulators/pisnes" ]]; then
        rm -rf "$rootdir/emulators/pisnes"
    fi        
    gitPullOrClone "$rootdir/emulators/pisnes" https://code.google.com/p/pisnes/
    sed -i -e "s|-lglib-2.0|-lglib-2.0 -lbcm_host|g" Makefile
    make
    if [[ -z `grep "mode \"320x240\"" /etc/fb.modes` ]]; then
        echo -e "mode \"320x240\"\ngeometry 320 240 656 512 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" | cat - /etc/fb.modes > temp && mv temp /etc/fb.modes
    fi
    if [[ ! -f "$rootdir/emulators/pisnes/snes9x" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile PiSNES."
    fi      
    popd
}

# install PSP emulator PPSSPP
function install_ppsspp()
{
    if [[ -d "$rootdir/emulators/ppsspp" ]]; then
        rm -rf "$rootdir/emulators/ppsspp"
    fi        
    gitPullOrClone "$rootdir/emulators/ppsspp" git://github.com/hrydgard/ppsspp.git
    git submodule update --init    
    # generate default Makefile
    cmake . 
    sed -i -e "s/ARM:BOOL=OFF/ARM:BOOL=ON/g" CMakeCache.txt
    sed -i -e "s/X86:BOOL=ON/X86:BOOL=OFF/g" CMakeCache.txt
    sed -i -e "s/CMAKE_BUILD_TYPE:STRING=/CMAKE_BUILD_TYPE:STRING=Release/g" CMakeCache.txt
    # enabled arm, disabled x86, built with release flags.
    cmake .
    make    
    mkdir -p "$rootdir/emulators/ppsspp/assets/lang"
    cp $rootdir/emulators/ppsspp/lang/* $rootdir/emulators/ppsspp/assets/lang/
    if [[ ! -f "$rootdir/emulators/ppsspp/PPSSPPSDL" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile PPSSPP."
    fi      
    popd
}

function install_wolfenstein3d()
{
    printMsg "Installing Wolfenstein3D Engine"    
    if [[ -d "$rootdir/emulators/Wolf4SDL-1.7-src" ]]; then
        rm -rf "$rootdir/emulators/Wolf4SDL-1.7-src"
    fi    
    wget http://radix-16.com/files/wolf4sdl/Wolf4SDL-1.7-src.zip
    mv Wolf4SDL-1.7-src.zip Wolf4SDL-1.7.zip
    unzip -n Wolf4SDL-1.7.zip -d "$rootdir/emulators/"
    pushd "$rootdir/emulators/Wolf4SDL-1.7-src"
    make
    mkdir "$rootdir/emulators/Wolf4SDL-1.7-bin"
    cp wolf3d "$rootdir/emulators/Wolf4SDL-1.7-bin/"
    popd
    if [[ ! -f "$rootdir/emulators/Wolf4SDL-1.7-bin/wolf3d" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Wolfenstein3D engine."
    else
        __INFMSGS="$__INFMSGS The Wolfenstein3D engine was successfully installed. You have to copy the game files (.wl6) into the directory $rootdir/emulators/Wolf4SDL-1.7-bin. Take care for lowercase extensions!"        
    fi 
    rm Wolf4SDL-1.7.zip
}

# install Dispmanx library
function install_dispmanx()
{
    printMsg "Installing Dispmanx library"    
    if [[ -d "$rootdir/supplementary/dispmanx" ]]; then
        rm -rf "$rootdir/supplementary/dispmanx"
    fi 
    gitPullOrClone "$rootdir/supplementary/dispmanx" git://github.com/vanfanel/SDL12-kms-dispmanx.git
    export CFLAGS="-I/opt/vc/include/interface/vmcs_host/linux"
    ./MAC_ConfigureDISPMANX.sh
    make

    if [[ ! -f "$rootdir/supplementary/dispmanx/build/.libs/libSDL.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Dispmanx."
    fi    
    popd
}

function configure_rpix86()
{
    ln -s $rootdir/roms/x86/ $rootdir/emulators/rpix86/games
    rm $rootdir/roms/x86/x86
    cat > "$rootdir/emulators/rpix86/Start.sh" << _EOF_
#!/bin/bash
pushd $rootdir/emulators/rpix86
./rpix86
popd
_EOF_
    chmod +x "$rootdir/emulators/rpix86/Start.sh"
    touch $rootdir/roms/x86/Start.txt
    chgrp -R $user $rootdir
    chown -R $user $rootdir    
}

# install PC emulator rpix86
function install_rpix86()
{
    printMsg "Installing PC emulator rpix86"
    
    # install rpix86
    wget http://rpix86.patrickaalto.com/rpix86.tar.gz
    if [[ -d "$rootdir/emulators/rpix86" ]]; then
        rm -rf "$rootdir/emulators/rpix86"
    fi  
    mkdir -p "$rootdir/emulators/rpix86"
    tar xvfz rpix86.tar.gz -C "$rootdir/emulators/rpix86"
    rm rpix86.tar.gz

    # install 4DOS.com
    unzip -n $scriptdir/supplementary/4dos.zip -d "$rootdir/emulators/rpix86/"

    # configure for use with Emulation Station
    configure_rpix86

    chgrp -R $user $rootdir
    chown -R $user $rootdir
}

# install Z Machine emulator
function install_zmachine()
{
    printMsg "Installing Z Machine emulator"
    apt-get install -y frotz
    wget -U firefox http://www.infocom-if.org/downloads/zork1.zip
    wget -U firefox http://www.infocom-if.org/downloads/zork2.zip
    wget -U firefox http://www.infocom-if.org/downloads/zork3.zip
    unzip -n zork1.zip -d "$rootdir/roms/zmachine/zork1/"
    unzip -n zork2.zip -d "$rootdir/roms/zmachine/zork2/"
    unzip -n zork3.zip -d "$rootdir/roms/zmachine/zork3/"
    rm zork1.zip
    rm zork2.zip
    rm zork3.zip
    __INFMSGS="$__INFMSGS The text adventures Zork 1 - 3 have been installed in the directory '$rootdir/roms/zmachine/'. You can start, e.g., Zork 1 with the command 'frotz $rootdir/roms/zmachine/zork1/DATA/ZORK1.DAT'."
}

# Install ZX Spectrum emulator, this function is not used abymore due to segmentation fault errors.
# However, it is kept here for now as a recipe.
function install_zxspectrumFromSource()
{
    printMsg "Installing ZX Spectrum emulator"
    if [[ -d "$rootdir/emulators/zxspectrum" ]]; then
        rm -rf "$rootdir/emulators/zxspectrum"
    fi    
    mkdir -p "$rootdir/emulators/zxspectrum"
    pushd "$rootdir/emulators/zxspectrum"
    wget ftp://ftp.worldofspectrum.org/pub/sinclair/emulators/unix/libspectrum-1.0.0.tar.gz
    wget http://downloads.sourceforge.net/project/fuse-emulator/fuse/1.0.0.1a/fuse-1.0.0.1a.tar.gz
    tar xvfz libspectrum-1.0.0.tar.gz
    cd libspectrum-1.0.0
    ./configure # this yields segmentation fault errors now (20.2.2013)
    make
    make install
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/libspectrum.conf
    ldconfig
    cd ..

    tar xvfz fuse-1.0.0.1a.tar.gz
    cd fuse-1.0.0.1a
    ./configure --with-sdl
    make
    make install
    popd
}

function install_zxspectrum()
{
    printMsg "Installing ZX Spectrum emulator"
    apt-get install -y spectrum-roms fuse-emulator-utils fuse-emulator-common
}

# install BCM library to enable GPIO access by SNESDev-RPi
function install_bcmlibrary()
{
    printMsg "Installing BCM2835 library"
    wget http://www.open.com.au/mikem/bcm2835/bcm2835-1.14.tar.gz
    tar -zxvf bcm2835-1.14.tar.gz
    mkdir -p "$rootdir/supplementary/"
    if [[ -d "$rootdir/supplementary/bcm2835-1.14/" ]]; then
        rm -rf "$rootdir/supplementary/bcm2835-1.14/"
    fi
    mv bcm2835-1.14 $rootdir/supplementary/
    pushd $rootdir/supplementary/bcm2835-1.14
    ./configure
    make clean
    make
    make install
    popd
    rm bcm2835-1.14.tar.gz 
}

# install ScummVM
function install_scummvm()
{
    printMsg "Installing ScummVM"
    apt-get install -y scummvm scummvm-data
    if [[ $? -gt 0 ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully install ScummVM."
    else
        __INFMSGS="$__INFMSGS ScummVM has successfully been installed. You can start the ScummVM GUI by typing 'scummvm' in the console. Copy your Scumm games into the directory '$rootdir/roms/scummvm'. When you get a blank screen after running scumm for the first time, press CTRL-q. You should not get a blank screen with further runs of scummvm."
    fi 
}

# install SNESDev as GPIO interface for SNES controllers
function install_snesdev()
{
    printMsg "Installing SNESDev as GPIO interface for SNES controllers"
    gitPullOrClone "$rootdir/supplementary/SNESDev-Rpi" git://github.com/petrockblog/SNESDev-RPi.git
    make clean
    make
    if [[ ! -f "$rootdir/supplementary/SNESDev-Rpi/SNESDev" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNESDev."  
    else
        service SNESDev stop
        cp "$rootdir/supplementary/SNESDev-Rpi/SNESDev" /usr/local/bin/
    fi    
    popd
}

# start SNESDev on boot and configure RetroArch input settings
function enableSNESDevAtStart()
{
    clear
    printMsg "Enabling SNESDev on boot."

    if [[ ! -f "/etc/init.d/SNESDev" ]]; then
        if [[ ! -f "$rootdir/supplementary/SNESDev-Rpi/SNESDev" ]]; then
            dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Cannot find SNESDev binary. Please install SNESDev." 22 76    
            return
        else
            echo "Copying service script for SNESDev to /etc/init.d/ ..."
            chmod +x "$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev"
            cp "$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev" /etc/init.d/
        fi
    fi
    if [[ ! -f "/usr/local/bin/SNESDev" ]]; then
        echo "Copying SNESDev to /usr/local/bin/ ..."
        cp "$rootdir/supplementary/SNESDev-Rpi/SNESDev" /usr/local/bin/
    fi    

    ensureKeyValueShort "DAEMON_ARGS" "\"$1\"" "/etc/init.d/SNESDev"

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d SNESDev defaults
    # This command starts the daemon now so no need for a reboot
    service SNESDev start

    if [[ ($1 -eq 1) || ($1 -eq 3) ]]; then

        REVSTRING=`cat /proc/cpuinfo |grep Revision | cut -d ':' -f 2 | tr -d ' \n' | tail -c 4`
        case "$REVSTRING" in
              "0002"|"0003")
                 GPIOREV=1 
                 ;;
              *)
                 GPIOREV=2
                 ;;
        esac
        if [ $GPIOREV = 1 ]; then
            ensureKeyValue "input_player1_joypad_index" "0" "$rootdir/configs/all/retroarch.cfg"
            ensureKeyValue "input_player2_joypad_index" "1" "$rootdir/configs/all/retroarch.cfg"
        else
            ensureKeyValue "input_player1_joypad_index" "1" "$rootdir/configs/all/retroarch.cfg"
            ensureKeyValue "input_player2_joypad_index" "0" "$rootdir/configs/all/retroarch.cfg"
        fi

        disableKeyValue "input_enable_hotkey_btn" "6" "$rootdir/configs/all/retroarch.cfg"
        disableKeyValue "input_exit_emulator_btn" "7" "$rootdir/configs/all/retroarch.cfg"
        disableKeyValue "input_rewind_btn" "3" "$rootdir/configs/all/retroarch.cfg"
        disableKeyValue "input_save_state_btn" "4" "$rootdir/configs/all/retroarch.cfg"
        disableKeyValue "input_load_state_btn" "5" "$rootdir/configs/all/retroarch.cfg"    

        ensureKeyValue "input_player1_a_btn" "0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_b_btn" "1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_x_btn" "2" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_y_btn" "3" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_l_btn" "4" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_r_btn" "5" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_start_btn" "7" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_select_btn" "6" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_left_axis" "-0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_right_axis" "+0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_up_axis" "-1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_down_axis" "+1" "$rootdir/configs/all/retroarch.cfg" 
        
        ensureKeyValue "input_player2_a_btn" "0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_b_btn" "1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_x_btn" "2" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_y_btn" "3" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_l_btn" "4" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_r_btn" "5" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_start_btn" "7" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_select_btn" "6" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_left_axis" "-0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_right_axis" "+0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_up_axis" "-1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_down_axis" "+1" "$rootdir/configs/all/retroarch.cfg" 
    fi
}

# disable start SNESDev on boot and remove RetroArch input settings
function disableSNESDevAtStart()
{
    clear
    printMsg "Disabling SNESDev on boot."

    # This command stops the daemon now so no need for a reboot
    service SNESDev stop

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d SNESDev remove

    disableKeyValue "input_enable_hotkey_btn" "6" "$rootdir/configs/all/retroarch.cfg" 
    disableKeyValue "input_exit_emulator_btn" "7" "$rootdir/configs/all/retroarch.cfg" 
    disableKeyValue "input_rewind_btn" "3" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_save_state_btn" "4" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_load_state_btn" "5" "$rootdir/configs/all/retroarch.cfg"    

    disableKeyValue "input_player1_a_btn" "0" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_b_btn" "1" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_x_btn" "2" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_y_btn" "3" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_l_btn" "4" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_r_btn" "5" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_start_btn" "7" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_select_btn" "6" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_left_axis" "-0" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_right_axis" "+0" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_up_axis" "-1" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player1_down_axis" "+1"   "$rootdir/configs/all/retroarch.cfg" 

    disableKeyValue "input_player2_a_btn" "0" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_b_btn" "1" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_x_btn" "2" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_y_btn" "3" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_l_btn" "4" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_r_btn" "5" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_start_btn" "7" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_select_btn" "6" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_left_axis" "-0" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_right_axis" "+0" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_up_axis" "-1" "$rootdir/configs/all/retroarch.cfg"
    disableKeyValue "input_player2_down_axis" "+1" "$rootdir/configs/all/retroarch.cfg" 
}

# Show dialogue for enabling/disabling SNESDev on boot
function enableDisableSNESDevStart()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable SNESDev on boot and SNESDev keyboard mapping."
             2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)."
             3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)."
             4 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button).")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) disableSNESDevAtStart
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Disabled SNESDev on boot." 22 76    
                            ;;
            2) enableSNESDevAtStart 3
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Enabled SNESDev on boot (polling pads and button)." 22 76    
                            ;;
            3) enableSNESDevAtStart 1
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Enabled SNESDev on boot (polling only pads)." 22 76    
                            ;;
            4) enableSNESDevAtStart 2
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Enabled SNESDev on boot (polling only button)." 22 76    
                            ;;
        esac
    else
        break
    fi    
}

# install driver for XBox 360 controllers
function install_xboxdrv()
{
    printMsg "Installing xboxdrv"
    apt-get install -y xboxdrv
    # still to be continued
}

# fix for RaspBMC
function fixForXBian()
{
    echo "/opt/vc/lib" > /etc/ld.so.conf.d/vc.conf    
    ldconfig
}

# a work around here, so that EmulationStation can be executed from arbitrary locations
function install_esscript()
{
    cat > /usr/bin/emulationstation << _EOF_
#!/bin/bash

es_bin="$rootdir/supplementary/EmulationStation/emulationstation"

nb_lock_files=\$(find /tmp -name ".X?-lock" | wc -l)
if [ \$nb_lock_files -ne 0 ]; then
    echo "X is running. Please shut down X in order to mitigate problems with loosing keyboard input. For example, logout from LXDE."
    exit 1
fi

\$es_bin "\$@"
_EOF_
    chmod +x /usr/bin/emulationstation
}

function configure_esconfig()
{
    printMsg "Configuring ES-config"
    cp "$scriptdir/supplementary/settings.xml" "$rootdir/supplementary/ES-config/"
    sed -i -e "s|/home/pi/RetroPie|$rootdir|g" "$rootdir/supplementary/ES-config/settings.xml"
    # generate start script for ES-config
    if [[ ! -d $rootdir/roms/esconfig ]]; then
        mkdir -p $rootdir/roms/esconfig
    fi
    cat > $rootdir/roms/esconfig/Start.sh << _EOF_
#!/bin/bash
pushd $rootdir/supplementary/ES-config
#if you don't supply the "--settings [path]" argument, no settings XML file will be loaded!
./es-config --settings $rootdir/supplementary/ES-config/settings.xml   
popd
_EOF_
chown $user $rootdir/roms/esconfig/Start.sh
chgrp $user $rootdir/roms/esconfig/Start.sh
chmod +x $user $rootdir/roms/esconfig/Start.sh
}

function install_esconfig()
{
    printMsg "Installing ES-config"
    if [[ -d "$rootdir/supplementary/ES-config" ]]; then
        rm -rf "$rootdir/supplementary/ES-config"
    fi 
    gitPullOrClone "$rootdir/supplementary/ES-config" git://github.com/Aloshi/ES-config.git
    sed -i -e "s/apt-get install/apt-get install -y/g" get_dependencies.sh
    ./get_dependencies.sh
    make
    popd
    configure_esconfig()

    if [[ ! -f "$rootdir/supplementary/ES-config/es-config" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile ES-config."
    fi
}

# install EmulationStation as graphical front end for the emulators
function install_emulationstation()
{
    printMsg "Installing EmulationStation as graphical front end"
    gitPullOrClone "$rootdir/supplementary/EmulationStation" git://github.com/Aloshi/EmulationStation.git
    #ES requires C++11 support to build, which means g++ 4.7 or later, which isn't what g++ resolves to right now
    rm -rf CMakeFiles
    rm CMakeCache.txt
    export CXX=g++-4.7 
    cmake .
    make
    unset CXX
    install_esscript    
    if [[ ! -f "$rootdir/supplementary/EmulationStation/emulationstation" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Emulation Station."
    fi      

    if [[ ! -f /usr/lib/libEGL.so ]]; then
        ln -fs /opt/vc/lib/libEGL.so /usr/lib/libEGL.so
    fi
    if [[ ! -f /usr/lib/libEGL.so ]]; then
        ln -fs /opt/vc/lib/libEGL.so /usr/lib/libEGL.so
    fi
    if [[ ! -f /usr/lib/libEGL.so ]]; then
        ln -fs /opt/vc/lib/libEGL.so /usr/lib/libEGL.so
    fi

    popd
}

# generate EmulationStation configuration
function generate_esconfig()
{
    printMsg "Generating configuration file ~/.emulationstation/es_systems.cfg for EmulationStation"
    if [[ ! -d "$rootdir/../.emulationstation" ]]; then
        mkdir "$rootdir/../.emulationstation"
    fi
    cat > "$rootdir/../.emulationstation/es_systems.cfg" << _EOF_
DESCNAME=Apple ][
NAME=apple2
PATH=$rootdir/roms/apple2
EXTENSION=.txt
COMMAND=$rootdir/emulators/linapple-src_2a/Start.sh

DESCNAME=Atari 2600
NAME=atari2600
PATH=$rootdir/roms/atari2600
EXTENSION=.a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "stella %ROM%"
# alternatively: COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/atari2600/retroarch.cfg %ROM%"
PLATFORMID=22

DESCNAME=Basilisk II
NAME=basiliskii
PATH=$rootdir/roms/basiliskii
EXTENSION=.txt
COMMAND=sudo modprobe snd_pcm_oss && xinit $rootdir/emulators/basiliskii/installdir/bin/BasiliskII
# Or possibly just COMMAND=xinit $rootdir/emulators/basiliskii/installdir/bin/BasiliskII

DESCNAME=Cave Story
NAME=cavestory
PATH=$rootdir/roms/cavestory
EXTENSION=.txt
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/nxengine-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/cavestory/retroarch.cfg $rootdir/emulatorcores/nxengine-libretro/datafiles/Doukutsu.exe"

DESCNAME=C64
NAME=c64
PATH=$rootdir/roms/c64
EXTENSION=.crt .CRT .d64 .D64 .g64 .G64 .t64 .T64 .tap .TAP .x64 .X64 .zip .ZIP
COMMAND=$rootdir/emulators/vice-2.3.dfsg/installdir/bin/x64 %ROM%
PLATFORMID=40

DESCNAME=Doom
NAME=doom
PATH=$rootdir/roms/doom
EXTENSION=.WAD .wad
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/libretro-prboom/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/doom/retroarch.cfg %ROM%"
PLATFORMID=1

DESCNAME=Duke Nukem 3D
NAME=duke3d
PATH=$rootdir/roms/duke3d
EXTENSION=.grp .GRP
COMMAND=eduke32 -g %ROM% -gamegrp %ROM%
PLATFORMID=1

DESCNAME=Game Boy
NAME=gb
PATH=$rootdir/roms/gb
EXTENSION=.gb .GB
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/gambatte-libretro/libgambatte/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gb/retroarch.cfg %ROM%"
PLATFORMID=4

DESCNAME=Game Boy Advance
NAME=gba
PATH=$rootdir/roms/gba
EXTENSION=.gba .GBA
COMMAND=/home/pi/RetroPie/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/gpsp/raspberrypi/gpsp %ROM%"
PLATFORMID=5

DESCNAME=Game Boy Color
NAME=gbc
PATH=$rootdir/roms/gbc
EXTENSION=.gbc .GBC
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/gambatte-libretro/libgambatte/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gbc/retroarch.cfg %ROM%"
PLATFORMID=41

DESCNAME=Sega Game Gear
NAME=gamegear
PATH=$rootdir/roms/gamegear
EXTENSION=.gg .GG
COMMAND=$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose %ROM% -joy -tv -fs
PLATFORMID=20

DESCNAME=Intellivision
NAME=intellivision
PATH=$rootdir/roms/intellivision
EXTENSION=.int .INT .bin .BIN
COMMAND=$rootdir/emulators/jzintv-1.0-beta4/bin/jzintv -z1 -f1 -q %ROM%
PLATFORMID=32

DESCNAME=MAME
NAME=mame
PATH=$rootdir/roms/mame
EXTENSION=.zip .ZIP
COMMAND=retroarch -L `find $rootdir/emulatorcores/imame4all-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/mame/retroarch.cfg %ROM% 
PLATFORMID=23

DESCNAME=FinalBurn Alpha
NAME=fba
PATH=$rootdir/roms/fba
EXTENSION=.zip .ZIP
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/fba-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/fba/retroarch.cfg %ROM%"
PLATFORMID=23

DESCNAME=PC (x86)
NAME=x86
PATH=$rootdir/roms/x86
EXTENSION=.txt
COMMAND=$rootdir/emulators/rpix86/Start.sh
PLATFORMID=1

DESCNAME=ScummVM
NAME=scummvm
PATH=$rootdir/roms/scummvm
EXTENSION=.exe .EXE
COMMAND=scummvm
PLATFORMID=20

DESCNAME=Sega Master System II
NAME=mastersystem
PATH=$rootdir/roms/mastersystem
EXTENSION=.sms .SMS
COMMAND=$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose %ROM% -joy -tv -fs
PLATFORMID=35

DESCNAME=Sega Mega Drive / Genesis
NAME=megadrive
PATH=$rootdir/roms/megadrive
EXTENSION=.smd .SMD
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/dgen-sdl/dgen -f -r $rootdir/configs/all/dgenrc %ROM%"
# alternatively: COMMAND=export LD_LIBRARY_PATH="$rootdir/supplementary/dispmanx/SDL12-kms-dispmanx/build/.libs"; $rootdir/emulators/dgen-sdl/dgen %ROM%
PLATFORMID=18

DESCNAME=NeoGeo
NAME=neogeo
PATH=$rootdir/roms/neogeo
EXTENSION=.zip .ZIP
COMMAND=$rootdir/emulators/gngeo-pi-0.85/installdir/bin/arm-linux-gngeo -i $rootdir/roms/neogeo -B $rootdir/emulators/gngeo-pi-0.85/neogeobios %ROM%
PLATFORMID=24

DESCNAME=Nintendo Entertainment System
NAME=nes
PATH=$rootdir/roms/nes
EXTENSION=.nes .NES
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/fceu-next/fceumm-code/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/nes/retroarch.cfg %ROM%"
PLATFORMID=7

DESCNAME=PC Engine/TurboGrafx 16
NAME=pcengine
PATH=$rootdir/roms/pcengine
EXTENSION=.pce
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/mednafen-pce-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/pcengine/retroarch.cfg %ROM%"
PLATFORMID=34

DESCNAME=Sony Playstation 1
NAME=psx
PATH=$rootdir/roms/psx
EXTENSION=.img .IMG .7z .7Z .pbp .PBP .bin .BIN
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/psx/retroarch.cfg %ROM%"
PLATFORMID=10

DESCNAME=Playstation Portable
NAME=psp
PATH=$rootdir/roms/psp
EXTENSION=.iso .ISO .cso .CSO
COMMAND=$rootdir/emulators/ppsspp/PPSSPPSDL %ROM% en
PLATFORMID=13

DESCNAME=Super Nintendo
NAME=snes
PATH=$rootdir/roms/snes
EXTENSION=.smc .sfc .fig .swc .SMC .SFC .FIG .SWC
COMMAND=$rootdir/supplementary/runcommand/runcommand.sh 1 "retroarch -L `find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/snes/retroarch.cfg %ROM%"
# alternatively: COMMAND=$rootdir/emulators/snes9x-rpi/snes9x %ROM%
# alternatively: COMMAND=$rootdir/emulators/pisnes/snes9x %ROM%
PLATFORMID=6

DESCNAME=ZX Spectrum
NAME=zxspectrum
PATH=$rootdir/roms/zxspectrum
EXTENSION=.z80 .Z80
COMMAND=xinit fuse

DESCNAME=Input Configuration
NAME=esconfig
PATH=$rootdir/roms/esconfig
EXTENSION=.sh .SH
COMMAND=$rootdir/roms/esconfig/Start.sh
_EOF_

chown -R $user "$rootdir/../.emulationstation"
chgrp -R $user "$rootdir/../.emulationstation"

}

# sorts ROMs alphabetically. Users reported issues with that, so that it is disbaled in the menu for now. Needs to be debugged
function sortromsalphabet()
{
    clear
    pathlist=()
    pathlist+=("$rootdir/roms/amiga")
    pathlist+=("$rootdir/roms/atari2600")
    pathlist+=("$rootdir/roms/fba")
    pathlist+=("$rootdir/roms/gamegear")
    pathlist+=("$rootdir/roms/gb")
    pathlist+=("$rootdir/roms/gba")
    pathlist+=("$rootdir/roms/gbc")
    pathlist+=("$rootdir/roms/intellivision")
    pathlist+=("$rootdir/roms/mame")
    pathlist+=("$rootdir/roms/mastersystem")
    pathlist+=("$rootdir/roms/megadrive")
    pathlist+=("$rootdir/roms/neogeo")
    pathlist+=("$rootdir/roms/nes")
    pathlist+=("$rootdir/roms/snes")
    pathlist+=("$rootdir/roms/pcengine")
    pathlist+=("$rootdir/roms/psx")
    pathlist+=("$rootdir/roms/zxspectrum")
    printMsg "Sorting roms alphabetically"
    for elem in "${pathlist[@]}"
    do
        echo "Sorting roms in folder $elem"
        if [[ -d $elem ]]; then
            for x in {a..z}
            do
                if [[ ! -d $elem/$x ]]; then
                    mkdir $elem/$x
                fi
                find $elem -maxdepth 1 -type f -iname "$x*"| while read line; do
                    mv "$line" "$elem/$x/$(basename "${line,,}")"
                done
            done
            if [[ -f "$elem/g/gamelist.xml" ]]; then
                mv "$elem/g/gamelist.xml" "$elem/gamelist.xml"
            fi
            if [[ -f "$elem/t/theme.xml" ]]; then
                mv "$elem/t/theme.xml" "$elem/theme.xml"
            fi
            if [[ ! -d "$elem/#" ]]; then
                mkdir "$elem/#"
            fi
            find $elem -maxdepth 1 -type f -iname "[0-9]*"| while read line; do
                mv "$line" "$elem/#/$(basename "${line,,}")"
            done
        fi
    done  
    chgrp -R $user $rootdir/roms
    chown -R $user $rootdir/roms
}

# downloads and installs pre-compiles binaries of all essential programs and libraries
function downloadBinaries()
{
    wget -O binariesDownload.tar.bz2 http://blog.petrockblock.com/?wpdmdl=3
    tar -jxvf binariesDownload.tar.bz2 -C $rootdir
    pushd $rootdir/RetroPie
    cp -r * ../
    popd

    # handle Doom emulator specifics
    cp $rootdir/emulatorcores/libretro-prboom/prboom.wad $rootdir/roms/doom/
    chgrp $user $rootdir/roms/doom/prboom.wad
    chown $user $rootdir/roms/doom/prboom.wad

    rm -rf $rootdir/RetroPie
    rm binariesDownload.tar.bz2    
}

# downloads and installs theme files for Emulation Station
function install_esthemes()
{
    printMsg "Installing themes for Emulation Station"
    wget -O themesDownload.tar.bz2 http://blog.petrockblock.com/?wpdmdl=2
    tar -jxvf themesDownload.tar.bz2 -C $home/

    chgrp -R $user $home/.emulationstation
    chown -R $user $home/.emulationstation

    rm themesDownload.tar.bz2
}

# sets the ARM frequency of the Raspberry to a specific value
function setArmFreq()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose the ARM frequency. However, it is suggested that you change this with the raspi-config script!" 22 76 16)
    options=(700 "(default)"
             750 "(do this at your own risk!)"
             800 "(do this at your own risk!)"
             850 "(do this at your own risk!)"
             900 "(do this at your own risk!)"
             1000 "(do this at your own risk!)")
    armfreqchoice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$armfreqchoice" != "" ]; then                
        if [[ -z $(egrep -i "#? *arm_freq=[0-9]*" /boot/config.txt) ]]; then
            # add key-value pair
            echo "arm_freq=$armfreqchoice" >> /boot/config.txt
        else
            # replace existing key-value pair
            toreplace=`egrep -i "#? *arm_freq=[0-9]*" /boot/config.txt`
            sed /boot/config.txt -i -e "s|$toreplace|arm_freq=$armfreqchoice|g"
        fi 
        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "ARM frequency set to $armfreqchoice MHz. If you changed the frequency, you need to reboot." 22 76    
    fi
}

# sets the SD ram frequency of the Raspberry to a specific value
function setSDRAMFreq()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose the ARM frequency. However, it is suggested that you change this with the raspi-config script!" 22 76 16)
    options=(400 "(default)"
             425 "(do this at your own risk!)"
             450 "(do this at your own risk!)"
             475 "(do this at your own risk!)"
             500 "(do this at your own risk!)")
    sdramfreqchoice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$sdramfreqchoice" != "" ]; then                
        if [[ -z $(egrep -i "#? *sdram_freq=[0-9]*" /boot/config.txt) ]]; then
            # add key-value pair
            echo "sdram_freq=$sdramfreqchoice" >> /boot/config.txt
        else
            # replace existing key-value pair
            toreplace=`egrep -i "#? *sdram_freq=[0-9]*" /boot/config.txt`
            sed /boot/config.txt -i -e "s|$toreplace|sdram_freq=$sdramfreqchoice|g"
        fi 
        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "SDRAM frequency set to $sdramfreqchoice MHz. If you changed the frequency, you need to reboot." 22 76    
    fi
}

# configure sound settings
function configureSoundsettings()
{
    printMsg "Enabling ALSA thread-based audio driver for RetroArch in $rootdir/configs/all/retroarch.cfg"    

    # RetroArch settings
    ensureKeyValue "audio_driver" "alsathread" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "audio_out_rate" "48000" "$rootdir/configs/all/retroarch.cfg"

    # ALSA settings
    mv /etc/asound.conf /etc/asound.conf.bak
    cat >> /etc/asound.conf << _EOF_
pcm.!default {
type hw
card 0
}

ctl.!default {
type hw
card 0
}
_EOF_

}

# Disables safe mode (http://www.raspberrypi.org/phpBB3/viewtopic.php?p=129413) in order to make GPIO adapters work
function setAvoidSafeMode()
{  
    printMsg "Setting avoid_safe_mode=1"
    ensureKeyValueBootconfig "avoid_safe_mode" 1 "/boot/config.txt"
}

# shows help information in the console
function showHelp()
{
    echo ""
    echo "RetroPie Setup script"
    echo "====================="
    echo ""
    echo "The script installs the RetroArch emulator base with various cores and a graphical front end."
    echo "Because it needs to install some APT packages it has to be run with root priviliges."
    echo ""
    echo "Usage:"
    echo "sudo ./retropie_setup.sh: The installation directory is /home/pi/RetroPie for user pi"
    echo "sudo ./retropie_setup.sh USERNAME: The installation directory is /home/USERNAME/RetroPie for user USERNAME"
    echo "sudo ./retropie_setup.sh USERNAME ABSPATH: The installation directory is ABSPATH for user USERNAME"
    echo ""
}

# Start Emulation Station on boot or not?
function changeBootbehaviour()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose the desired boot behaviour." 22 76 16)
    options=(1 "Original boot behaviour"
             2 "Start Emulation Station at boot.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) sed /etc/inittab -i -e "s|1:2345:respawn:/bin/login -f $user tty1 </dev/tty1 >/dev/tty1 2>&1|1:2345:respawn:/sbin/getty --noclear 38400 tty1|g"
               sed /etc/profile -i -e "/emulationstation/d"
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Enabled original boot behaviour. ATTENTION: If you still have the custom splash screen enabled (via this script), you need to jump between consoles after booting via Ctrl+Alt+F2 and Ctrl+Alt+F1 to see the login prompt. You can restore the original boot behavior of the RPi by disabling the custom splash screen with this script." 22 76    
                            ;;
            2) sed /etc/inittab -i -e "s|1:2345:respawn:/sbin/getty --noclear 38400 tty1|1:2345:respawn:\/bin\/login -f $user tty1 \<\/dev\/tty1 \>\/dev\/tty1 2\>\&1|g"
               update-rc.d lightdm disable 2 # taken from /usr/bin/raspi-config
               if [ -z $(egrep -i "emulationstation$" /etc/profile) ]
               then
                   echo "[ -n \"\${SSH_CONNECTION}\" ] || emulationstation" >> /etc/profile
               fi
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Emulation Station is now starting on boot." 22 76    
                            ;;
        esac
    else
        break
    fi    
}

function installGPIOpadModules()
{
    GAMECON_VER=0.9
    DB9_VER=0.7
    DOWNLOAD_LOC=http://www.niksula.hut.fi/~mhiienka/Rpi

    clear

    dialog --title " GPIO gamepad drivers installation " --clear \
    --yesno "GPIO gamepad drivers require that most recent kernel (firmware)\
    is installed and active. Continue with installation?" 22 76
    case $? in
      0)
        echo "Starting installation.";;
      *)
        return 0;;
    esac

    #install dkms
    apt-get install -y dkms

    #reconfigure / install headers (takes a a while)
    if [ "$(dpkg-query -W -f='${Version}' linux-headers-$(uname -r))" = "$(uname -r)-2" ]; then
        dpkg-reconfigure linux-headers-`uname -r`
    else
        wget ${DOWNLOAD_LOC}/linux-headers-rpi/linux-headers-`uname -r`_`uname -r`-2_armhf.deb
        dpkg -i linux-headers-`uname -r`_`uname -r`-2_armhf.deb
        rm linux-headers-`uname -r`_`uname -r`-2_armhf.deb
    fi

    #install gamecon
    if [ "`dpkg-query -W -f='${Version}' gamecon-gpio-rpi-dkms`" = ${GAMECON_VER} ]; then
        #dpkg-reconfigure gamecon-gpio-rpi-dkms
        echo "gamecon is the newest version"
    else
        wget ${DOWNLOAD_LOC}/gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb
        dpkg -i gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb
        rm gamecon-gpio-rpi-dkms_${GAMECON_VER}_all.deb
    fi

    #install db9 joystick driver
    if [ "`dpkg-query -W -f='${Version}' db9-gpio-rpi-dkms`" = ${DB9_VER} ]; then
        echo "db9 is the newest version"
    else
        wget ${DOWNLOAD_LOC}/db9-gpio-rpi-dkms_${DB9_VER}_all.deb
        dpkg -i db9-gpio-rpi-dkms_${DB9_VER}_all.deb
        rm db9-gpio-rpi-dkms_${DB9_VER}_all.deb
    fi

    #test if gamecon installation is OK
    if [[ -n $(modinfo -n gamecon_gpio_rpi | grep gamecon_gpio_rpi.ko) ]]; then
            dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Gamecon GPIO driver successfully installed. \
        Use 'zless /usr/share/doc/gamecon_gpio_rpi/README.gz' to read how to use it." 22 76
    else
        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Gamecon GPIO driver installation FAILED"\
        22 76
    fi

    #test if db9 installation is OK
    if [[ -n $(modinfo -n db9_gpio_rpi | grep db9_gpio_rpi.ko) ]]; then
            dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Db9 GPIO driver successfully installed. \
        Use 'zless /usr/share/doc/db9_gpio_rpi/README.gz' to read how to use it." 22 76
    else
        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Db9 GPIO driver installation FAILED"\
        22 76
    fi
}

# install runcommand script for switching video modes
function install_runcommandscript()
{
    printMsg "Installing script for setting video mode."
    mkdir -p "$rootdir/supplementary/runcommand/"
    cp $scriptdir/supplementary/runcommand.sh "$rootdir/supplementary/runcommand/"
    chmod +x "$rootdir/supplementary/runcommand/runcommand.sh"
    chown -R $user $rootdir
    chgrp -R $user $rootdir
}

function enableGameconSnes()
{
    if [ "`dpkg-query -W -f='${Status}' gamecon-gpio-rpi-dkms`" != "install ok installed" ]; then
        dialog --msgbox "gamecon_gpio_rpi not found, install it first" 22 76
        return 0
    fi

    REVSTRING=`cat /proc/cpuinfo |grep Revision | cut -d ':' -f 2 | tr -d ' \n' | tail -c 4`
    case "$REVSTRING" in
          "0002"|"0003")
             GPIOREV=1 
             ;;
          *)
             GPIOREV=2
             ;;
    esac

dialog --msgbox "\
__________\n\
         |          ### Board gpio revision $GPIOREV detected ###\n\
    + *  |\n\
    * *  |\n\
    1 -  |          The driver is set to use the following configuration\n\
    2 *  |          for 2 SNES controllers:\n\
    * *  |\n\
    * *  |\n\
    * *  |          + = power\n\
    * *  |          - = ground\n\
    * *  |          C = clock\n\
    C *  |          L = latch\n\
    * *  |          1 = player1 pad\n\
    L *  |          2 = player2 pad\n\
    * *  |          * = unconnected\n\
         |\n\
         |" 22 76

    if [[ -n $(lsmod | grep gamecon_gpio_rpi) ]]; then
        rmmod gamecon_gpio_rpi
    fi

    if [ $GPIOREV = 1 ]; then
        modprobe gamecon_gpio_rpi map=0,1,1,0
    else
        modprobe gamecon_gpio_rpi map=0,0,1,0,0,1
    fi

    dialog --title " Update $rootdir/configs/all/retroarch.cfg " --clear \
        --yesno "Would you like to update button mappings \
    to $rootdir/configs/all/retroarch.cfg ?" 22 76

      case $? in
       0)
    if [ $GPIOREV = 1 ]; then
            ensureKeyValue "input_player1_joypad_index" "0" "$rootdir/configs/all/retroarch.cfg"
            ensureKeyValue "input_player2_joypad_index" "1" "$rootdir/configs/all/retroarch.cfg"
    else
        ensureKeyValue "input_player1_joypad_index" "1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_joypad_index" "0" "$rootdir/configs/all/retroarch.cfg"
    fi

        ensureKeyValue "input_player1_a_btn" "0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_b_btn" "1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_x_btn" "2" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_y_btn" "3" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_l_btn" "4" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_r_btn" "5" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_start_btn" "7" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_select_btn" "6" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_left_axis" "-0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_up_axis" "-1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_right_axis" "+0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player1_down_axis" "+1" "$rootdir/configs/all/retroarch.cfg"

        ensureKeyValue "input_player2_a_btn" "0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_b_btn" "1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_x_btn" "2" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_y_btn" "3" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_l_btn" "4" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_r_btn" "5" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_start_btn" "7" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_select_btn" "6" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_left_axis" "-0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_up_axis" "-1" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_right_axis" "+0" "$rootdir/configs/all/retroarch.cfg"
        ensureKeyValue "input_player2_down_axis" "+1" "$rootdir/configs/all/retroarch.cfg"
    ;;
       *)
        ;;
      esac

    dialog --title " Enable SNES configuration permanently " --clear \
        --yesno "Would you like to permanently enable SNES configuration?\
        " 22 76

    case $? in
      0)
    if [[ -z $(cat /etc/modules | grep gamecon_gpio_rpi) ]]; then
    if [ $GPIOREV = 1 ]; then
                addLineToFile "gamecon_gpio_rpi map=0,1,1,0" "/etc/modules"
    else
        addLineToFile "gamecon_gpio_rpi map=0,0,1,0,0,1" "/etc/modules"
    fi
    fi
    ;;
      *)
        #TODO: delete the line from /etc/modules
        ;;
    esac

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox \
    "Gamecon GPIO driver enabled with 2 SNES pads." 22 76
}

function install_USBROMService()
{
    clear
    printMsg "Installing USB-ROM Service"

    # install usbmount package
    apt-get install -y usbmount

    # install hook in usbmount sub-directory
    cp $scriptdir/supplementary/01_retropie_copyroms /etc/usbmount/mount.d/
    sed -i -e "s/USERTOBECHOSEN/$user/g" /etc/usbmount/mount.d/01_retropie_copyroms
    chmod +x /etc/usbmount/mount.d/01_retropie_copyroms
}

function checkNeededPackages()
{
    doexit=0
    type -P git &>/dev/null && echo "Found git command." || { echo "Did not find git. Try 'sudo apt-get install -y git' first."; doexit=1; }
    type -P dialog &>/dev/null && echo "Found dialog command." || { echo "Did not find dialog. Try 'sudo apt-get install -y dialog' first."; doexit=1; }
    if [[ $doexit -eq 1 ]]; then
        exit 1
    fi
}

function checkESScraperExists()
{
    if [[ ! -d $rootdir/supplementary/ES-scraper ]]; then
        # new download
        git clone git://github.com/elpendor/ES-scraper.git "$rootdir/supplementary/ES-scraper"
    else
        # update
        pushd $rootdir/supplementary/ES-scraper
        git pull
        popd
    fi
    chgrp -R $user "$rootdir/supplementary/ES-scraper"
    chown -R $user "$rootdir/supplementary/ES-scraper"
}

function essc_runnormal()
{
    checkESScraperExists
    python $rootdir/supplementary/ES-scraper/scraper.py -w $esscrapimgw
    chgrp -R $user "$rootdir/roms"
    chown -R $user "$rootdir/roms"
}

function essc_runforced()
{
    checkESScraperExists
    python $rootdir/supplementary/ES-scraper/scraper.py -f -w $esscrapimgw
    chgrp -R $user "$rootdir/roms"
    chown -R $user "$rootdir/roms"
}

function essc_runmanual()
{
    checkESScraperExists
    python $rootdir/supplementary/ES-scraper/scraper.py -m -w $esscrapimgw
    chgrp -R $user "$rootdir/roms"
    chown -R $user "$rootdir/roms"
}

function essc_runcrc()
{
    checkESScraperExists
    python $rootdir/supplementary/ES-scraper/scraper.py -crc -w $esscrapimgw
    chgrp -R $user "$rootdir/roms"
    chown -R $user "$rootdir/roms"
}

function essc_runpartial()
{
    checkESScraperExists
    python $rootdir/supplementary/ES-scraper/scraper.py -p -w $esscrapimgw
    chgrp -R $user "$rootdir/roms"
    chown -R $user "$rootdir/roms"
}

function essc_setimgw()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --inputbox "Please enter the maximum image width in pixels." 22 76 16)
    choices=$("${cmd[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        esscrapimgw=$choices
    else
        break
    fi
}

function main_reboot()
{
    clear
    reboot    
}

# checks all kinds of essential files for existence and logs the results into the file debug.log
function createDebugLog()
{
    clear
    printMsg "Generating debug log"

    echo "RetroArch files:" > "$rootdir/debug.log"

    # existence of files
    checkFileExistence "/usr/local/bin/retroarch"
    checkFileExistence "/usr/local/bin/retroarch-zip"
    checkFileExistence "$rootdir/configs/all/retroarch.cfg"
    echo -e "\nActive lines in $rootdir/configs/all/retroarch.cfg:" >> "$rootdir/debug.log"
    sed '/^$\|^#/d' "$rootdir/configs/all/retroarch.cfg"  >>  "$rootdir/debug.log"

    echo -e "\nEmulation Station files:" >> "$rootdir/debug.log"
    checkFileExistence "$rootdir/supplementary/EmulationStation/emulationstation"
    checkFileExistence "$rootdir/../.emulationstation/es_systems.cfg"
    checkFileExistence "$rootdir/../.emulationstation/es_input.cfg"
    echo -e "\nContent of es_systems.cfg:" >> "$rootdir/debug.log"
    cat "$rootdir/../.emulationstation/es_systems.cfg" >> "$rootdir/debug.log"
    echo -e "\nContent of es_input.cfg:" >> "$rootdir/debug.log"
    cat "$rootdir/../.emulationstation/es_input.cfg" >> "$rootdir/debug.log"

    echo -e "\nEmulators and cores:" >> "$rootdir/debug.log"
    checkFileExistence "`find $rootdir/emulatorcores/fceu-next/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/libretro-prboom/ -name "*libretro*.so"`"
    checkFileExistence "$rootdir/emulatorcores/libretro-prboom/prboom.wad"
    checkFileExistence "`find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/nxengine-libretro/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/gambatte-libretro/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/Genesis-Plus-GX/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/fba-libretro/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/mednafen-pce-libretro/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so"`"
    checkFileExistence "`find $rootdir/emulatorcores/vba-next/ -name "*libretro*.so"`"
    checkFileExistence "$rootdir/emulatorcors/uae4all/uae4all"

    echo -e "\nSNESDev:" >> "$rootdir/debug.log"
    checkFileExistence "$rootdir/supplementary/SNESDev-Rpi/bin/SNESDev"

    echo -e "\nSummary of ROMS directory:" >> "$rootdir/debug.log"
    du -ch --max-depth=1 "$rootdir/roms/" >> "$rootdir/debug.log"

    echo -e "\nUnrecognized ROM extensions:" >> "$rootdir/debug.log"
    find "$rootdir/roms/amiga/" -type f ! \( -iname "*.adf" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/atari2600/" -type f ! \( -iname "*.bin" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/doom/" -type f ! \( -iname "*.WAD" -or -iname "*.jpg" -or -iname "*.xml" -or -name "*.wad" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/fba/" -type f ! \( -iname "*.zip" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/gamegear/" -type f ! \( -iname "*.gg" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/gba/" -type f ! \( -iname "*.gba" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/gbc/" -type f ! \( -iname "*.gb" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/mame/" -type f ! \( -iname "*.zip" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/mastersystem/" -type f ! \( -iname "*.sms" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/megadrive/" -type f ! \( -iname "*.smd" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/nes/" -type f ! \( -iname "*.nes" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/pcengine/" -type f ! \( -iname "*.iso" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/psx/" -type f ! \( -iname "*.img" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/snes/" -type f ! \( -iname "*.smc" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"

    echo -e "\nCheck for needed APT packages:" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libsdl1.2-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "screen" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "scons" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libasound2-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "pkg-config" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libgtk2.0-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libboost-filesystem-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libboost-system-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "zip" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libxml2" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libxml2-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libbz2-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "python-imaging" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libfreeimage-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libfreetype6-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libaudiofile-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libsdl-sound1.2-dev" >> "$rootdir/debug.log"
    checkForInstalledAPTPackage "libsdl-mixer1.2-dev" >> "$rootdir/debug.log"

    echo -e "\nEnd of log file" >> "$rootdir/debug.log" >> "$rootdir/debug.log"

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Debug log was generated in $rootdir/debug.log" 22 76    

}

# download, extract, and install binaries
function main_binaries()
{
    __INFMSGS=""

    clear
    printMsg "Binaries-based installation"

    # install_rpiupdate, not done anymore, but rely on apt-get upgrade here
    update_apt
    upgrade_apt
    # run_rpiupdate, not done anymore, but rely on apt-get upgrade here
    installAPTPackages
    ensure_modules
    add_to_groups
    exportSDLNOMOUSE
    prepareFolders
    downloadBinaries
    install_esscript
    generate_esconfig
    fixForXBian
    
    # install RetroArch
    install -m755 $rootdir/emulators/RetroArch/retroarch /usr/local/bin
    install -m644 $rootdir/emulators/RetroArch/retroarch.cfg /etc/retroarch.cfg
    install -m755 $rootdir/emulators/RetroArch/retroarch-zip /usr/local/bin
    configureRetroArch
    configure_snes
    install_esthemes
    configureSoundsettings
    install_stella
    install_scummvm
    install_zmachine
    install_zxspectrum
    install_c64roms    

    # install DGEN
    test -z "/usr/local/bin" || /bin/mkdir -p "/usr/local/bin"
    /usr/bin/install -c $rootdir/emulators/dgen-sdl/installdir/usr/local/bin/dgen $rootdir/emulators/dgen-sdl/installdir/usr/local/bin/dgen_tobin '/usr/local/bin'
    test -z "/usr/local/share/man/man1" || /bin/mkdir -p "/usr/local/share/man/man1"
    /usr/bin/install -c -m 644 $rootdir/emulators/dgen-sdl/installdir/usr/local/share/man/man1/dgen.1 $rootdir/emulators/dgen-sdl/installdir/usr/local/share/man/man1/dgen_tobin.1 '/usr/local/share/man/man1'
    test -z "/usr/local/share/man/man5" || /bin/mkdir -p "/usr/local/share/man/man5"
    /usr/bin/install -c -m 644 $rootdir/emulators/dgen-sdl/installdir/usr/local/share/man/man5/dgenrc.5 '/usr/local/share/man/man5'
    configureDGEN
    configure_advmame
    configure_cavestory
    configure_linapple
    install_eduke32
    configure_rpix86
    configure_esconfig
    configure_doom

    chgrp -R $user $rootdir
    chown -R $user $rootdir

    setAvoidSafeMode
    install_runcommandscript

    createDebugLog

    __INFMSGS="$__INFMSGS The Amiga emulator can be started from command line with '$rootdir/emulators/uae4all/uae4all'. Note that you must manually copy a Kickstart rom with the name 'kick.rom' to the directory $rootdir/emulators/uae4all/."
    __INFMSGS="$__INFMSGS You need to copy NeoGeo BIOS files to the folder '$rootdir/emulators/gngeo-0.7/neogeo-bios/'."
    __INFMSGS="$__INFMSGS You need to copy Intellivision BIOS files to the folder '/usr/local/share/jzintv/rom'."

    if [[ ! -z $__INFMSGS ]]; then
        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "$__INFMSGS" 20 60    
    fi

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 22 76    
}

function main_updatescript()
{
  scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  pushd $scriptdir
  if [[ ! -d .git ]]; then
    dialog --backtitle "PetRockBlock.com - RetroPie Setup." --msgbox "Cannot find direcotry '.git'. Please clone the RetroPie Setup script via 'git clone git://github.com/petrockblog/RetroPie-Setup.git'" 20 60    
    popd
    return
  fi
  git pull
  popd
  dialog --backtitle "PetRockBlock.com - ORetroPie Setup." --msgbox "Fetched the latest version of the RetroPie Setup script. You need to restart the script." 20 60    
}

##################
## menus #########
##################

function scraperMenu()
{
    while true; do
        cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose task." 22 76 16)
        options=(1 "(Re-)scape of the ROMs directory" 
                 2 "FORCED (re-)scrape of the ROMs directory" 
                 3 "(Re-)scrape of the ROMs directory with CRC option" 
                 4 "(Re-)scrape of the ROMs directory in MANUAL mode" 
                 5 "(Re-)scrape of the ROMs directory in PARTIAL mode"
                 6 "Set maximum width of images (currently: $esscrapimgw px)" )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
        if [ "$choices" != "" ]; then
            clear
            case $choices in
                1) essc_runnormal ;;
                2) essc_runforced ;;
                3) essc_runcrc ;;
                4) essc_runmanual ;;
                5) essc_runpartial ;;
                6) essc_setimgw ;;
            esac
        else
            break
        fi
    done        
}

function main_options()
{
    cmd=(dialog --separate-output --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --checklist "Select options with 'space' and arrow keys. The default selection installs a complete set of packages and configures basic settings. The entries marked as (C) denote the configuration steps. For an update of an installation you would deselect these to keep all your settings untouched." 22 76 16)
    options=(1 "Install latest rpi-update script" ON     # any option can be set to default to "on"
             2 "Update firmware with rpi-update" OFF \
             3 "Update APT repositories" ON \
             4 "Perform APT upgrade" ON \
             5 "Apply fix for XBian (Neede to make components compile properly)" ON \
             6 "(C) Add user $user to groups video, audio, and input" ON \
             7 "(C) Enable modules ALSA, uinput, and joydev" ON \
             8 "(C) Export SDL_NOMOUSE=1" ON \
             9 "Install all needed APT packages" ON \
             10 "(C) Generate folder structure" ON \
             11 "Install RetroArch" ON \
             12 "(C) Configure video, rewind, and keyboard for RetroArch" ON \
             13 "Install Amiga emulator" ON \
             14 "Install Apple ][ emulator (Linapple)" ON \
             15 "Install Atari 2600 RetroArch core" ON \
             16 "Install Atari 2600 emulator Stella" ON \
             17 "Install BasiliskII" ON \
             18 "Install C64 emulator (Vice)" ON \
             19 "Install NXEngine / Cave Story" ON \
             20 "Install Doom core" ON \
             21 "Install eDuke32 with shareware files" ON \
             22 "Install Game Boy Advance emulator (gpSP)" ON \
             23 "Install Game Boy Color core" ON \
             24 "Install IntelliVision emulator (jzintv)" ON \
             25 "Install MAME (iMAME4All) core" ON \
             26 "Install AdvMAME emulator" ON \
             27 "Install FBA core" ON \
             28 "Install Mastersystem/Game Gear/Megadrive emulator (OsmOse)" ON \
             29 "Install DGEN (Megadrive/Genesis emulator)" ON \
             30 "(C) Configure DGEN" ON \
             31 "Install Megadrive/Genesis core (Genesis-Plus-GX)" ON \
             32 "Install NeoGeo emulator GnGeo 0.7" ON \
             33 "Install NeoGeo emulator GnGeo-Pi 0.85" ON \
             34 "(C) Configure NeoGeo" ON \
             35 "Install NES core" ON \
             36 "Install PC emulator (RPix86)" ON \
             37 "Install Playstation core" ON \
             38 "Install PSP emulator PPSSPP" OFF \
             39 "Install ScummVM" ON \
             40 "Install Super NES core" ON \
             41 "Install SNES9X emulator" ON \
             42 "Install PiSNES emulator" ON \
             43 "(C) Configure Super NES core" ON \
             44 "Install Wolfenstein3D engine" ON \
             45 "Install Z Machine emulator (Frotz)" ON \
             46 "Install ZX Spectrum emulator (Fuse)" ON \
             47 "Install BCM library" ON \
             48 "Install Dispmanx library" ON \
             49 "Install SNESDev" ON \
             50 "Install Emulation Station" ON \
             51 "Install Emulation Station Themes" ON \
             52 "Install ES-config" ON \
             53 "(C) Generate config file for Emulation Station" ON \
             54 "(C) Configure sound settings for RetroArch" ON \
             55 "(C) Set avoid_safe_mode=1 (for GPIO adapter)" ON \
             56 "Install runcommand script" ON )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    __ERRMSGS=""
    __INFMSGS=""
    if [ "$choices" != "" ]; then
        for choice in $choices
        do
            case $choice in
                1) install_rpiupdate ;;
                2) run_rpiupdate ;;
                3) update_apt ;;
                4) upgrade_apt ;;
                5) fixForXBian ;;
                6) add_to_groups ;;
                7) ensure_modules ;;
                8) exportSDLNOMOUSE ;;
                9) installAPTPackages ;;
                10) prepareFolders ;;
                11) install_retroarch ;;
                12) configureRetroArch ;;
                13) install_amiga ;;
                14) install_linapple ;;
                15) install_atari2600 ;;
                16) install_stella ;;
                17) install_basiliskII ;;
                18) install_viceC64 ;;
                19) install_cavestory ;;
                20) install_doom ;;
                21) install_eduke32 ;;
                22) install_gba ;;
                23) install_gbc ;;
                24) install_intellivision ;;
                25) install_mame ;;
                26) install_advmame ;;
                27) install_fba ;;
                28) install_megadrive ;;
                29) install_dgen ;;
                30) configureDGEN ;;
                31) install_megadriveLibretro ;;
                32) install_neogeo ;;
                33) install_GnGeoPi ;;
                34) configureNeogeo ;;
                35) install_nes ;;
                36) install_rpix86 ;;
                37) install_psx ;;
                38) install_ppsspp ;;
                39) install_scummvm ;;
                40) install_snes ;;
                41) install_snes9x ;;
                42) install_pisnes ;;
                43) configure_snes ;;
                44) install_wolfenstein3d ;;
                45) install_zmachine ;;
                46) install_zxspectrum ;;
                47) install_bcmlibrary ;;
                48) install_dispmanx ;;
                49) install_snesdev ;;
                50) install_emulationstation ;;
                51) install_esthemes ;;
                52) install_esconfig ;;
                53) generate_esconfig ;;
                54) configureSoundsettings ;;
                55) setAvoidSafeMode ;;
                56) install_runcommandscript ;;
            esac
        done

        chgrp -R $user $rootdir
        chown -R $user $rootdir

        createDebugLog

        if [[ ! -z $__ERRMSGS ]]; then
            dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "$__ERRMSGS See debug.log for more details." 20 60    
        fi

        if [[ ! -z $__INFMSGS ]]; then
            dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "$__INFMSGS" 20 60    
        fi

        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 20 60    
    fi
}

function main_setup()
{
    while true; do
        cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose task." 22 76 16)
        options=(1 "Re-generate config file for Emulation Station" 
                 2 "Install latest Rasperry Pi firmware" 
                 3 "Install AdvanceMenu"
                 4 "Start Emulation Station on boot?" 
                 5 "Start SNESDev on boot?"
                 6 "Enable/disable RetroPie splashscreen"
                 7 "Change ARM frequency" 
                 8 "Change SDRAM frequency"
                 9 "Install/update multi-console gamepad drivers for GPIO" 
                 10 "Enable gamecon_gpio_rpi with SNES-pad config"
                 11 "Run 'ES-scraper'" 
                 12 "Install and configure SAMBA shares"
                 13 "Install USB-ROM-Copy service"
                 14 "Generate debug log" )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
        if [ "$choices" != "" ]; then
            case $choices in
                 1) generate_esconfig ;;
                 2) run_rpiupdate ;;
                 3) install_advancemenu ;;
                 4) changeBootbehaviour ;;
                 5) enableDisableSNESDevStart ;;
                 6) enableDisableSplashscreen ;;
                 7) setArmFreq ;;
                 8) setSDRAMFreq ;;
                 9) installGPIOpadModules ;;
                 10) enableGameconSnes ;;
                 11) scraperMenu ;;
                 12) configureSAMBA ;;
                 13) install_USBROMService ;;
                 14) createDebugLog ;;
            esac
        else
            break
        fi
    done    
}

######################################
# here starts the main loop ##########
######################################

scriptdir=`dirname $0`
scriptdir=`cd $scriptdir && pwd`

checkNeededPackages

if [[ "$1" == "--help" ]]; then
    showHelp
    exit 0
fi

if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./retropie_setup' or ./retropie_setup --help for further information\n"
  exit 1
fi

# if called with sudo ./retropie_setup.sh, the installation directory is /home/CURRENTUSER/RetroPie for the current user
# if called with sudo ./retropie_setup.sh USERNAME, the installation directory is /home/USERNAME/RetroPie for user USERNAME
# if called with sudo ./retropie_setup.sh USERNAME ABSPATH, the installation directory is ABSPATH for user USERNAME
    
if [[ $# -lt 1 ]]; then
    user=$SUDO_USER
    if [ -z "$user" ]
    then
        user=$(whoami)
    fi
    rootdir=/home/$user/RetroPie
elif [[ $# -lt 2 ]]; then
    user=$1
    rootdir=/home/$user/RetroPie
elif [[ $# -lt 3 ]]; then
    user=$1
    rootdir=$2
fi

esscrapimgw=275 # width in pixel for EmulationStation games scraper

home=$(eval echo ~$user)

if [[ ! -d $rootdir ]]; then
    mkdir -p "$rootdir"
    if [[ ! -d $rootdir ]]; then
      echo "Couldn't make directory $rootdir"
      exit 1
    fi
fi

availFreeDiskSpace 800000

while true; do
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose installation either based on binaries or on sources." 22 76 16)
    options=(1 "Binaries-based INSTALLATION (faster, but possibly not up-to-date)"
             2 "Source-based INSTALLATION (slower, but up-to-date versions)"
             3 "SETUP (only if you already have run one of the installations above)"
             4 "UPDATE RetroPie Setup script"
             5 "UPDATE RetroPie Binaries"
             6 "UNINSTALL RetroPie installation"
             7 "Perform REBOOT" )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        case $choices in
            1) main_binaries ;;
            2) main_options ;;
            3) main_setup ;;
            4) main_updatescript ;;
            5) downloadBinaries ;;
            6) removeAPTPackages ;;
            7) main_reboot ;;
        esac
    else
        break
    fi
done

if [[ $__doReboot -eq 1 ]]; then
    dialog --title "The firmware has been updated and a reboot is needed." --clear \
        --yesno "Would you like to reboot now?\
        " 22 76

        case $? in
          0)
            main_reboot
            ;;
          *)        
            ;;
        esac
fi
clear
