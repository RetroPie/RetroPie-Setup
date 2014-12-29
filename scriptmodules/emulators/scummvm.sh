rp_module_id="scummvm"
rp_module_desc="ScummVM"
rp_module_menus="2+"

function install_scummvm() {
    aptInstall scummvm scummvm-data
    if [[ $? -gt 0 ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully install ScummVM."
    else
        __INFMSGS="$__INFMSGS ScummVM has successfully been installed. You can start the ScummVM GUI by typing 'scummvm' in the console. Copy your Scumm games into the directory '$rootdir/roms/scummvm'. When you get a blank screen after running scumm for the first time, press CTRL-q. You should not get a blank screen with further runs of scummvm."
    fi
}

function configure_scummvm() {
    mkRomDir "scummvm"

    setESSystem "ScummVM" "scummvm" "~/RetroPie/roms/scummvm" ".exe .EXE" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"scummvm\"" "pc" "scummvm"
}
