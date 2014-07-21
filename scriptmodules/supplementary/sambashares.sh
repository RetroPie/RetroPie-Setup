rp_module_id="sambashares"
rp_module_desc="Samba ROM Shares"
rp_module_menus="3+"

function set_ensureEntryInSMBConf()
{
    comp=`cat /etc/samba/smb.conf | grep "\[$1\]"`
    if [ "$comp" == "[$1]" ]; then
      echo "$1 already contained in /etc/samba/smb.conf."
    else
    tee -a /etc/samba/smb.conf <<_EOF_
[$1]
comment = $1
path = $2
writeable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = $user
_EOF_
    fi
}

function install_sambashares() {
    rps_checkNeededPackages samba samba-common-bin
}

function configure_sambashares() {
    # remove old configs
    sed -i '/\[[A-Z]\]*/,$d' /etc/samba/smb.conf

    set_ensureEntryInSMBConf "roms" "$romdir"
    set_ensureEntryInSMBConf "bios" "$home/RetroPie/BIOS"

    # enforce rom directory permissions - root:$user for roms folder with the sticky bit set,
    # and root:$user for first level subfolders with group writable. This allows them to be
    # writable by the pi user, yet avoid being deleted by accident
    chown root:$user "$romdir" "$romdir"/*
    chmod g+w "$romdir"/*
    chmod +t "$romdir"

    printMsg "Resetting ownershop on existing files to user: $user"
    chown -R $user:$user "$romdir"/*/*

    /etc/init.d/samba restart
}