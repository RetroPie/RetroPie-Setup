rp_module_id="resetromdirs"
rp_module_desc="Reset ownership/permissions of $romdir"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_resetromdirs() {
    printHeading "Resetting $romdir ownershop/permissions"
    mkUserDir "$romdir"
    mkUserDir "$biosdir"
    chown -R $user:$user "$romdir"
    chown -R $user:$user "$biosdir"
}
