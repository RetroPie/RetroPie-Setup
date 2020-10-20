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

        # don't build binaries for modules with flag nobin
        # eg scraper which fails as go1.8 doesn't work under qemu
        hasFlag "${__mod_flags[$md_idx]}" "nobin" && continue

        ! fnExists "install_${md_id}" && continue

        # skip already built archives, so we can retry failed modules
        [[ -f "$__tmpdir/archives/$__binary_path/${__mod_type[md_idx]}/$md_id.tar.gz" ]] && continue

        # build, install and create binary archive.
        # initial clean in case anything was in the build folder when calling
        local mode
        for mode in clean remove depends sources build install create_bin clean remove "depends remove"; do
            rp_callModule "$md_id" $mode
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
    adminRsync "$__tmpdir/archives/" "files/binaries/"
}

function clean_archives_builder() {
    rm -rfv "$__tmpdir/archives"
}

function chroot_build_builder() {
    rp_callModule image depends
    mkdir -p "$md_build"

    # get current host ip for the distcc in the emulated chroot to connect to
    local ip="$(getIPAddress)"

    local dist
    local dists="$__builder_dists"
    [[ -z "$dists" ]] && dists="stretch buster"

    local platform
    local platforms="$__builder_platforms"
    [[ -z "$platforms" ]] && platforms="rpi1 rpi2 rpi4"

    for dist in $dists; do
        local distcc_hosts="$__builder_distcc_hosts"
        if [[ -d "$rootdir/admin/crosscomp/$dist" ]]; then
            rp_callModule crosscomp switch_distcc "$dist"
            [[ -z "$distcc_hosts" ]] && distcc_hosts="$ip"
        fi

        local makeflags="$__builder_makeflags"
        [[ -z "$makeflags" ]] && makeflags="-j$(nproc)"

        [[ ! -d "$md_build/$dist" ]] && rp_callModule image create_chroot "$dist" "$md_build/$dist"
        if [[ ! -d "$md_build/$dist/home/pi/RetroPie-Setup" ]]; then
            sudo -u $user git clone "$home/RetroPie-Setup" "$md_build/$dist/home/pi/RetroPie-Setup"
            gpg --export-secret-keys "$__gpg_signing_key" >"$md_build/$dist/retropie.key"
            rp_callModule image chroot "$md_build/$dist" bash -c "\
                sudo gpg --import "/retropie.key"; \
                sudo rm "/retropie.key"; \
                sudo apt-get update; \
                sudo apt-get install -y git; \
                "
        else
            sudo -u $user git -C "$md_build/$dist/home/pi/RetroPie-Setup" pull
        fi

        for platform in $platforms; do
            if [[ "$dist" == "stretch" && "$platform" == "rpi4" ]]; then
                printMsgs "heading" "Skipping platform $platform on $dist ..."
                continue
            fi

            rp_callModule image chroot "$md_build/$dist" \
                sudo \
                __makeflags="$makeflags" \
                DISTCC_HOSTS="$distcc_hosts" \
                __platform="$platform" \
                __has_binaries="$__chroot_has_binaries" \
                /home/pi/RetroPie-Setup/retropie_packages.sh builder "$@"
        done

        rsync -av "$md_build/$dist/home/pi/RetroPie-Setup/tmp/archives/" "$home/RetroPie-Setup/tmp/archives/"
    done
}
