rp_module_id="linapple"
rp_module_desc="Apple 2 emulator Linapple"
rp_module_menus="2+"

function depends_linapple() {
    rps_checkNeededPackages libzip2 libzip-dev
}

function sources_linapple() {
    rmDirExists "$rootdir/emulators/apple2"
    mkdir -p "$rootdir/emulators"
    wget http://downloads.petrockblock.com/retropiearchives/linapple-src_2a.tar.bz2
    tar -jxvf linapple-src_2a.tar.bz2 -C "$rootdir/emulators/"
    rm linapple-src_2a.tar.bz2
}

function build_linapple() {
    pushd "$rootdir/emulators/linapple-src_2a/src"
    make CXX="g++-4.6"
    popd
}

function configure_linapple() {
    if [[ ! -d $romdir/apple2 ]]; then
        mkdir -p $romdir/apple2
    fi
    cat > "$rootdir/emulators/linapple-src_2a/Start.sh" << _EOF_
#!/bin/bash
pushd $rootdir/emulators/linapple-src_2a
./linapple
popd
_EOF_
    chmod +x "$rootdir/emulators/linapple-src_2a/Start.sh"
    touch $romdir/apple2/Start.txt

    pushd "$rootdir/emulators/linapple-src_2a"
    sed -i -r -e "s|[^I]?Joystick 0[^I]?=[^I]?[0-9]|\tJoystick 0\t=\t1|g" linapple.conf
    sed -i -r -e "s|[^I]?Joystick 1[^I]?=[^I]?[0-9]|\tJoystick 1\t=\t1|g" linapple.conf
    popd

    setESSystem "Apple II" "apple2" "~/RetroPie/roms/apple2" ".txt" "$rootdir/emulators/linapple-src_2a/Start.sh" "apple2" "apple2"

}