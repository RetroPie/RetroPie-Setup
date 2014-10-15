rp_module_id="esthemesimple"
rp_module_desc="EmulationStation Theme Simple"
rp_module_menus="2+"

function install_esthemesimple() {
	# download themes archive
    wget -O /tmp/themesDownload.zip http://blog.petrockblock.com/?wpdmdl=7118

    # unzip archive to tmp folder
    unzip /tmp/themesDownload.zip -d /tmp/
    if [[ ! -d "/etc/emulationstation/themes" ]]; then
        mkdir -p "/etc/emulationstation/themes"
    fi

    # remove old simple theme files
    rmDirExists "/etc/emulationstation/themes/simple"

    # move new simple theme files to themes folder
    mv -f /tmp/simple/ "/etc/emulationstation/themes/"

    # delete zi parchive
    rm /tmp/themesDownload.zip
}