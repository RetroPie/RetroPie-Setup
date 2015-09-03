#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sambashares"
rp_module_desc="Samba ROM Shares"
rp_module_menus="3+"
rp_module_flags="nobin"

function set_ensureEntryInSMBConf()
{
    sed -i "/^\[$1\]/,/^force user/d" /etc/samba/smb.conf
    cat >>/etc/samba/smb.conf <<_EOF_
[$1]
comment = $1
path = $2
writeable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = $user
_EOF_
}

function install_sambashares() {
    getDepends samba samba-common-bin
}

function configure_sambashares() {
    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
    set_ensureEntryInSMBConf "roms" "$romdir"
    set_ensureEntryInSMBConf "bios" "$home/RetroPie/BIOS"
    set_ensureEntryInSMBConf "configs" "$configdir"
    set_ensureEntryInSMBConf "splashscreens" "$datadir/splashscreens"

    service samba restart
}
