rp_module_id="uae4all"
rp_module_desc="Amiga emulator UAE4All"
rp_module_menus="2+"

function depends_uae4all() {
    rps_checkNeededPackages libsdl1.2-dev libsdl-mixer1.2-dev libasound2-dev
}

function sources_uae4all() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/uae4rpi.tar.bz2 | tar -xvj --strip-components=1
    sed -i "s/-lstdc++$/-lstdc++ -lm -lz/" Makefile
}

function build_uae4all() {
    touch /opt/vc/include/interface/vmcs_host/vchost_config.h
    make clean
    make
    require="$builddir/$1/uae4all"
}

function install_uae4all() {
    files=(
        'COPYING'
        'docs'
        'uae4all'
    )
}

function configure_uae4all() {
    mkdir -p "$romdir/amiga"

    cat > "$emudir/$1/startAmigaDisk.sh" << _EOF_
#!/bin/bash
pushd "$emudir/$1"
if [[ -f "df0.adf" ]]; then
     rm df0.adf
 fi
ln -s "$romdir/amiga/$1" "df0.adf"
./uae4all    
popd
_EOF_
    chmod +x "$emudir/$1/startAmigaDisk.sh"

    chown -R $user:$user "$emudir/$1"

    setESSystem "Amiga" "amiga" "~/RetroPie/roms/amiga" ".adf .ADF" "$emudir/$1/startAmigaDisk.sh %ROM%" "amiga" "amiga"
}
