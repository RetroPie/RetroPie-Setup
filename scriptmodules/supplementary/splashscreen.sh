rp_module_id="splashscreen"
rp_module_desc="Select Splashscreen"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_splashscreen() {
    printMsg "Configuring splashscreen"

    local options
    local ctr

    ctr=0
    pushd $scriptdir/supplementary/splashscreens/ > /dev/null
    options=()
    dirlist=()
    for splashdir in $(find . -type d | sort) ; do
        if [[ $splashdir != "." ]]; then
            options+=($ctr "${splashdir:2}")
            dirlist+=(${splashdir:2})
            ctr=$((ctr + 1))
        fi
    done
    popd > /dev/null
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    __ERRMSGS=""
    __INFMSGS=""
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    splashdir=${dirlist[$choices]}
    if [[ -n "$choices" ]]; then
        rm /etc/splashscreen.list
        find $scriptdir/supplementary/splashscreens/$splashdir/ -type f | sort | while read line; do
            echo $line >> /etc/splashscreen.list
        done
        dialog --backtitle "$__backtitle" --msgbox "Splashscreen set to '$splashdir'." 20 60
    fi
}