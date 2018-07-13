#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="builder"
rp_module_desc="Create binary archives for distribution"
rp_module_section=""

function depends_builder() {
    getDepends rsync
}

function module_builder() {
    local ids=($@)

    local id
    for id in "${ids[@]}"; do
        # if index get mod_id from array else we look it up
        local md_id
        local md_idx
        if [[ "$id" =~ ^[0-9]+$ ]]; then
            md_id="$(rp_getIdFromIdx $id)"
            md_idx="$id"
        else
            md_idx="$(rp_getIdxFromId $id)"
            md_id="$id"
        fi
        ! fnExists "install_${md_id}" && continue

        # skip already built archives, so we can retry failed modules
        [[ -f "$__tmpdir/archives/$__os_codename/$__platform/${__mod_type[md_idx]}/$md_id.tar.gz" ]] && continue

        # build, install and create binary archive.
        # initial clean in case anything was in the build folder when calling
        local mode
        for mode in clean remove depends sources build install create_bin clean remove "depends remove"; do
            rp_callModule "$md_id" $mode
            # return on error
            [[ $? -eq 1 ]] && return 1
            # no module found - skip to next module
            [[ $? -eq 2 ]] && break
        done
    done
    return 0
}

function section_builder() {
    module_builder $(rp_getSectionIds $1) || return 1
}

function upload_builder() {
    rsync -av --progress --delay-updates "$__tmpdir/archives/" "retropie@$__binary_host:files/binaries/"
}

function clean_archives_builder() {
    rm -rfv "$__tmpdir/archives"
}

function chroot_build_builder() {
    rp_callModule image depends
    mkdir -p "$md_build"

    # get current host ip for the distcc in the emulated chroot to connect to
    local ip="$(ip route get 8.8.8.8 2>/dev/null | awk '{print $NF; exit}')"

    local use_distcc=0
    [[ -d "$rootdir/admin/crosscomp/$dist" ]] && use_distcc=1

    local dist
    local sys

    for dist in jessie stretch; do
        [[ "$use_distcc" -eq 1 ]] && rp_callModule crosscomp switch_distcc "$dist"
        if [[ ! -d "$md_build/$dist" ]]; then
            rp_callModule image create_chroot "$dist" "$md_build/$dist"
            git clone "$HOME/RetroPie-Setup" "$md_build/$dist/home/pi/RetroPie-Setup"
            cat > "$md_build/$dist/home/pi/install.sh" <<_EOF_
#!/bin/bash
cd
sudo apt-get update
sudo apt-get install -y git
if [[ "$use_distcc" -eq 1 ]]; then
    sudo apt-get install -y distcc
    sudo sed -i s/\+zeroconf/$ip/ /etc/distcc/hosts;
fi
_EOF_
            rp_callModule image chroot "$md_build/$dist" bash /home/pi/install.sh
        else
            git -C "$md_build/$dist/home/pi/RetroPie-Setup" pull
        fi

        for sys in rpi1 rpi2; do
            rp_callModule image chroot "$md_build/$dist" \
                sudo \
                PATH="/usr/lib/distcc:$PATH" \
                MAKEFLAGS="-j4 PATH=/usr/lib/distcc:$PATH" \
                __platform="$sys" \
                /home/pi/RetroPie-Setup/retropie_packages.sh builder "$@"
        done

        rsync -av "$md_build/$dist/home/pi/RetroPie-Setup/tmp/archives/" "$HOME/RetroPie-Setup/tmp/archives/"
    done
}
