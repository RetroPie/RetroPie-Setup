rp_module_id="uae4all"
rp_module_desc="Amiga emulator UAE4All"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_uae4all() {
    checkNeededPackages libsdl1.2-dev libsdl-mixer1.2-dev libasound2-dev libguichan-sdl-0.8.1-1 libguichan-0.8.1-1
}

function sources_uae4all() {
    wget -O- -q ftp://researchlab.spdns.de/rpi/uae4all/uae4all-2.5.3.2-1rpi.tgz | tar -xvz --strip-components=1
}


function install_uae4all() {
    md_ret_files=(
        'amiga'
        'conf'
        'data'
        'kickstarts'
        'lib'
        'license.txt'
        'readme.txt'
        'saves'
        'uae4all'
    )
}

function configure_uae4all() {
    mkRomDir "amiga"

    cat > "$md_inst/startAmigaDisk.sh" << _EOF_
#!/bin/bash

file="\$1"
[ -z "\$file" ] && exit 1

pushd "$md_inst"

ROMDIR=\$(dirname "\$file")
echo "path=\"\${ROMDIR}\"" > ./conf/adfdir.conf

$rootdir/supplementary/runcommand/runcommand.sh 1 ./uae4all "$md_id"
popd
_EOF_
    chmod +x "$md_inst/startAmigaDisk.sh"

    chown -R $user:$user "$md_inst"

    setESSystem "Amiga" "amiga" "~/RetroPie/roms/amiga" ".adf .ADF" "$md_inst/startAmigaDisk.sh %ROM%" "amiga" "amiga"

    __INFMSGS="$__INFMSGS The Amiga emulator can be started from command line with '$md_inst/uae4all'. Note that you must manually copy a Kickstart rom with the name 'kick.rom' to the directory $md_inst/uae4all/."
}
