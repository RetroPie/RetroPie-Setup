rp_module_id="bashwelcometweak"
rp_module_desc="Bash Welcome Tweak"
rp_module_menus="2+"

function install_bashwelcometweak() {
    printMsg "Installing Bash Welcome Tweak"

    if [[ -z `cat "/home/$user/.bashrc" | grep "# RETROPIE PROFILE START"` ]]; then
        cat $scriptdir/supplementary/ProfileTweak >> "/home/$user/.bashrc"
    fi
}