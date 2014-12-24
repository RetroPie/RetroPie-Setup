rp_module_id="dispmanx"
rp_module_desc="Configure emulators to use dispmanx SDL"
rp_module_menus="3+"

function configure_dispmanx() {
    local options=()
    local command=()
    local count=1
    local mod_id
    local function
    for idx in "${__mod_idx[@]}"; do
        if [[ $idx < 200 ]]; then
            mod_id=${__mod_id[idx]}
            local function="configure_dispmanx_on_${mod_id}"
            if fn_exists $function; then
                options+=($count "Enable for $mod_id")
                command[$count]="$mod_id configure_dispmanx_on"
                ((count++))
                options+=($count "Disable for $mod_id")
                command[$count]="$mod_id configure_dispmanx_off"
                ((count++))
            fi
        fi
    done
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure emulators to use dispmanx SDL" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [ "$choice" != "" ]; then
            rp_callModule ${command[$choice]}
        else
            break
        fi
    done
}