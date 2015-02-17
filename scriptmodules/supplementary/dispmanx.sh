rp_module_id="dispmanx"
rp_module_desc="Configure emulators to use dispmanx SDL"
rp_module_menus="3+"
rp_module_flags="nobin !odroid"

function configure_dispmanx() {
    while true; do
        local count=1
        local options=()
        local command=()
        source "$configdir/all/dispmanx.cfg"
        for idx in "${__mod_idx[@]}"; do
            [[ $idx -gt 200 ]] && break
            if [[ "${__mod_flags[$idx]}" =~ dispmanx ]]; then
                local mod_id=${__mod_id[idx]}
                if [[ "${!mod_id}" == "1" ]]; then
                    options+=($count "Disable for $mod_id (currently enabled)")
                    command[$count]="$mod_id off"
                else
                    options+=($count "Enable for $mod_id (currently disabled)")
                    command[$count]="$mod_id on"
                fi
                ((count++))
            fi
        done
        [[ -z "${options[*]}" ]] && break
        local cmd=(dialog --backtitle "$__backtitle" --menu "Configure emulators to use dispmanx SDL" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            local params=(${command[$choice]})
            if [[ "${params[1]}" == "on" ]]; then
                setDispmanx "${params[0]}" 1
            else
                setDispmanx "${params[0]}" "0"
            fi
            rp_callModule "${params[0]}" configure_dispmanx_${params[1]}
        else
            break
        fi
    done
}
