rp_module_id="scummvm"
rp_module_desc="ScummVM"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_scummvm() {
    getDepends libsdl1.2-dev libjpeg8-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev libpng12-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev zlib1g-dev
}

function sources_scummvm() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/scummvm-1.7.0.tar.gz | tar -xvz --strip-components=1
}

function build_scummvm() {
    ./configure --enable-vkeybd --enable-release --disable-debug --enable-keymapper --disable-eventrecorder --prefix="$md_inst"
    make clean
    make
    strip "$md_build/scummvm"
    md_ret_require="$md_build/scummvm"
}

function install_scummvm() {
    make install
    mkdir -p "$md_inst/extra"
    cp -v backends/vkeybd/packs/vkeybd_*.zip "$md_inst/extra"
}

function configure_scummvm() {
    mkRomDir "scummvm"

    # Create startup script
    cat > "$romdir/scummvm/+Launch GUI.sh" << _EOF_
#!/bin/bash
game="\$1"
[[ "\$game" =~ ^\+ ]] && game=""
$md_inst/bin/scummvm --joystick=0 --extrapath="$md_inst/extra" \$game
while read line; do
    id=(\$line);
    touch "$romdir/scummvm/\$id.svm"
done < <($md_inst/bin/scummvm --list-targets | tail -n +3)
_EOF_
    chown $user:$user "$romdir/scummvm/+Launch GUI.sh"
    chmod u+x "$romdir/scummvm/+Launch GUI.sh"

    setESSystem "ScummVM" "scummvm" "~/RetroPie/roms/scummvm" ".sh .svm" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$romdir/scummvm/+Launch\ GUI.sh %BASENAME%\" \"$md_id\"" "pc" "scummvm"
}
