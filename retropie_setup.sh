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

__BINARIESNAME="RetroPieSetupBinaries_061112.tar.bz2"
__THEMESNAME="RetroPieSetupThemes_241112.tar.bz2"

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
        git clone "$2" "$1"
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
    apt-get -y update
}

# upgrade APT packages
function upgrade_apt()
{
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
                        joystick

    # remove PulseAudio since this is slowing down the whole system significantly
    apt-get remove -y pulseaudio
}

# prepare folder structure for emulator, cores, front end, and roms
function prepareFolders()
{
    printMsg "Creating folder structure for emulator, front end, cores, and roms"

    pathlist[0]="$rootdir/roms"
    pathlist[1]="$rootdir/roms/atari2600"
    pathlist[2]="$rootdir/roms/doom"
    pathlist[3]="$rootdir/roms/gamegear"
    pathlist[4]="$rootdir/roms/gba"
    pathlist[5]="$rootdir/roms/gbc"
    pathlist[6]="$rootdir/roms/mame"
    pathlist[7]="$rootdir/roms/mastersystem"
    pathlist[8]="$rootdir/roms/megadrive"
    pathlist[9]="$rootdir/roms/nes"
    pathlist[10]="$rootdir/roms/pcengine"
    pathlist[11]="$rootdir/roms/psx"
    pathlist[12]="$rootdir/roms/snes"
    pathlist[13]="$rootdir/roms/zxspectrum"
    pathlist[14]="$rootdir/emulatorcores"
    pathlist[15]="$rootdir/roms/amiga"
    pathlist[16]="$rootdir/roms/neogeo"
    pathlist[17]="$rootdir/roms/scummvm"
    pathlist[18]="$rootdir/roms/zmachine"
    pathlist[19]="$rootdir/emulators"
    pathlist[20]="$rootdir/supplementary"

    for elem in "${pathlist[@]}"
    do
        if [[ ! -d $elem ]]; then
            mkdir $elem
            chown $user $elem
            chgrp $user $elem
        fi
    done    
}

# settings for RetroArch
function configureRetroArch()
{
    printMsg "Configuring RetroArch in /etc/retroarch.cfg"
    ensureKeyValue "system_directory" "$rootdir/emulatorcores/" "/etc/retroarch.cfg"
    ensureKeyValue "video_driver" "\"gl\"" "/etc/retroarch.cfg"

    # enable and configure rewind feature
    ensureKeyValue "rewind_enable" "true" "/etc/retroarch.cfg"
    ensureKeyValue "rewind_buffer_size" "10" "/etc/retroarch.cfg"
    ensureKeyValue "rewind_granularity" "2" "/etc/retroarch.cfg"
}

# install RetroArch emulator
function install_retroarch()
{
    printMsg "Installing RetroArch emulator"
    gitPullOrClone "$rootdir/emulators/RetroArch" git://github.com/Themaister/RetroArch.git
    ./configure --disable-libpng
    make
    sudo make install
    if [[ ! -f "/usr/local/bin/retroarch" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile and install RetroArch."
    fi  
    popd
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
    printMsg "Installing Atari 2600 core"
    gitPullOrClone "$rootdir/emulatorcores/stella-libretro" git://github.com/libretro/stella-libretro.git
    # remove msse and msse2 flags from Makefile, just a hack here to make it compile on the Raspberry
    sed 's|-msse2 ||g;s|-msse ||g' Makefile >> Makefile.rpi
    make -f Makefile.rpi
    if [[ ! -f "$rootdir/emulatorcores/stella-libretro/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Atari 2600 core."
    fi  
    popd    
}

# configure DGEN
function configureDGEN()
{
    chmod 777 /dev/fb0

    mkdir /home/$user/.dgen/
    chown -R $user /home/$user/.dgen/
    chgrp -R $user /home/$user/.dgen/
    cp sample.dgenrc /home/$user/.dgen/dgenrc 
    ensureKeyValue "joypad1_b0" "A" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad1_b1" "B" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad1_b3" "C" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad1_b6" "MODE" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad1_b7" "START" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad2_b0" "A" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad2_b1" "B" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad2_b3" "C" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad2_b6" "MODE" /home/$user/.dgen/dgenrc
    ensureKeyValue "joypad2_b7" "START" /home/$user/.dgen/dgenrc    
}

# install DGEN (Megadrive/Genesis emulator)
function install_dgen()
{
    printMsg "Installing Megadrive/Genesis emulator"
    if [[ -d "$rootdir/emulators/dgen" ]]; then
        rm -rf "$rootdir/emulators/dgen"
    fi   
    wget http://downloads.sourceforge.net/project/dgen/dgen/1.30/dgen-sdl-1.30.tar.gz
    tar xvfz dgen-sdl-1.30.tar.gz -C "$rootdir/emulators/"
    pushd "$rootdir/emulators/dgen-sdl-1.30"
    mkdir "installdir" # only used for creating the binaries archive
    ./configure --disable-hqx --disable-opengl
    make
    make install DESTDIR=$rootdir/emulators/dgen-sdl-1.30/installdir
    make install
    if [[ ! -f "$rootdir/emulators/dgen-sdl-1.30/dgen" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile DGEN emulator."
    fi  
    popd
    rm dgen-sdl-1.30.tar.gz

    configureDGEN

}

# install Doom WADs emulator core
function install_doom()
{
    printMsg "Installing Doom core"
    gitPullOrClone "$rootdir/emulatorcores/libretro-prboom" git://github.com/libretro/libretro-prboom.git
    make
    mkdir -p $rootdir/roms/doom/
    cp $rootdir/emulatorcores/libretro-prboom/prboom.wad $rootdir/roms/doom/
    if [[ ! -f "$rootdir/emulatorcores/libretro-prboom/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Doom core."
    fi  
    popd
}

#install eDuke32
function install_eduke32()
{
	  printMsg "Installing eDuke32"
    if [[ -d "$rootdir/emulators/eduke32" ]]; then
        rm -rf "$rootdir/emulators/eduke32"
    fi
    mkdir -p $rootdir/emulators/eduke32
    cd "$rootdir/emulators/eduke32"
    pushd "$rootdir/emulators/eduke32"
		printMsg "Downloading eDuke core"
		wget http://repo.berryboot.com/eduke32_2.0.0rpi+svn2789_armhf.deb		
		printMsg "Downloading eDuke32 Shareware files"
		wget http://apt.duke4.net/pool/main/d/duke3d-shareware/duke3d-shareware_1.3d-23_all.deb	
		if [[ ! -f "$rootdir/emulators/eduke32/eduke32_2.0.0rpi+svn2789_armhf.deb" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile eDuke32 core."
    fi
		printMsg "Installing eDuke32"
		sudo dpkg -i *duke*.deb
		mkdir -p $rootdir/roms/eduke32/
		cp /usr/share/games/eduke32/DUKE.RTS $rootdir/roms/eduke32/
		cp /usr/share/games/eduke32/duke3d.grp $rootdir/roms/eduke32/
		popd
		rm -rf "$rootdir/emulators/eduke32"
}

# install Game Boy Advance emulator core
function install_gba()
{
    printMsg "Installing Game Boy Advance core"
    gitPullOrClone "$rootdir/emulatorcores/vba-next" git://github.com/libretro/vba-next.git
    make -f Makefile.libretro
    if [[ ! -f "$rootdir/emulatorcores/vba-next/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Game Boy Advance core."
    fi      
    popd    
}

# install Game Boy Color emulator core
function install_gbc()
{
    printMsg "Installing Game Boy Color core"
    gitPullOrClone "$rootdir/emulatorcores/gambatte-libretro" git://github.com/libretro/gambatte-libretro.git
    make -C libgambatte -f Makefile.libretro
    if [[ ! -f "$rootdir/emulatorcores/gambatte-libretro/libgambatte/libretro.so" ]]; then
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
    if [[ ! -f "$rootdir/emulatorcores/imame4all-libretro/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile MAME core."
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

    # install and enable GCC-4.7
    apt-get install -y gcc-4.7
    export CC=gcc-4.7
    export GCC=g++-4.7

    # install zlib
    wget http://zlib.net/zlib-1.2.7.tar.gz    
    tar xvfz zlib-1.2.7.tar.gz -C $rootdir/supplementary/
    pushd $rootdir/supplementary/zlib-1.2.7
    ./configure 
    make
    make install
    popd
    rm zlib-1.2.7.tar.gz 

    # GnGeo
    wget http://gngeo.googlecode.com/files/gngeo-0.7.tar.gz
    tar xvfz gngeo-0.7.tar.gz -C $rootdir/emulators/
    pushd "$rootdir/emulators/gngeo-0.7"
    ./configure --build=i386 --host=arm-linux --target=arm-linux --disable-i386asm --enable-cyclone --enable-drz80
    make
    make install

    # configure
    mkdir /home/$user/.gngeo/
    cp sample_gngeorc /home/$user/.gngeo/gngeorc
    chown -R $user /home/$user/.gngeo/
    chgrp -R $user /home/$user/.gngeo/

    sed -i -e "s/effect none/effect scale2x/g" /home/$user/.gngeo/gngeorc
    sed -i -e "s/fullscreen false/fullscreen true/g" /home/$user/.gngeo/gngeorc

    if [[ ! -f "$rootdir/emulators/gngeo-0.7/src/gngeo" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NeoGeo emulator."
    fi          
    popd
    rm gngeo-0.7.tar.gz

    chmod 777 /dev/fb0

    mkdir "$rootdir/emulators/gngeo-0.7/neogeo-bios"
    __INFMSGS="$__INFMSGS You need to copy NeoGeo BIOS files to the folder '$rootdir/emulators/gngeo-0.7/neogeo-bios/'."
}

# install NES emulator core
function install_nes()
{
    printMsg "Installing NES core"
    gitPullOrClone "$rootdir/emulatorcores/fceu-next" git://github.com/libretro/fceu-next.git
    make -f Makefile.libretro-fceumm
    if [[ ! -f "$rootdir/emulatorcores/fceu-next/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NES core."
    fi      
    popd
}

# install Sega Mega Drive/Mastersystem/Game Gear emulator core
function install_megadrive()
{
    printMsg "Installing Mega Drive/Mastersystem/Game Gear core"
    gitPullOrClone "$rootdir/emulatorcores/Genesis-Plus-GX" git://github.com/libretro/Genesis-Plus-GX.git
    make -f Makefile.libretro 
    sed /etc/retroarch.cfg -i -e "s|# system_directory =|system_directory = $rootdir/emulatorcores/|g"
    if [[ ! -f "$rootdir/emulatorcores/Genesis-Plus-GX/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Genesis core."
    fi      
    popd
}

# install PC Engine core
function install_mednafen_pce()
{
    printMsg "Installing Mednafen PC Engine core"
    gitPullOrClone "$rootdir/emulatorcores/mednafen-pce-libretro" git://github.com/libretro/mednafen-pce-libretro.git
    make
    if [[ ! -f "$rootdir/emulatorcores/mednafen-pce-libretro/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile PC Engine core."
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
    if [[ ! -f "$rootdir/emulatorcores/pcsx_rearmed/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Playstation core."
    fi      
    popd
}

# install SNES emulator core
function install_snes()
{
    printMsg "Installing SNES core"
    gitPullOrClone "$rootdir/emulatorcores/pocketsnes-libretro" git://github.com/ToadKing/pocketsnes-libretro.git
    make
    if [[ ! -f "$rootdir/emulatorcores/pocketsnes-libretro/libretro.so" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES core."
    fi      
    popd
}

function install_wolfenstein3d()
{
    printMsg "Installing Wolfenstein3D Engine"    
    if [[ -d "$rootdir/emulators/Wolf4SDL" ]]; then
        rm -rf "$rootdir/emulators/Wolf4SDL"
    fi    
    wget http://www.alice-dsl.net/mkroll/bins/Wolf4SDL-1.7-src.zip
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

# install ZX Spectrum emulator
function install_zxspectrum()
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
    ./configure
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

# install BCM library to enable GPIO access by SNESDev-RPi
function install_bcmlibrary()
{
    printMsg "Installing BCM2835 library"
    pushd $rootdir
    wget http://www.open.com.au/mikem/bcm2835/bcm2835-1.3.tar.gz
    tar -zxvf bcm2835-1.3.tar.gz
    cd bcm2835-1.3
    ./configure
    make
    sudo make install
    cd ..
    rm bcm2835-1.3.tar.gz
    rm -rf bcm2835-1.3
    popd 
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
    if [[ ! -f "$rootdir/supplementary/SNESDev-Rpi/bin/SNESDev" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNESDev."  
    fi    
    popd
}

# start SNESDev on boot and configure RetroArch input settings
function enableSNESDevAtStart()
{
    clear
    printMsg "Enabling SNESDev on boot."

    if [[ ! -f "/etc/init.d/SNESDev" ]]; then
        if [[ ! -f "$rootdir/supplementary/SNESDev-Rpi/bin/SNESDev" ]]; then
            dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Cannot find SNESDev binary. Please install SNESDev." 22 76    
            return
        else
            chmod +x "$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev"
            cp "$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev" /etc/init.d/
        fi
        cp "$rootdir/supplementary/SNESDev-Rpi/bin/SNESDev" /usr/local/bin/
    fi    

    ensureKeyValueShort "DAEMON_ARGS" "\"$1\"" "/etc/init.d/SNESDev"

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d SNESDev defaults
    # This command starts the daemon now so no need for a reboot
    service SNESDev start     

    if [[ ($1 -eq 1) || ($1 -eq 3) ]]; then
        ensureKeyValue "input_player1_a" "x" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_b" "z" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_y" "a" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_x" "s" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_start" "enter" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_select" "rshift" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_l" "q" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_r" "w" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_left" "left" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_right" "right" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_up" "up" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_down" "down"   "/etc/retroarch.cfg" 

        ensureKeyValue "input_player2_a" "e" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_b" "r" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_y" "y" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_x" "t" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_start" "p" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_select" "o" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_l" "u" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_r" "i" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_left" "c" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_right" "b" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_up" "f" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_down" "v"   "/etc/retroarch.cfg" 
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

    disableKeyValue "input_player1_a" "x" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_b" "z" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_y" "a" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_x" "s" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_start" "enter" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_select" "rshift" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_l" "q" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_r" "w" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_left" "left" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_right" "right" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_up" "up" "/etc/retroarch.cfg"
    disableKeyValue "input_player1_down" "down"   "/etc/retroarch.cfg" 

    disableKeyValue "input_player2_a" "e" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_b" "r" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_y" "y" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_x" "t" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_start" "p" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_select" "o" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_l" "u" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_r" "i" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_left" "c" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_right" "b" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_up" "f" "/etc/retroarch.cfg"
    disableKeyValue "input_player2_down" "v"   "/etc/retroarch.cfg" 
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

# a work around here, so that EmulationStation can be executed from arbitrary locations
function install_esscript()
{
    cat > /usr/bin/emulationstation << _EOF_
#!/bin/bash

if [ -n "\$DISPLAY" ]; then
    echo "X is running. Please shut down X in order to mitigate problems with loosing keyboard input. For example, logout from LXDE."
    exit 1
fi 

pushd "$rootdir/supplementary/EmulationStation" > /dev/null
./emulationstation
popd > /dev/null
_EOF_
    chmod +x /usr/bin/emulationstation
}

# install EmulationStation as graphical front end for the emulators
function install_emulationstation()
{
    printMsg "Installing EmulationStation as graphical front end"
    gitPullOrClone "$rootdir/supplementary/EmulationStation" git://github.com/Aloshi/EmulationStation.git
    make
    install_esscript
    if [[ ! -f "$rootdir/supplementary/EmulationStation/emulationstation" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Emulation Station."
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
NAME=Atari 2600
PATH=$rootdir/roms/atari2600
EXTENSION=.bin .BIN
COMMAND=retroarch -L $rootdir/emulatorcores/stella-libretro/libretro.so %ROM%
PLATFORMID=22

NAME=Doom
PATH=$rootdir/roms/doom
EXTENSION=.WAD .wad
COMMAND=retroarch -L $rootdir/emulatorcores/libretro-prboom/libretro.so %ROM%
PLATFORMID=1

NAME=eDuke32
PATH=$rootdir/roms/eduke32
EXTENSION=.grp .GRP
COMMAND=eduke32 %ROM%
PLATFORMID=1

NAME=Game Boy Advance
PATH=$rootdir/roms/gba
EXTENSION=.gba .GBA
COMMAND=retroarch -L $rootdir/emulatorcores/vba-next/libretro.so %ROM%
PLATFORMID=5

NAME=Game Boy Color
PATH=$rootdir/roms/gbc
EXTENSION=.gb .GB
COMMAND=retroarch -L $rootdir/emulatorcores/gambatte-libretro/libgambatte/libretro.so %ROM%
PLATFORMID=41

NAME=Sega Game Gear
PATH=$rootdir/roms/gamegear
EXTENSION=.gg .GG
COMMAND=retroarch -L $rootdir/emulatorcores/Genesis-Plus-GX/libretro.so %ROM%
PLATFORMID=20

NAME=MAME
PATH=$rootdir/roms/mame
EXTENSION=.zip .ZIP
COMMAND=retroarch -L $rootdir/emulatorcores/imame4all-libretro/libretro.so %ROM%  
PLATFORMID=23

NAME=ScummVM
PATH=$rootdir/roms/scummvm
EXTENSION=.exe .EXE
COMMAND=scummvm
PLATFORMID=20

NAME=Sega Master System II
PATH=$rootdir/roms/mastersystem
EXTENSION=.sms .SMS
COMMAND=retroarch -L $rootdir/emulatorcores/Genesis-Plus-GX/libretro.so %ROM%
PLATFORMID=35

NAME=Sega Mega Drive / Genesis
PATH=$rootdir/roms/megadrive
EXTENSION=.smd .SMD .md .MD
COMMAND=dgen -f %ROM%
PLATFORMID=36

NAME=NeoGeo
PATH=$rootdir/roms/neogeo
EXTENSION=.zip .ZIP
COMMAND=$rootdir/emulators/gngeo-0.7/src/gngeo -i $rootdir/roms/neogeo -B $rootdir/emulators/gngeo-0.7/neogeo-bios %ROM%
PLATFORMID=24

NAME=Nintendo Entertainment System
PATH=$rootdir/roms/nes
EXTENSION=.nes .NES
COMMAND=retroarch -L $rootdir/emulatorcores/fceu-next/libretro.so %ROM%
PLATFORMID=7

NAME=PC Engine/TurboGrafx 16
PATH=$rootdir/roms/pcengine
EXTENSION=.pce
COMMAND=retroarch -L $rootdir/emulatorcores/mednafen-pce-libretro/libretro.so %ROM%
PLATFORMID=34

NAME=Sony Playstation 1
PATH=$rootdir/roms/psx
EXTENSION=.img .IMG .7z
COMMAND=retroarch -L $rootdir/emulatorcores/pcsx_rearmed/libretro.so %ROM%
PLATFORMID=10

NAME=Super Nintendo
PATH=$rootdir/roms/snes
EXTENSION=.smc .sfc .fig .swc .SMC .SFC .FIG .SWC
COMMAND=retroarch -L $rootdir/emulatorcores/pocketsnes-libretro/libretro.so %ROM%
PLATFORMID=6

NAME=ZX Spectrum
PATH=$rootdir/roms/zxspectrum
EXTENSION=.z80 .Z80
COMMAND=fuse

_EOF_

chown -R $user "$rootdir/../.emulationstation"
chgrp -R $user "$rootdir/../.emulationstation"

}

function sortromsalphabet()
{
    clear
    pathlist[0]="$rootdir/roms/amiga"
    pathlist[1]="$rootdir/roms/atari2600"
    pathlist[2]="$rootdir/roms/gamegear"
    pathlist[3]="$rootdir/roms/gba"
    pathlist[4]="$rootdir/roms/gbc"
    pathlist[5]="$rootdir/roms/mame"
    pathlist[6]="$rootdir/roms/mastersystem"
    pathlist[7]="$rootdir/roms/megadrive"
    pathlist[8]="$rootdir/roms/neogeo"
    pathlist[9]="$rootdir/roms/nes"
    pathlist[10]="$rootdir/roms/snes"  
    pathlist[11]="$rootdir/roms/pcengine"      
    pathlist[12]="$rootdir/roms/psx"  
    pathlist[13]="$rootdir/roms/zxspectrum"  
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
    wget https://github.com/downloads/petrockblog/RetroPie-Setup/$__BINARIESNAME
    tar -jxvf $__BINARIESNAME -C $rootdir
    pushd $rootdir/RetroPie
    cp -r * ../
    popd

    # handle Doom emulator specifics
    cp $rootdir/emulatorcores/libretro-prboom/prboom.wad $rootdir/roms/doom/
    chgrp $user $rootdir/roms/doom/prboom.wad
    chown $user $rootdir/roms/doom/prboom.wad

    rm -rf $rootdir/RetroPie
    rm $__BINARIESNAME    
}

# downloads and installs theme files for Emulation Station
function install_esthemes()
{
    printMsg "Installing themes for Emulation Station"
    wget https://github.com/downloads/petrockblog/RetroPie-Setup/$__THEMESNAME
    tar -jxvf $__THEMESNAME -C /tmp
    if [[ ! -d $home/.emulationstation/themes ]]; then
        mkdir $home/.emulationstation/themes
    fi
    cp -r /tmp/.emulationstation/themes/* "$home/.emulationstation/themes/"
    cp -r /tmp/RetroPie/roms/* "$rootdir/roms/"
    rm -rf /tmp/RetroPie/
    rm -rf /tmp/.emulationstation/
    rm $__THEMESNAME
    chgrp -R $user .emulationstation
    chown -R $user .emulationstation
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
    printMsg "Enabling SDL audio driver for RetroArch in /etc/retroarch.cfg"    
    # RetroArch settings
    ensureKeyValue "audio_driver" "sdl" "/etc/retroarch.cfg"
    ensureKeyValue "audio_out_rate" "44100" "/etc/retroarch.cfg"
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
               sed /etc/profile -i -e "s|emulationstation||g"
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Enabled original boot behaviour." 22 76    
                            ;;
            2) sed /etc/inittab -i -e "s|1:2345:respawn:/sbin/getty --noclear 38400 tty1|1:2345:respawn:\/bin\/login -f $user tty1 \<\/dev\/tty1 \>\/dev\/tty1 2\>\&1|g"
               if [ -z $(egrep -i "^emulationstation" /etc/profile) ]
               then
                   echo "emulationstation" >> /etc/profile
               fi
               dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Emulation Station is now starting on boot." 22 76    
                            ;;
        esac
    else
        break
    fi    
}

function installGameconGPIOModule()
{
        clear

	dialog --title " gamecon_gpio_rpi installation " --clear \
	--yesno "Gamecon_gpio_rpi requires thats most recent kernel (firmware)\
	is installed and active. Continue with gamecon_gpio_rpi\
	installation?" 22 76
	case $? in
	  0)
	    echo "Starting installation.";;
	  *)
	    return 0;;
	esac

	#remove old headers manually to avoid cleanup issues
	if [ "`dpkg-query -W -f='${Version}' linux-headers-3.2.27+`" = "3.2.27+-1" ]; then
	    dpkg -r gamecon-gpio-rpi-dkms
	    dpkg -r linux-headers-3.2.27+
	fi

        #install dkms
        apt-get install -y dkms

	#reconfigure / install headers (takes a a while)
	if [ "`dpkg-query -W -f='${Version}' linux-headers-3.2.27+`" = "3.2.27+-2" ]; then
		dpkg-reconfigure linux-headers-3.2.27+
	else
        	wget http://www.niksula.hut.fi/~mhiienka/Rpi/linux-headers-rpi/linux-headers-`uname -r`_`uname -r`-2_armhf.deb
	        dpkg -i linux-headers-`uname -r`_`uname -r`-2_armhf.deb
		rm linux-headers-`uname -r`_`uname -r`-2_armhf.deb
	fi

	#install gamecon
	if [ "`dpkg-query -W -f='${Version}' gamecon-gpio-rpi-dkms`" = "0.9" ]; then
		#dpkg-reconfigure gamecon-gpio-rpi-dkms
		echo "gamecon is the newest version"
	else
	        wget http://www.niksula.hut.fi/~mhiienka/Rpi/gamecon-gpio-rpi-dkms_0.9_all.deb
	        dpkg -i gamecon-gpio-rpi-dkms_0.9_all.deb
		rm gamecon-gpio-rpi-dkms_0.9_all.deb
	fi

	#test if module installation is OK
	if [[ -n $(modinfo -n gamecon_gpio_rpi | grep gamecon_gpio_rpi.ko) ]]; then
	        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Gamecon GPIO driver successfully installed. \
		Use 'zless /usr/share/doc/gamecon_gpio_rpi/README.gz' to read how to use it." 22 76
	else
		dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Gamecon GPIO driver installation FAILED"\
		22 76
	fi
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

	dialog --title " Update /etc/retroarch.cfg " --clear \
        --yesno "Would you like to update button mappings \
	to /etc/retroarch.cfg ?" 22 76

      case $? in
       0)
	if [ $GPIOREV = 1 ]; then
	        ensureKeyValue "input_player1_joypad_index" "0" "/etc/retroarch.cfg"
        	ensureKeyValue "input_player2_joypad_index" "1" "/etc/retroarch.cfg"
	else
		ensureKeyValue "input_player1_joypad_index" "1" "/etc/retroarch.cfg"
		ensureKeyValue "input_player2_joypad_index" "0" "/etc/retroarch.cfg"
	fi

        ensureKeyValue "input_player1_a_btn" "0" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_b_btn" "1" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_x_btn" "2" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_y_btn" "3" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_l_btn" "4" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_r_btn" "5" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_start_btn" "7" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_select_btn" "6" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_left_axis" "-0" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_up_axis" "-1" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_right_axis" "+0" "/etc/retroarch.cfg"
        ensureKeyValue "input_player1_down_axis" "+1" "/etc/retroarch.cfg"

        ensureKeyValue "input_player2_a_btn" "0" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_b_btn" "1" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_x_btn" "2" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_y_btn" "3" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_l_btn" "4" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_r_btn" "5" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_start_btn" "7" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_select_btn" "6" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_left_axis" "-0" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_up_axis" "-1" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_right_axis" "+0" "/etc/retroarch.cfg"
        ensureKeyValue "input_player2_down_axis" "+1" "/etc/retroarch.cfg"
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

function checkNeededPackages()
{
    doexit=0
    type -P git &>/dev/null && echo "Found git command." || { echo "Did not find git. Try 'sudo apt-get install -y git' first."; doexit=1; }
    type -P dialog &>/dev/null && echo "Found dialog command." || { echo "Did not find dialog. Try 'sudo apt-get install -y dialog' first."; doexit=1; }
    if [[ doexit -eq 1 ]]; then
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
    shutdown -r now    
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
    checkFileExistence "/etc/retroarch.cfg"
    echo -e "\nActive lines in /etc/retroarch.cfg:" >> "$rootdir/debug.log"
    sed '/^$\|^#/d' "/etc/retroarch.cfg"  >>  "$rootdir/debug.log"

    echo -e "\nEmulation Station files:" >> "$rootdir/debug.log"
    checkFileExistence "$rootdir/supplementary/EmulationStation/emulationstation"
    checkFileExistence "$rootdir/../.emulationstation/es_systems.cfg"
    checkFileExistence "$rootdir/../.emulationstation/es_input.cfg"
    checkFileExistence "$rootdir/supplementary/EmulationStation/LinLibertine_R.ttf"
    echo -e "\nContent of es_systems.cfg:" >> "$rootdir/debug.log"
    cat "$rootdir/../.emulationstation/es_systems.cfg" >> "$rootdir/debug.log"
    echo -e "\nContent of es_input.cfg:" >> "$rootdir/debug.log"
    cat "$rootdir/../.emulationstation/es_input.cfg" >> "$rootdir/debug.log"

    echo -e "\nEmulators and cores:" >> "$rootdir/debug.log"
    checkFileExistence "$rootdir/emulatorcores/fceu-next/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/Genesis-Plus-GX/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/libretro-prboom/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/libretro-prboom/prboom.wad"
    checkFileExistence "$rootdir/emulatorcores/stella-libretro/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/gambatte-libretro/libgambatte/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/imame4all-libretro/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/pcsx_rearmed/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/mednafen-pce-libretro/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/pocketsnes-libretro/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/vba-next/libretro.so"
    checkFileExistence "$rootdir/emulatorcores/uae4all/uae4all"

    echo -e "\nSNESDev:" >> "$rootdir/debug.log"
    checkFileExistence "$rootdir/supplementary/SNESDev-Rpi/bin/SNESDev"

    echo -e "\nSummary of ROMS directory:" >> "$rootdir/debug.log"
    du -ch --max-depth=1 "$rootdir/roms/" >> "$rootdir/debug.log"

    echo -e "\nUnrecognized ROM extensions:" >> "$rootdir/debug.log"
    find "$rootdir/roms/amiga/" -type f ! \( -iname "*.adf" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/atari2600/" -type f ! \( -iname "*.bin" -or -iname "*.jpg" -or -iname "*.xml" \) >> "$rootdir/debug.log"
    find "$rootdir/roms/doom/" -type f ! \( -iname "*.WAD" -or -iname "*.jpg" -or -iname "*.xml" -or -name "*.wad" \) >> "$rootdir/debug.log"
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

    install_rpiupdate
    run_rpiupdate
    update_apt
    upgrade_apt
    installAPTPackages
    ensure_modules
    add_to_groups
    exportSDLNOMOUSE
    prepareFolders
    downloadBinaries
    install_esscript
    generate_esconfig
    # install RetroArch
    install -m755 $rootdir/emulators/RetroArch/retroarch /usr/local/bin
    install -m644 $rootdir/emulators/RetroArch/retroarch.cfg /etc/retroarch.cfg
    install -m755 $rootdir/emulators/RetroArch/retroarch-zip /usr/local/bin
    configureRetroArch
    install_esthemes
    configureSoundsettings
    # install DGEN
    test -z "/usr/local/bin" || /bin/mkdir -p "/usr/local/bin"
    /usr/bin/install -c $rootdir/emulators/dgen-sdl-1.30/installdir/usr/local/bin/dgen $rootdir/emulators/dgen-sdl-1.30/installdir/usr/local/bin/dgen_tobin '/usr/local/bin'
    test -z "/usr/local/share/man/man1" || /bin/mkdir -p "/usr/local/share/man/man1"
    /usr/bin/install -c -m 644 $rootdir/emulators/dgen-sdl-1.30/installdir/usr/local/share/man/man1/dgen.1 $rootdir/emulators/dgen-sdl-1.30/installdir/usr/local/share/man/man1/dgen_tobin.1 '/usr/local/share/man/man1'
    test -z "/usr/local/share/man/man5" || /bin/mkdir -p "/usr/local/share/man/man5"
    /usr/bin/install -c -m 644 $rootdir/emulators/dgen-sdl-1.30/installdir/usr/local/share/man/man5/dgenrc.5 '/usr/local/share/man/man5'
    configureDGEN

    chgrp -R $user $rootdir
    chown -R $user $rootdir

    createDebugLog

    __INFMSGS="$__INFMSGS The Amiga emulator can be started from command line with '$rootdir/emulators/uae4all/uae4all'. Note that you must manually copy a Kickstart rom with the name 'kick.rom' to the directory $rootdir/emulators/uae4all/."
    __INFMSGS="$__INFMSGS You need to copy NeoGeo BIOS files to the folder '$rootdir/emulators/gngeo-0.7/neogeo-bios/'."

    if [[ ! -z $__INFMSGS ]]; then
        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "$__INFMSGS" 20 60    
    fi

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 22 76    
}

##################
## menus #########
##################

function scraperMenu()
{
    while true; do
        cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose task." 22 76 16)
        options=(1 "(Re-)scape of the ROMs directory" 
                 2 "Forced (re-)scrape of the ROMs directory" 
                 3 "(Re-)scrape of the ROMs directory with CRC option" 
                 4 "(Re-)scrape of the ROMs directory in manual mode" 
                 5 "Set maximum width of images (currently: $esscrapimgw px)" )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
        if [ "$choices" != "" ]; then
            clear
            case $choices in
                1) essc_runnormal ;;
                2) essc_runforced ;;
                3) essc_runcrc ;;
                4) essc_runmanual ;;
                5) essc_setimgw ;;
            esac
        else
            break
        fi
    done        
}

function main_options()
{
    cmd=(dialog --separate-output --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --checklist "Select options with 'space' and arrow keys. The default selection installs a complete set of packages." 22 76 16)
    options=(1 "Install latest rpi-update script" ON     # any option can be set to default to "on"
             2 "Update firmware with rpi-update" ON \
             3 "Update APT repositories" ON \
             4 "Perform APT upgrade" ON \
             5 "Add user $user to groups video, audio, and input" ON \
             6 "Enable modules ALSA, uinput, and joydev" ON \
             7 "Export SDL_NOMOUSE=1" ON \
             8 "Install all needed APT packages" ON \
             9 "Generate folder structure" ON \
             10 "Install RetroArch" ON \
             11 "Configure RetroArch" ON \
             12 "Install Amiga emulator" ON \
             13 "Install Atari 2600 core" ON \
             14 "Install Doom core" ON \
             15 "Install eDuke32 core" ON \
             16 "Install Game Boy Advance core" ON \
             17 "Install Game Boy Color core" ON \
             18 "Install MAME core" ON \
             19 "Install Mega Drive/Mastersystem/Game Gear (RetroArch) core" ON \
             20 "Install DGEN (alternative Megadrive/Genesis emulator)" ON \
             21 "Install NeoGeo emulator" ON \
             22 "Install NES core" ON \
             23 "Install PC Engine core" ON \
             24 "Install Playstation core" ON \
             25 "Install ScummVM" ON \
             26 "Install Super NES core" ON \
             27 "Install Wolfenstein3D engine" ON \
             28 "Install Z Machine emulator (Frotz)" ON \
             29 "Install ZX Spectrum emulator (Fuse)" ON \
             30 "Install BCM library" ON \
             31 "Install SNESDev" ON \
             32 "Install Emulation Station" ON \
             33 "Install Emulation Station Themes" ON \
             34 "Generate config file for Emulation Station" ON \
             35 "Enable SDL sound driver for RetroArch" ON )
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
                5) add_to_groups ;;
                6) ensure_modules ;;
                7) exportSDLNOMOUSE ;;
                8) installAPTPackages ;;
                9) prepareFolders ;;
                10) install_retroarch ;;
                11) configureRetroArch ;;
                12) install_amiga ;;
                13) install_atari2600 ;;
                14) install_doom ;;
                15) install_eduke32 ;;
                16) install_gba ;;
                17) install_gbc ;;
                18) install_mame ;;
                19) install_megadrive ;;
                20) install_dgen ;;
                21) install_neogeo ;;
                22) install_nes ;;
                23) install_mednafen_pce ;;
                24) install_psx ;;
                25) install_scummvm ;;
                26) install_snes ;;
                27) install_wolfenstein3d ;;
                28) install_zmachine ;;
                29) install_zxspectrum ;;
                30) install_bcmlibrary ;;
                31) install_snesdev ;;
                32) install_emulationstation ;;
                33) install_esthemes ;;
                34) generate_esconfig ;;
                35) configureSoundsettings ;;
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
                 3 "Sort roms alphabetically within folders. *Creates subfolders*" 
                 4 "Start Emulation Station on boot?" 
                 5 "Start SNESDev on boot?"
                 6 "Change ARM frequency" 
                 7 "Change SDRAM frequency"
                 8 "Install/update multi-console gamepad driver for GPIO" 
                 9 "Enable gamecon_gpio_rpi with SNES-pad config"
                 10 "Run 'ES-scraper'" 
                 11 "Generate debug log" )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
        if [ "$choices" != "" ]; then
            case $choices in
                 1) generate_esconfig ;;
                 2) run_rpiupdate ;;
                 3) sortromsalphabet ;;
                 4) changeBootbehaviour ;;
                 5) enableDisableSNESDevStart ;;
                 6) setArmFreq ;;
                 7) setSDRAMFreq ;;
                 8) installGameconGPIOModule ;;
                 9) enableGameconSnes ;;
                 10) scraperMenu ;;
                 11) createDebugLog ;;
            esac
        else
            break
        fi
    done    
}

######################################
# here starts the main loop ##########
######################################

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

availFreeDiskSpace 600000

while true; do
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose installation either based on binaries or on sources." 22 76 16)
    options=(1 "Binaries-based installation (faster, (probably) not the newest)"
             2 "Source-based (custom) installation (slower, newest)"
             3 "Setup (only if you already have run one of the installations above)"
             4 "Perform reboot" )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        case $choices in
            1) main_binaries
               break ;;
            2) main_options ;;
            3) main_setup ;;
            4) main_reboot ;;
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
