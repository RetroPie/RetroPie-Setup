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
# Many, many thanks go to all people that provide the individual packages!!!
# 
#  Raspberry Pi is a trademark of the Raspberry Pi Foundation.
# 

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

function availFreeDiskSpace()
{
    local __required=$1
    local __avail=`df -P $rootdir | tail -n1 | awk '{print $4}'`

    if [[ "$__required" -le "$__avail" ]] || ask "Recommended disk space($__required) not available. Only $__avail available at $rootdir continue anyway?"; then
        return 0;
    else
        exit 0;
    fi
}

printMsg()
{
	echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$1\n= = = = = = = = = = = = = = = = = = = = =\n"
}

rel2abs() {
  cd "$(dirname $1)" && dir="$PWD"
  file="$(basename $1)"

  echo $dir/$file
}

install_rpiupdate()
{
    # install latest rpi-update script (to enable firmware update)
    printMsg "Installing latest rpi-update script"
    sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
    # ask "Do you want to perform a firmware upgrade now?\nThis might take some minutes." && sudo rpi-update    
}

run_rpiupdate()
{
    printMsg "Starting rpi-update script"
    /usr/bin/rpi-update
}

# update APT repositories
update_apt() 
{
    apt-get -y update
}

# upgrade APT packages
upgrade_apt()
{
    apt-get -y upgrade
}

add_to_groups()
{
    # add user $user to groups "video", "audio", and "input"
    printMsg "Adding user $user to groups video, audio, and input."
    add_user_to_group $user video
    add_user_to_group $user audio
    add_user_to_group $user input
}

add_user_to_group()
{
    # add user $1 to group $2, create the group if it doesn't exist
    if [ -z $(egrep -i "^$2" /etc/group) ]
    then
      sudo addgroup $2
    fi
    sudo adduser $1 $2
}

ensure_modules()
{
    # make sure ALSA, uinput, and joydev modules are active
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

exportSDLNOMOUSE()
{
    # needed by SDL for working joypads
    printMsg "Exporting SDL_NOMOUSE=1 permanently to $home/.bashrc"
    export SDL_NOMOUSE=1
    if ! grep -q "export SDL_NOMOUSE=1" $home/.bashrc; then
        echo -e "\nexport SDL_NOMOUSE=1" >> $home/.bashrc
    else
        echo -e "SDL_NOMOUSE=1 already contained in $home/.bashrc"
    fi    
}

installAPTPackages()
{
    # make sure that all needed packages are installed
    printMsg "Making sure that all needed packaged are installed"
    sudo apt-get install -y libsdl1.2-dev screen scons libasound2-dev pkg-config libgtk2.0-dev libsdl-ttf2.0-dev libboost-filesystem-dev zip libxml2 libsdl-image1.2-dev libsdl-gfx1.2-dev
}

prepareFolders()
{
    # prepare folder structure for emulator, cores, front end, and roms
    printMsg "Creating folder structure for emulator, front end, cores, and roms"

    pathlist[0]="$rootdir/roms"
    pathlist[1]="$rootdir/roms/atari2600"
    pathlist[2]="$rootdir/roms/doom"
    pathlist[3]="$rootdir/roms/gba"
    pathlist[4]="$rootdir/roms/gbc"
    pathlist[5]="$rootdir/roms/mame"
    pathlist[6]="$rootdir/roms/megadrive"
    pathlist[7]="$rootdir/roms/nes"
    pathlist[8]="$rootdir/roms/snes"
    pathlist[9]="$rootdir/emulatorcores"

    for elem in "${pathlist[@]}"
    do
        if [[ ! -d $elem ]]; then
            mkdir $elem
            chown $user $elem
            chgrp $user $elem
        fi
    done    
}

install_retroarch()
{
    # install RetroArch emulator
    printMsg "Installing RetroArch emulator"
    if [[ -d "$rootdir/RetroArch-Rpi" ]]; then
        rm -rf "$rootdir/RetroArch-Rpi"
    fi
    git clone git://github.com/Themaister/RetroArch.git "$rootdir/RetroArch-Rpi"
    pushd "$rootdir/RetroArch-Rpi"
    ./configure --disable-libpng
    make
    sudo make install
    popd
}

install_atari2600()
{
    # install Atari 2600 core
    printMsg "Installing Atari 2600 core"
    if [[ -d "$rootdir/emulatorcores/stella-libretro" ]]; then
        rm -rf "$rootdir/emulatorcores/stella-libretro"
    fi
    git clone git://github.com/libretro/stella-libretro.git "$rootdir/emulatorcores/stella-libretro"
    pushd "$rootdir/emulatorcores/stella-libretro"
    # remove msse and msse2 flags from Makefile, just a hack here to make it compile on the Raspberry
    sed 's|-msse2 ||g;s|-msse ||g' Makefile >> Makefile.rpi
    make -f Makefile.rpi
    popd    
}

install_doom()
{
    # install Doom WADs emulator core
    printMsg "Installing Doom core"
    if [[ -d "$rootdir/emulatorcores/libretro-prboom" ]]; then
        rm -rf "$rootdir/emulatorcores/libretro-prboom"
    fi
    git clone git://github.com/libretro/libretro-prboom.git "$rootdir/emulatorcores/libretro-prboom"
    pushd "$rootdir/emulatorcores/libretro-prboom"
    make
    cp $rootdir/emulatorcores/libretro-prboom/prboom.wad $rootdir/roms/doom/
    chgrp pi $rootdir/roms/doom/prboom.wad
    chgown $user $rootdir/roms/doom/prboom.wad
    popd
}

install_gba()
{
    # install Game Boy Advance emulator core
    printMsg "Installing Game Boy Advancecore"
    if [[ -d "$rootdir/emulatorcores/vba-next" ]]; then
        rm -rf "$rootdir/emulatorcores/vba-next"
    fi
    git clone git://github.com/libretro/vba-next.git "$rootdir/emulatorcores/vba-next"
    pushd "$rootdir/emulatorcores/vba-next"
    make -f Makefile.libretro
    popd    
}

install_gbc()
{
    # install Game Boy Color emulator core
    printMsg "Installing Game Boy Color core"
    if [[ -d "$rootdir/emulatorcores/gambatte-libretro/libgambatte" ]]; then
        rm -rf "$rootdir/emulatorcores/gambatte-libretro/libgambatte"
    fi
    git clone git://github.com/libretro/gambatte-libretro.git "$rootdir/emulatorcores/gambatte-libretro"
    pushd "$rootdir/emulatorcores/gambatte-libretro/libgambatte"
    make -f Makefile.libretro 
    popd
}

install_mame()
{
    # install MAME emulator core
    printMsg "Installing MAME core"
    if [[ -d "$rootdir/emulatorcores/imame4all-libretro" ]]; then
        rm -rf "$rootdir/emulatorcores/imame4all-libretro"
    fi
    git clone git://github.com/libretro/imame4all-libretro.git "$rootdir/emulatorcores/imame4all-libretro"
    pushd "$rootdir/emulatorcores/imame4all-libretro"
    make -f makefile.libretro ARM=1
    popd
}

install_nes()
{
    # install NES emulator core
    printMsg "Installing NES core"
    if [[ -d "$rootdir/emulatorcores/fceu-next" ]]; then
        rm -rf "$rootdir/emulatorcores/fceu-next"
    fi
    git clone git://github.com/libretro/fceu-next.git "$rootdir/emulatorcores/fceu-next"
    pushd "$rootdir/emulatorcores/fceu-next"
    make -f Makefile.libretro-fceumm
    popd
}

install_megadrive()
{
    # install Sega Mega Drive emulator core
    printMsg "Installing Mega Drive core"
    if [[ -d "$rootdir/emulatorcores/Genesis-Plus-GX" ]]; then
        rm -rf "$rootdir/emulatorcores/Genesis-Plus-GX"
    fi
    git clone git://github.com/libretro/Genesis-Plus-GX.git "$rootdir/emulatorcores/Genesis-Plus-GX"
    pushd "$rootdir/emulatorcores/Genesis-Plus-GX"
    make -f Makefile.libretro 
    sed /etc/retroarch.cfg -i -e "s|# system_directory =|system_directory = $rootdir/emulatorcores/|g"
    popd
}

install_snes()
{
    # install SNES emulator core
    printMsg "Installing SNES core"
    if [[ -d "$rootdir/emulatorcores/pocketsnes-libretro" ]]; then
        rm -rf "$rootdir/emulatorcores/pocketsnes-libretro"
    fi
    git clone git://github.com/ToadKing/pocketsnes-libretro.git "$rootdir/emulatorcores/pocketsnes-libretro"
    pushd "$rootdir/emulatorcores/pocketsnes-libretro"
    make
    popd
}

install_bcmlibrary()
{
    # install BCM library to enable GPIO access by SNESDev-RPi
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

install_snesdev()
{
    # install SNESDev as GPIO interface for SNES controllers
    printMsg "Installing SNESDev as GPIO interface for SNES controllers"
    if [[ -d "$rootdir/SNESDev-Rpi" ]]; then
        rm -rf "$rootdir/SNESDev-Rpi"
    fi
    git clone git://github.com/petrockblog/SNESDev-RPi.git "$rootdir/SNESDev-Rpi"
    pushd "$rootdir/SNESDev-Rpi"
    make clean
    make
    popd
}

install_esscript()
{
    if [[ ! -f /usr/bin/emulationstation.sh ]]; then
        # a work around here, so that EmulationStation can be executed from arbitrary locations
        echo -e "#!/bin/bash\npushd \"$rootdir/EmulationStation\"\n./emulationstation\npopd\n" > /usr/bin/emulationstation
        sudo chmod +x /usr/bin/emulationstation
    fi
}

install_emulationstation()
{
    # install EmulationStation as graphical front end for the emulators
    printMsg "Installing EmulationStation as graphical front end"
    if [[ -d "$rootdir/EmulationStation" ]]; then
        rm -rf "$rootdir/EmulationStation"
    fi
    git clone git://github.com/Aloshi/EmulationStation.git "$rootdir/EmulationStation"
    pushd "$rootdir/EmulationStation"
    make clean
    make
    install_esscript
    popd
}

generate_esconfig()
{
    # generate EmulationStation configuration
    printMsg "Generating configuration file ~/.emulationstation/es_systems.cfg for EmulationStation"
    if [[ ! -d "$rootdir/../.emulationstation" ]]; then
        mkdir $rootdir/../.emulationstation
    fi
    cat > $rootdir/../.emulationstation/es_systems.cfg << _EOF_
NAME=Atari 2600
PATH=$rootdir/roms/atari2600
EXTENSION=.bin
COMMAND=retroarch -L $rootdir/emulatorcores/stella-libretro/libretro.so %ROM%

NAME=Doom
PATH=$rootdir/roms/doom
EXTENSION=.WAD
COMMAND=retroarch -L $rootdir/emulatorcores/libretro-prboom/libretro.so %ROM%

NAME=Game Boy Advance
PATH=$rootdir/roms/gba
EXTENSION=.gba
COMMAND=retroarch -L $rootdir/emulatorcores/vba-next/libretro.so %ROM%

NAME=Game Boy Color
PATH=$rootdir/roms/gbc
EXTENSION=.gb
COMMAND=retroarch -L $rootdir/emulatorcores/gambatte-libretro/libgambatte/libretro.so %ROM%

NAME=Sega Mega Drive
PATH=$rootdir/roms/megadrive
EXTENSION=.smd
COMMAND=retroarch -L $rootdir/emulatorcores/Genesis-Plus-GX/libretro.so %ROM%

NAME=Nintendo Entertainment System
PATH=$rootdir/roms/nes
EXTENSION=.nes
COMMAND=retroarch -L $rootdir/emulatorcores/fceu-next/libretro.so %ROM%

NAME=Super Nintendo
PATH=$rootdir/roms/snes
EXTENSION=.smc
COMMAND=retroarch -L $rootdir/emulatorcores/pocketsnes-libretro/libretro.so %ROM%

NAME=MAME
PATH=$rootdir/roms/mame
EXTENSION=.zip
COMMAND=retroarch -L $rootdir/emulatorcores/imame4all-libretro/libretro.so %ROM%    

_EOF_

}

sortromsalphabet()
{
    pathlist[0]="$rootdir/roms/atari2600"
    pathlist[1]="$rootdir/roms/gba"
    pathlist[2]="$rootdir/roms/gbc"
    pathlist[3]="$rootdir/roms/mame"
    pathlist[4]="$rootdir/roms/megadrive"
    pathlist[5]="$rootdir/roms/nes"
    pathlist[6]="$rootdir/roms/snes"  
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
        fi
    done  
}

downloadBinaries()
{
    wget https://github.com/downloads/petrockblog/RetroPie-Setup/RetroPieSetupBinaries.tar.bz2
    tar -jxvf RetroPieSetupBinaries.tar.bz2 -C $rootdir
    pushd $rootdir/RetroPie
    mv * ../
    popd
    rm -rf $rootdir/RetroPie
    rm RetroPieSetupBinaries.tar.bz2
}

setArmFreq()
{
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose the ARM frequency." 22 76 16)
    options=(700 "(default)"
             750 "(do this at your own risk!)"
             800 "(do this at your own risk!)"
             850 "(do this at your own risk!)"
             900 "(do this at your own risk!)")
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

main_binaries()
{
    clear
    printMsg "Binaries-based installation"

    update_apt
    installAPTPackages
    ensure_modules
    add_to_groups
    exportSDLNOMOUSE
    downloadBinaries
    install_esscript
    generate_esconfig
    install -m755 $rootdir/RetroArch-Rpi/retroarch /usr/local/bin 
    install -m644 $rootdir/RetroArch-Rpi/retroarch.cfg /etc/retroarch.cfg
    install -m755 $rootdir/RetroArch-Rpi/retroarch-zip /usr/local/bin
    sed /etc/retroarch.cfg -i -e "s|# system_directory =|system_directory = $rootdir/emulatorcores/|g"
    prepareFolders

    chgrp -R $user $rootdir
    chown -R $user $rootdir

    dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 22 76    
}

showHelp()
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

changeBootbehaviour()
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

checkNeededPackages()
{
    doexit=0
    type -P git &>/dev/null && echo "Found git command." || { echo "Did not find git. Try 'sudo apt-get install -y git' first."; doexit=1; }
    type -P dialog &>/dev/null && echo "Found dialog command." || { echo "Did not find dialog. Try 'sudo apt-get install -y dialog' first."; doexit=1; }
    if [[ doexit -eq 1 ]]; then
        exit 1
    fi
}

main_options()
{
    cmd=(dialog --separate-output --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --checklist "Select options with 'space' and arrow keys. The default selection installs a complete set of packages." 22 76 16)
    options=(1 "Install latest rpi-update script" ON     # any option can be set to default to "on"
             2 "Update APT repositories" ON \
             3 "Perform APT upgrade" ON \
             4 "Add user $user to groups video, audio, and input" ON \
             5 "Enable modules ALSA, uinput, and joydev" ON \
             6 "Export SDL_NOMOUSE=1" ON \
             7 "Install all needed APT packages" ON \
             8 "Generate folder structure" ON \
             9 "Install RetroArch" ON \
             10 "Install Atari 2600 core" ON \
             11 "Install Doom core" ON \
             12 "Install Game Boy Advance core" ON \
             13 "Install Game Boy Color core" ON \
             14 "Install MAME core" ON \
             15 "Install Mega Drive core" ON \
             16 "Install NES core" ON \
             17 "Install Super NES core" ON \
             18 "Install BCM library" ON \
             19 "Install SNESDev" ON \
             20 "Install Emulation Station" ON \
             21 "Generate config file for Emulation Station" ON )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    if [ "$choices" != "" ]; then
        for choice in $choices
        do
            case $choice in
                1) install_rpiupdate ;;
                2) update_apt ;;
                3) upgrade_apt ;;
                4) add_to_groups ;;
                5) ensure_modules ;;
                6) exportSDLNOMOUSE ;;
                7) installAPTPackages ;;
                8) prepareFolders ;;
                9) install_retroarch ;;
                10) install_atari2600 ;;
                11) install_doom ;;
                12) install_gba ;;
                13) install_gbc ;;
                14) install_mame ;;
                15) install_megadrive ;;
                16) install_nes ;;
                17) install_snes ;;
                18) install_bcmlibrary ;;
                19) install_snesdev ;;
                20) install_emulationstation ;;
                21) generate_esconfig ;;
            esac
        done

        chgrp -R $user $rootdir
        chown -R $user $rootdir

        dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --msgbox "Finished tasks.\nStart the front end with 'emulationstation'. You now have to copy roms to the roms folders. Have fun!" 20 60    
    fi
}

main_setup()
{
    while true; do
        cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose installation either based on binaries or on sources." 22 76 16)
        options=(1 "Re-generate config file for Emulation Station" 
                 2 "Install latest Rasperry Pi firmware" 
                 3 "Sort roms alphabetically within folders. *Creates subfolders*" 
                 4 "Start Emulation Station on boot?" 
                 5 "Change ARM frequency" )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
        if [ "$choices" != "" ]; then
            case $choices in
                1) generate_esconfig ;;
                2) run_rpiupdate ;;
                3) sortromsalphabet ;;
                4) changeBootbehaviour ;;
                5) setArmFreq ;;
            esac
        else
            break
        fi
    done    
}

# here starts the main loop

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

home=$(eval echo ~$user)

if [[ ! -d $rootdir ]]; then
    mkdir -p "$rootdir"
    if [[ ! -d $rootdir ]]; then
      echo "Couldn't make directory $rootdir"
      exit 1
    fi
fi

availFreeDiskSpace 300000

while true; do
    cmd=(dialog --backtitle "PetRockBlock.com - RetroPie Setup. Installation folder: $rootdir for user $user" --menu "Choose installation either based on binaries or on sources." 22 76 16)
    options=(1 "Binaries-based installation (faster, (probably) not the newest)"
             2 "Source-based (custom) installation (slower, newest)"
             3 "Setup (only if you already have run one of the installations above)")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        case $choices in
            1) main_binaries
               break ;;
            2) main_options ;;
            3) main_setup ;;
        esac
    else
        break
    fi
done
clear
