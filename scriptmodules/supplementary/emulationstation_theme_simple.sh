rp_module_id="esthemesimple"
rp_module_desc="EmulationStation Theme Simple"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_esthemesimple() {
    # download themes archive
    wget -O themesDownload.zip http://blog.petrockblock.com/download/retropie-setup-script-themes-package-simple/

    mkdir -p "/etc/emulationstation/themes"

    # remove old simple theme files
    rmDirExists "/etc/emulationstation/themes/simple"

    # unzip archive to tmp folder
    unzip themesDownload.zip -d /etc/emulationstation/themes/

    # delete zi parchive
    rm themesDownload.zip
}
