# Jason Whiteman's first attempt at an install script for RetroPie  

rp_module_id="yabause"
rp_module_desc="Yabause 0.9.13.1 Sega Saturn Emulation"
# JWW Comment: I'm not sure what this means 2+ but (most) all other scripts seem to have it.  One has 4+ that I checked
rp_module_menus="2+"

function depends_yabause() {
     rps_checkNeededPackages libsdl1.2-dev qt4-dev-tools cmake subversion
}

function sources_yabause() {

# JWW Comment: I'd prefer to be prompted to blow away the directory, but not addressing
    rmDirExists "$rootdir/emulators/yabause-0.9.13.1"
    wget -O yabause-0.9.13.1.tar.gz "http://sourceforge.net/projects/yabause/files/yabause/0.9.13/yabause-0.9.13.1.tar.gz/download"
    mkdir -p "$rootdir/emulators"
    tar vxzf yabause-0.9.13.1.tar.gz -C "$rootdir/emulators"
    rm yabause-0.9.13.1.tar.gz
}

function build_yabause() {
    pushd "$rootdir/emulators/yabause-0.9.31.1"
    cmake src
    make
    if [[ ! -f "$rootdir/emulators/yabause-0.9.31.1/qt/yabause" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile YABAUSE."
    fi
    popd
}

function configure_yabause() {
    mkdir -p $romdir/saturn-yabause

# Not sure of the format here yet, best guess without "reading the manual"

    setESSystem "Sega Saturn" "saturn-yabause" "RetroPie/roms/saturn-yabause" ".iso .ISO" "$rootdir/emulators/yabause-0.9.13.1/qt/yabause -i %ROM%" "saturn-yabause" "saturn-yabause"
}

