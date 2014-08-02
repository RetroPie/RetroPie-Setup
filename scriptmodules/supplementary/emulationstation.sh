rp_module_id="emulationstation"
rp_module_desc="EmulationStation"
rp_module_menus="2+"

function depen_emulationstation() {
    rps_checkNeededPackages \
        libboost-system-dev libboost-filesystem-dev libboost-date-time-dev \
        libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev \
        libasound2-dev cmake g++-4.7
}

function sources_emulationstation() {
    # sourced of EmulationStation
    gitPullOrClone "$rootdir/supplementary/EmulationStation" "https://github.com/Aloshi/EmulationStation" || return 1
    pushd "$rootdir/supplementary/EmulationStation" || return 1
    git pull || return 1
    git checkout unstable || return 1
    popd
}

function build_emulationstation() {
    # EmulationStation
    pushd "$rootdir/supplementary/EmulationStation" || return 1
    cmake -D CMAKE_CXX_COMPILER=g++-4.7 . || return 1
    make || return 1
    popd
}

function install_emulationstation() {
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
        # make sure that ES has enough GPU memory
        ensureKeyValueBootconfig "gpu_mem" 256 "/boot/config.txt"
        ensureKeyValueBootconfig "overscan_scale" 1 "/boot/config.txt"
        return 0
    else
        return 1
    fi
}

function configure_emulationstation() {
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

    setESSystem "Input Configuration" "esconfig" "~/RetroPie/roms/esconfig" ".py .PY" "%ROM%" "ignore" "esconfig"
    chmod 644 "/etc/emulationstation/es_systems.cfg"
}

function package_emulationstation() {
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
