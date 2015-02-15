rp_module_id="stella"
rp_module_desc="Atari2600 emulator STELLA"
rp_module_menus="2+"
rp_module_flags="dispmanx nobin"

function install_stella()
{
    aptInstall stella
}

function configure_stella() {
    mkRomDir "atari2600-stella"

    setDispmanx "$md_id" 1

    # when not using dispmanx
    if [[ -z $(grep "mode \"320x240\"" /etc/fb.modes) ]]; then
        echo -e "\nmode \"320x240\"\ngeometry 320 240 640 480 16\ntimings 0 0 0 0 0 0 0\nrgba 5/11,6/5,5/0,0/16\nendmode" >> /etc/fb.modes
    fi

    setESSystem "Atari 2600" "atari2600" "~/RetroPie/roms/atari2600-stella" ".a26 .A26 .bin .BIN .rom .ROM .zip .ZIP .gz .GZ" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"stella -maxres 320x240 %ROM%\" \"$md_id\"" "atari2600" "atari2600"
}
