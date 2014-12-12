rp_module_id="linapple"
rp_module_desc="Apple 2 emulator Linapple"
rp_module_menus="2+"

function depends_linapple() {
    rps_checkNeededPackages libzip2 libzip-dev libsdl1.2-dev libcurl3 zlib1g 
}

function sources_linapple() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/linapple-src_2a.tar.bz2 | tar -xvj --strip-components=1
}

function build_linapple() {
    cd src
    make clean
    make CXX="g++-4.6"
}

function install_linapple() {
    files=(
        'CHANGELOG'
        'INSTALL'
        'LICENSE'
        'linapple'
        'charset40.bmp'
        'font.bmp'
        'icon.bmp'
        'linapple1.bmp'
        'linapple2.bmp'
        'linapple3.bmp'
        'linapple4.bmp'
        'linapple5.bmp'
        'linapple.conf'
        'splash.bmp'
        'Master.dsk'
        'README'
    )
}

function configure_linapple() {
    mkdir -p $romdir/apple2

    cat > "Start.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./linapple
popd
_EOF_
    chmod +x Start.sh
    touch "$romdir/apple2/Start.txt"

    sed -i -r -e "s|[^I]?Joystick 0[^I]?=[^I]?[0-9]|\tJoystick 0\t=\t1|g" linapple.conf
    sed -i -r -e "s|[^I]?Joystick 1[^I]?=[^I]?[0-9]|\tJoystick 1\t=\t1|g" linapple.conf

    setESSystem "Apple II" "apple2" "~/RetroPie/roms/apple2" ".txt" "$md_inst/Start.sh" "apple2" "apple2"
}