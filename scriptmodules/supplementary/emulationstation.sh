rp_module_id="emulationstation"
rp_module_desc="EmulationStation"
rp_module_menus="2+"

function depen_emulationstation() {
    rps_checkNeededPackages \
        libboost-system-dev libboost-filesystem-dev libboost-date-time-dev \
        libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev \
        libasound2-dev cmake g++-4.7
}

function sources_EmulationStation() {
    # sourced of EmulationStation
    gitPullOrClone "$rootdir/supplementary/EmulationStation" "https://github.com/Aloshi/EmulationStation" || return 1
    pushd "$rootdir/supplementary/EmulationStation" || return 1
    git pull || return 1
    git checkout unstable || return 1
    popd
}

function build_EmulationStation() {
    # EmulationStation
    pushd "$rootdir/supplementary/EmulationStation" || return 1
    cmake -D CMAKE_CXX_COMPILER=g++-4.7 . || return 1
    make || return 1
    popd
}

function install_EmulationStation() {
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

    if [[ -f "$rootdir/supplementary/EmulationStation/emulationstation" ]]; then
        return 0
    else
        return 1
    fi

    # make sure that ES has enough GPU memory
    ensureKeyValueBootconfig "gpu_mem" 256 "/boot/config.txt"
    ensureKeyValueBootconfig "overscan_scale" 1 "/boot/config.txt"
}

function configure_EmulationStation() {
    if [[ $__netplayenable == "E" ]]; then
         local __tmpnetplaymode="-$__netplaymode "
         local __tmpnetplayhostip_cfile=$__netplayhostip_cfile
         local __tmpnetplayport="--port $__netplayport "
         local __tmpnetplayframes="--frames $__netplayframes"
     else
         local __tmpnetplaymode=""
         local __tmpnetplayhostip_cfile=""
         local __tmpnetplayport=""
         local __tmpnetplayframes=""
     fi

    mkdir -p "/etc/emulationstation"

    cat > "/etc/emulationstation/es_systems.cfg" << _EOF_
<systemList>

    <system>
        <fullname>Amiga</fullname>
        <name>amiga</name>
        <path>~/RetroPie/roms/amiga</path>
        <extension>.adf .ADF</extension>
        <command>$rootdir/emulators/uae4rpi/startAmigaDisk.sh %ROM%</command>
        <platform>amiga</platform>
        <theme>amiga</theme>
    </system>

    <system>
        <fullname>Apple II</fullname>
        <name>apple2</name>
        <path>~/RetroPie/roms/apple2</path>
        <extension>.txt</extension>
        <command>$rootdir/emulators/linapple-src_2a/Start.sh</command>
        <platform>apple2</platform>
        <theme>apple2</theme>
    </system>

    <system>
        <fullname>Atari 800</fullname>
        <name>atari800</name>
        <path>~/RetroPie/roms/atari800</path>
        <extension>.xex .XEX</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/atari800-3.0.0/installdir/bin/atari800 %ROM%"</command>
        <platform>atari800</platform>
        <theme>atari800</theme>
    </system>

    <system>
        <fullname>Atari 2600</fullname>
        <name>atari2600</name>
        <path>~/RetroPie/roms/atari2600</path>
        <extension>.a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ</extension>
        <!-- alternatively: <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "stella %ROM%"</command> -->
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/atari2600/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%"</command>
        <platform>atari2600</platform>
        <theme>atari2600</theme>
    </system>

    <system>
        <fullname>Atari ST/STE/Falcon</fullname>
        <name>atariststefalcon</name>
        <path>~/RetroPie/roms/atariststefalcon</path>
        <extension>.st .ST .img .IMG .rom .ROM .ipf .IPF</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "hatari %ROM%"</command>
        <platform>atarist</platform>
        <theme>atarist</theme>
    </system>

    <system>
        <fullname>Apple Macintosh</fullname>
        <name>macintosh</name>
        <path>~/RetroPie/roms/macintosh</path>
        <extension>.txt</extension>
        <!-- alternatively: <command>sudo modprobe snd_pcm_oss && xinit $rootdir/emulators/basiliskii/installdir/bin/BasiliskII</command> -->
        <!-- ~/.basilisk_ii_prefs: Setup all and everything under X, enable fullscreen and disable GUI -->
        <command>xinit $rootdir/emulators/basiliskii/installdir/bin/BasiliskII</command>
        <theme>macintosh</theme>
    </system>

    <system>
        <fullname>C64</fullname>
        <name>c64</name>
        <path>~/RetroPie/roms/c64</path>
        <extension>.crt .CRT .d64 .D64 .g64 .G64 .t64 .T64 .tap .TAP .x64 .X64 .zip .ZIP</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/vice-2.4/installdir/bin/x64 -sdlbitdepth 16 %ROM%"</command>
        <platform>c64</platform>
        <theme>c64</theme>
    </system>

    <system>
        <fullname>Amstrad CPC</fullname>
        <name>amstradcpc</name>
        <path>~/RetroPie/roms/amstradcpc</path>
        <extension>.cpc .CPC .dsk .DSK</extension>
        <command>$rootdir/emulators/cpc4rpi-1.1/cpc4rpi %ROM%</command>
        <theme>amstradcpc</theme>
    </system>

    <system>
        <fullname>Final Burn Alpha</fullname>
        <name>fba</name>
        <path>~/RetroPie/roms/fba</path>
        <extension>.zip .ZIP .fba .FBA</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/pifba/fba2x %ROM%" </command>
        <!-- alternatively: <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/fba-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/fba/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%"</command> -->
        <platform>arcade</platform>
        <theme></theme>
    </system>

    <system>
        <fullname>Game Boy</fullname>
        <name>gb</name>
        <path>~/RetroPie/roms/gb</path>
        <extension>.gb .GB</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/gambatte-libretro/libgambatte/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gb/retroarch.cfg %ROM%"</command>
        <platform>gb</platform>
        <theme>gb</theme>
    </system>

    <system>
        <fullname>Game Boy Advance</fullname>
        <name>gba</name>
        <path>~/RetroPie/roms/gba</path>
        <extension>.gba .GBA</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/gpsp/raspberrypi/gpsp %ROM%"</command>
        <platform>gba</platform>
        <theme>gba</theme>
    </system>

    <system>
        <fullname>Game Boy Color</fullname>
        <name>gbc</name>
        <path>~/RetroPie/roms/gbc</path>
        <extension>.gbc .GBC</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/gambatte-libretro/libgambatte/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/gbc/retroarch.cfg %ROM%"</command>
        <platform>gbc</platform>
        <theme>gbc</theme>
    </system>

    <system>
        <fullname>Sega Game Gear</fullname>
        <name>gamegear</name>
        <path>~/RetroPie/roms/gamegear</path>
        <extension>.gg .GG</extension>
        <command>$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose %ROM% -joy -tv -fs</command>
        <platform>gamegear</platform>
        <theme>gamegear</theme>
    </system>

    <system>
        <fullname>Intellivision</fullname>
        <name>intellivision</name>
        <path>~/RetroPie/roms/intellivision</path>
        <extension>.int .INT .bin .BIN</extension>
        <command>$rootdir/emulators/jzintv-1.0-beta4/bin/jzintv -z1 -f1 -q %ROM%</command>
        <platform>intellivision</platform>
        <theme></theme>
    </system>

    <system>
        <fullname>MAME</fullname>
        <name>mame</name>
        <path>~/RetroPie/roms/mame</path>
        <extension>.zip .ZIP</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/mame4all-pi/mame %BASENAME%"</command>
        <!-- alternatively: <command>$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/imame4all-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/mame/retroarch.cfg %ROM% </command> -->
        <platform>arcade</platform>
        <theme>mame</theme>
    </system>

    <system>
        <fullname>MSX</fullname>
        <name>msx</name>
        <path>~/RetroPie/roms/msx</path>
        <extension>.rom .ROM</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/openmsx-0.10.0/derived/arm-linux-opt/bin/openmsx %BASENAME%"</command>
        <platform></platform>
        <theme>msx</theme>
    </system>

    <system>
        <fullname>PC (x86)</fullname>
        <name>pc</name>
        <path>~/RetroPie/roms/pc</path>
        <extension>.txt</extension>
        <command>$rootdir/emulators/rpix86/Start.sh</command>
        <platform>pc</platform>
        <theme>pc</theme>
    </system>

    <system>
        <fullname>NeoGeo</fullname>
        <name>neogeo</name>
        <path>~/RetroPie/roms/neogeo</path>
        <extension>.zip .ZIP .fba .FBA</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/pifba/fba2x %ROM%" </command>
        <!-- alternatively: <command>$rootdir/emulators/gngeo-pi-0.85/installdir/bin/arm-linux-gngeo -i $rootdir/roms/neogeo -B $rootdir/emulators/gngeo-pi-0.85/neogeobios %ROM%</command> -->
        <platform>neogeo</platform>
        <theme>neogeo</theme>
    </system>

    <system>
        <fullname>Nintendo Entertainment System</fullname>
        <name>nes</name>
        <path>~/RetroPie/roms/nes</path>
        <extension>.nes .NES</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/fceu-next/fceumm-code/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/nes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%"</command>
        <platform>nes</platform>
        <theme>nes</theme>
    </system>

    <system>
        <fullname>Nintendo 64</fullname>
        <name>n64</name>
        <path>~/RetroPie/roms/n64</path>
        <extension>.z64 .Z64 .n64 .N64 .v64 .V64</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "cd $rootdir/emulators/mupen64plus-rpi/test/ && ./mupen64plus %ROM%"</command>
        <platform>n64</platform>
        <theme>n64</theme>
    </system>

    <system>
        <fullname>TurboGrafx 16 (PC Engine)</fullname>
        <name>pcengine</name>
        <path>~/RetroPie/roms/pcengine</path>
        <extension>.pce .PCE</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/mednafen-pce-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/pcengine/retroarch.cfg %ROM%"</command>
        <!-- alternatively: <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/mednafenpcefast/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/pcengine/retroarch.cfg %ROM%"</command> -->
        <platform>pcengine</platform>
        <theme>pcengine</theme>
    </system>

    <system>
        <fullname>Ports</fullname>
        <name>ports</name>
        <path>~/RetroPie/roms/ports</path>
        <extension>.sh .SH</extension>
        <command>%ROM%</command>
        <platformid>pc</platformid>
        <theme>ports</theme>
    </system>

    <system>
        <fullname>ScummVM</fullname>
        <name>scummvm</name>
        <path>~/RetroPie/roms/scummvm</path>
        <extension>.exe .EXE</extension>
        <command>scummvm</command>
        <platform>pc</platform>
        <theme>scummvm</theme>
    </system>

    <system>
        <fullname>Sega Master System / Mark III</fullname>
        <name>mastersystem</name>
        <path>~/RetroPie/roms/mastersystem</path>
        <extension>.sms .SMS</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/picodrive/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/mastersystem/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%"</command>
        <!-- alternatively: <command>$rootdir/emulators/osmose-0.8.1+rpi20121122/osmose %ROM% -joy -tv -fs</command> -->
        <platform>mastersystem</platform>
        <theme>mastersystem</theme>
    </system>

    <system>
        <fullname>Sega Mega Drive / Genesis</fullname>
        <name>megadrive</name>
        <path>~/RetroPie/roms/megadrive</path>
        <extension>.smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/picodrive/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/megadrive/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%"</command>
        <!-- alternatively: <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/dgen-sdl/installdir/bin/dgen -f -r $rootdir/configs/all/dgenrc %ROM%"</command> -->
        <!-- alternatively: <command>export LD_LIBRARY_<path>"$rootdir/supplementary/dispmanx/SDL12-kms-dispmanx/build/.libs"; $rootdir/emulators/dgen-sdl/dgen %ROM%</path></command> -->
        <platform>genesis,megadrive</platform>
        <theme>megadrive</theme>
    </system>

    <system>
        <fullname>Sega CD</fullname>
        <name>segacd</name>
        <path>~/RetroPie/roms/segacd</path>
        <extension>.smd .SMD .bin .BIN .md .MD .zip .ZIP .iso .ISO</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L $rootdir/emulatorcores/picodrive/picodrive_libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/segacd/retroarch.cfg  %ROM%"</command>
        <!-- <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/dgen-sdl/dgen -f -r $rootdir/configs/all/dgenrc %ROM%"</command> -->
        <!-- <command>export LD_LIBRARY_<path>"$rootdir/supplementary/dispmanx/SDL12-kms-dispmanx/build/.libs"; $rootdir/emulators/dgen-sdl/dgen %ROM%</path></command> -->
        <platform>segacd</platform>
        <theme>segacd</theme>
    </system>

    <system>
        <fullname>Sega 32X</fullname>
        <name>sega32x</name>
        <path>~/RetroPie/roms/sega32x</path>
        <extension>.32x .32X .smd .SMD .bin .BIN .md .MD .zip .ZIP</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L $rootdir/emulatorcores/picodrive/picodrive_libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/sega32x/retroarch.cfg  %ROM%"</command>
        <!-- <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/dgen-sdl/dgen -f -r $rootdir/configs/all/dgenrc %ROM%"</command> -->
        <!-- <command>export LD_LIBRARY_<path>"$rootdir/supplementary/dispmanx/SDL12-kms-dispmanx/build/.libs"; $rootdir/emulators/dgen-sdl/dgen %ROM%</path></command> -->
        <platform>sega32x</platform>
        <theme>sega32x</theme>
    </system>

    <system>
        <fullname>Sony Playstation 1</fullname>
        <name>psx</name>
        <path>~/RetroPie/roms/psx</path>
        <extension>.img .IMG .7z .7Z .pbp .PBP .bin .BIN .cue .CUE</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/psx/retroarch.cfg %ROM%"</command>
        <platform>psx</platform>
        <theme>psx</theme>
    </system>

    <system>
        <fullname>Super Nintendo</fullname>
        <name>snes</name>
        <path>~/RetroPie/roms/snes</path>
        <extension>.smc .sfc .fig .swc .SMC .SFC .FIG .SWC</extension>
        <command>$rootdir/supplementary/runcommand/runcommand.sh 4 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/snes/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%"</command>
        <!-- alternatively: <command>$rootdir/emulators/snes9x-rpi/snes9x %ROM%</command> -->
        <!-- alternatively: <command>$rootdir/emulators/pisnes/snes9x %ROM%</command> -->
        <platform>snes</platform>
        <theme>snes</theme>
    </system>

    <system>
        <fullname>ZX Spectrum</fullname>
        <name>zxspectrum</name>
        <path>~/RetroPie/roms/zxspectrum</path>
        <extension>.z80 .Z80 .ipf .IPF</extension>
        <command>xinit fuse</command>
        <!-- alternatively: <command>$rootdir/emulators/fbzx-2.10.0/fbzx %ROM%</command> -->
        <platform>zxspectrum</platform>
        <theme>zxspectrum</theme>
    </system>

    <system>
        <fullname>Input Configuration</fullname>
        <name>esconfig</name>
        <path>~/RetroPie/roms/esconfig</path>
        <extension>.py .PY</extension>
        <command>%ROM%</command>
        <platform>ignore</platform>
        <theme>esconfig</theme>
    </system>

</systemList>
_EOF_
chmod 755 "/etc/emulationstation/es_systems.cfg"

}

function package_EmulationStation() {
    local PKGNAME

    rps_checkNeededPackages reprepro

    printMsg "Building package of EmulationStation"

#   # create Raspbian package
#   $PKGNAME="retropie-supplementary-emulationstation"
#   mkdir $PKGNAME
#   mkdir $PKGNAME/DEBIAN
#   cat >> $PKGNAME/DEBIAN/control << _EOF_
# Package: $PKGNAME
# Priority: optional
# Section: devel
# Installed-Size: 1
# Maintainer: Florian Mueller
# Architecture: armhf
# Version: 1.0
# Depends: libboost-system-dev libboost-filesystem-dev libboost-date-time-dev libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev libasound2-dev cmake g++-4.7
# Description: This package contains the front-end EmulationStation.
# _EOF_

#   mkdir -p $PKGNAME/usr/share/RetroPie/supplementary/EmulationStation
#   cd
#   cp -r $rootdir/supplementary/EmulationStation/emulationstation $PKGNAME$rootdir/supplementary/EmulationStation/

#   # create package
#   dpkg-deb -z8 -Zgzip --build $PKGNAME

#   # sign Raspbian package
#   dpkg-sig --sign builder $PKGNAME.deb

#   # add package to repository
#   cd RetroPieRepo
#   reprepro --ask-passphrase -Vb . includedeb wheezy /home/pi/$PKGNAME.deb

}