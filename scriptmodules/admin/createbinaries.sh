rp_module_id="createbinaries"
rp_module_desc="Create binary archives for distribution"
rp_module_menus=""
rp_module_flags="nobindist"

function install_createbinaries() {
    for idx in "${__mod_idx[@]}"; do
        if [[ ! "${__mod_menus[$idx]}" =~ 4 ]] && [[ ! "${__mod_flags[$idx]}" =~ nobindist ]]; then
            rp_callModule $idx create_bin
        fi
    done
}
