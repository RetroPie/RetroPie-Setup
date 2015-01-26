rp_module_id="linapple"
rp_module_desc="Apple 2 emulator Linapple"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_linapple() {
    getDepends libzip2 libzip-dev libsdl1.2-dev libcurl4-openssl-dev
}

function sources_linapple() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/linapple-src_2a.tar.bz2 | tar -xvj --strip-components=1
    addLineToFile "#include <unistd.h>" "src/Timer.h"
}

function build_linapple() {
    cd src
    make clean
    make
}

function install_linapple() {
    mkdir -p "$md_inst/ftp/cache"
    mkdir -p "$md_inst/images"
    md_ret_files=(
        'CHANGELOG'
        'INSTALL'
        'LICENSE'
        'linapple'
        'charset40.bmp'
        'font.bmp'
        'icon.bmp'
        'linapple.conf'
        'splash.bmp'
        'Master.dsk'
        'README'
    )
}

function configure_linapple() {
    mkRomDir "apple2"

    chown -R $user:$user "$md_inst"

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

    setESSystem "Apple II" "apple2" "~/RetroPie/roms/apple2" ".txt" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/Start.sh\" \"$md_id\"" "apple2" "apple2"
}
