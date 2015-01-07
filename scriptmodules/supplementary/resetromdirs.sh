rp_module_id="resetromdirs"
rp_module_desc="Reset ownership/permissions of the $romdir structure"
rp_module_menus="3+"
rp_module_flags="nobindist"

configure_resetromdirs() {
    printMsg "Resetting main $romdir ownershop/permissions"
    mkRootRomDir "$romdir"
    chown root:$user "$romdir"/*
    chmod g+w "$romdir"/*

    printMsg "Resetting ownershop on existing files to user: $user"
    chown -f -R $user:$user "$romdir"/*/*
}