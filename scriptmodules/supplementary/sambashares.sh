rp_module_id="sambashares"
rp_module_desc="Samba ROM Shares"
rp_module_menus="3+"
rp_module_flags="nobin"

function set_ensureEntryInSMBConf()
{
    comp=$(cat /etc/samba/smb.conf | grep "\[$1\]")
    if [[ "$comp" == "[$1]" ]]; then
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
    getDepends samba samba-common-bin
}

function configure_sambashares() {
    # remove old configs
    sed -i '/\[[A-Z]\]*/,$d' /etc/samba/smb.conf

    set_ensureEntryInSMBConf "roms" "$romdir"
    set_ensureEntryInSMBConf "bios" "$home/RetroPie/BIOS"

    rp_callModule resetromdirs configure

    /etc/init.d/samba restart
}
