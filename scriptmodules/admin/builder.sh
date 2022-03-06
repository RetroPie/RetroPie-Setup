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
        printMsgs "heading" "Building module $id"
        # don't build binaries for modules with flag nobin
        # eg scraper which fails as go1.8 doesn't work under qemu
        if hasFlag "${__mod_info[$id/flags]}" "nobin"; then
            printMsgs "console" "Module has 'nobin' flag set, so not building."
            continue
        fi

        # skip modules that are not enabled for the target system
        if [[ "${__mod_info[$id/enabled]}" -ne 1 ]]; then
            printMsgs "console" "Module is disabled for this platform ($__platform)."
            continue
        fi

        # if the module has no install_ function skip to the next module
        if ! fnExists "install_${id}"; then
            printMsgs "console" "Module has no install_${id} function so cannot be pre-built."
            continue
        fi

        # if there is no newer version, skip to the next module. Returns 1 when update is not required,
        # but can also return 2, to mean "unknown" in which case we should do an update. Modules like sdl2
        # will return 2 as they are handled differently, and don't use the package update mechanisms.
        rp_hasNewerModule "$id" "source"
        if [[ "$?" -eq 1 ]]; then
            printMsgs "console" "No update was found."
            continue
        fi

        # build, install and create binary archive.
        # initial clean in case anything was in the build folder when calling
        local mode
        for mode in clean depends sources build install create_bin clean remove "depends remove"; do
            # continue to next module if not available or an error occurs
            rp_callModule "$id" $mode || break
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
    [[ -z "$dists" ]] && dists="buster"

    local platform
    local platforms="$__builder_platforms"
    [[ -z "$platforms" ]] && platforms="rpi1 rpi2 rpi4"

    for dist in $dists; do
        local chroot_dir="$md_build/$dist"
        local chroot_rps_dir="$chroot_dir/home/pi/RetroPie-Setup"
        local archive_dir="tmp/archives/$dist"

        local distcc_hosts="$__builder_distcc_hosts"
        if [[ -d "$rootdir/admin/crosscomp/$dist" ]]; then
            rp_callModule crosscomp switch_distcc "$dist"
            [[ -z "$distcc_hosts" ]] && distcc_hosts="$ip"
        fi

        local use_ccache="$__builder_use_ccache"

        local makeflags="$__builder_makeflags"
        [[ -z "$makeflags" ]] && makeflags="-j$(nproc)"
        [[ ! -d "$chroot_dir" ]] && rp_callModule image create_chroot "$dist" "$chroot_dir"


        if [[ ! -d "$chroot_rps_dir" ]]; then
            sudo -u $user git clone "$scriptdir" "$chroot_rps_dir"
            gpg --export-secret-keys "$__gpg_signing_key" >"$chroot_dir/retropie.key"
            rp_callModule image chroot "$chroot_dir" bash -c "\
                sudo gpg --import "/retropie.key"; \
                sudo rm "/retropie.key"; \
                sudo apt-get update; \
                sudo apt-get install -y git; \
                "
            # copy existing packages from host if building in a clean chroot to avoid rebuilding everything
            mkdir -p "$chroot_rps_dir/$archive_dir"
            rsync -av "$scriptdir/$archive_dir/" "$chroot_rps_dir/$archive_dir/"
        else
            sudo -u $user git -C "$chroot_rps_dir" pull
        fi

        for platform in $platforms; do
            if [[ "$dist" == "stretch" && "$platform" == "rpi4" ]]; then
                printMsgs "heading" "Skipping platform $platform on $dist ..."
                continue
            fi

            rp_callModule image chroot "$chroot_dir" \
                sudo \
                __use_ccache="$use_ccache" \
                __makeflags="$makeflags" \
                DISTCC_HOSTS="$distcc_hosts" \
                __platform="$platform" \
                __has_binaries="$__chroot_has_binaries" \
                /home/pi/RetroPie-Setup/retropie_packages.sh builder "$@"
        done

        rsync -av "$chroot_rps_dir/$archive_dir/" "$scriptdir/$archive_dir/"
    done
}
