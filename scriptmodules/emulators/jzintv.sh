#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="jzintv"
rp_module_desc="Intellivision emulator"
rp_module_help="ROM Extensions: .int .bin .rom\n\nCopy your Intellivision roms to $romdir/intellivision\n\nCopy the required BIOS files exec.bin and grom.bin to $biosdir"
rp_module_licence="GPL2 http://spatula-city.org/%7Eim14u2c/intv/"
rp_module_repo="file $__archive_url/jzintv-20200712-src.zip"
rp_module_section="opt"
rp_module_flags="sdl2 nodistcc"

function depends_jzintv() {
    getDepends libsdl2-dev libreadline-dev
}

function sources_jzintv() {
    rm -rf "$md_build/jzintv"
    downloadAndExtract "$md_repo_url" "$md_build"
    # jzintv-YYYYMMDD/ --> jzintv/
    mv jzintv-[0-9]* jzintv
    cd jzintv/src

    if isPlatform "rpi" ; then
        applyPatch "$md_data/01_rpi_hide_cursor_sdl2.patch"
        applyPatch "$md_data/01_rpi_pillar_boxing_black_background_sdl2.patch"
    fi

    # Add source release date information to build
    mv buildcfg/90-svn.mak buildcfg/90-svn.mak.txt
    echo "SVN_REV := $(echo $md_repo_url | grep -o -P '[\d]{8}')" > buildcfg/90-src_releasedate.mak
    sed -i.zip-dist "s/SVN Revision/Releasedate/" svn_revision.c

    # aarch64 doesn't include sys/io.h - but it's not needed so we can remove
    grep -rl "include.*sys/io.h" | xargs sed -i "/include.*sys\/io.h/d"

    # remove shipped binaries / libraries
    rm -rf ../bin
}

function build_jzintv() {
    mkdir -p jzintv/bin
    cd jzintv/src

    local extra
    if isPlatform "rpi" ; then
        extra='EXTRA=-DPLAT_LINUX_RPI'
    fi

    make clean
    make $extra

    md_ret_require="$md_build/jzintv/bin/jzintv"
}

function install_jzintv() {
    md_ret_files=(
        'jzintv/bin'
        'jzintv/doc'
        'jzintv/src/COPYING.txt'
        'jzintv/src/COPYRIGHT.txt'
        $(find jzintv/Release*)
    )
}

function configure_jzintv() {
    mkRomDir "intellivision"

    local start_script="$md_inst/jzintv_launcher.sh"
    cat > "$start_script" << _EOF_
#! /usr/bin/env bash

# \$1: width of display
# \$2: height of display
# \$3: --ecs=1, optional
# \$4,5,6...: more optional parameters
# last parameter: %ROM%

jzintv_bin="$md_inst/bin/jzintv"

# regular case: w>=h (rotation 90/270 not supported by jzintv)
disp_w=\$1; shift
disp_h=\$1; shift

ratio="4/3"
read intv_w intv_h < <(python3 <<PYSCRIPT
if (\$disp_w / \$disp_h >= \$ratio):
    # left/right padding
    intv_w=round(\$disp_h * \$ratio)
    intv_h=\$disp_h
else:
    # top/bottom padding (letterboxing; e.g., on 5:4 displays)
    intv_w=\$disp_w
    intv_h=round(\$disp_w / (\$ratio))

print(intv_w,intv_h)
PYSCRIPT
)
# set --gfx-verbose instead of --quiet for verbose output
options=(
    -f1 # fullscreen
    --quiet
#    --gfx-verbose
    --displaysize="\${intv_w}x\${intv_h}"
    --rom-path="$biosdir"
    --voice=1
)

echo "Launching: \$jzintv_bin \${options[@]} \$@"
\$jzintv_bin \${options[@]} "\$@"
_EOF_
    chown $user:$user "$start_script"
    chmod u+x "$start_script"

    addEmulator 1 "$md_id"     "intellivision" "'$start_script' %XRES% %YRES% %ROM%"
    addEmulator 0 "$md_id-ecs" "intellivision" "'$start_script' %XRES% %YRES% --ecs=1 %ROM%"
    addSystem "intellivision"
}
