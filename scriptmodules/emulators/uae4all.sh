rp_module_id="uae4all"
rp_module_desc="Amiga emulator UAE4All"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_uae4all() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libasound2-dev
}

function sources_uae4all() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/uae4rpi.tar.bz2 | tar -xvj --strip-components=1
    sed -i "s/-lstdc++$/-lstdc++ -lm -lz/" Makefile
}

function build_uae4all() {
    touch /opt/vc/include/interface/vmcs_host/vchost_config.h
    make clean
    make
    md_ret_require="$md_build/uae4all"
}

function install_uae4all() {
    md_ret_files=(
        'COPYING'
        'docs'
        'uae4all'
    )
}

function configure_uae4all() {
    mkRomDir "amiga"

    cat > "$md_inst/startAmigaDisk.sh" << _EOF_
#!/bin/bash

file="\$1"
[[ -z "\$file" ]] && exit 1

pushd "$md_inst"
rm -rf df0.adf
ln -s "\$file" df0.adf
$rootdir/supplementary/runcommand/runcommand.sh 1 ./uae4all "$md_id"
popd
_EOF_
    chmod +x "$md_inst/startAmigaDisk.sh"

    chown -R $user:$user "$md_inst"

    setESSystem "Amiga" "amiga" "~/RetroPie/roms/amiga" ".adf .ADF" "$md_inst/startAmigaDisk.sh %ROM%" "amiga" "amiga"

    __INFMSGS="$__INFMSGS The Amiga emulator can be started from command line with '$md_inst/uae4all'. Note that you must manually copy a Kickstart rom with the name 'kick.rom' to the directory $md_inst/uae4all/."
}
