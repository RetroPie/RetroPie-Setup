#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="piegalaxy"
rp_module_desc="Pie Galaxy - Downloand and install GOG.com games in RetroPie"
rp_module_licence="GPL https://github.com/sigboe/pie-galaxy/blob/master/LICENSE"
rp_module_section="exp"

function depends_piegalaxy() {
	getDepends jq html2text unar
}

function install_bin_piegalaxy() {
	local innoversion="1.8-dev-2019-01-13"
	gitPullOrClone "$md_inst" https://github.com/sigboe/pie-galaxy.git master
	isPlatform "x86" && (cd "$md_inst" && curl -o wyvern -O https://demenses.net/wyvern-nightly)
	isPlatform "arm" && (cd "$md_inst" && curl -o wyvern -O https://demenses.net/wyvern-arm-nightly)
	isPlatform "x86" && downloadAndExtract "http://constexpr.org/innoextract/files/snapshots/innoextract-${innoversion}/innoextract-${innoversion}-linux.tar.xz" "$md_inst" --strip-components 3 innoextract-${innoversion}-linux/bin/amd64/innoextract
	isPlatform "arm" && downloadAndExtract "http://constexpr.org/innoextract/files/snapshots/innoextract-${innoversion}/innoextract-${innoversion}-linux.tar.xz" "$md_inst" --strip-components 3 innoextract-${innoversion}-linux/bin/armv6j-hardfloat/innoextract
	chmod +x "$md_inst"/wyvern "$md_inst"/innoextract "$md_inst"/pie-galaxy.sh
}

function configure_piegalaxy() {
	addPort "$md_id" "piegalaxy" "Pie Galaxy" "$md_inst/pie-galaxy.sh"
}
