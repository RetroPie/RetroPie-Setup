#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="crosscomp"
rp_module_desc="Create am arm cross compiler env - based on examples from http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler"
rp_module_help="Can be used via distcc to build RetroPie binaries"
rp_module_section=""
rp_module_flags="!arm"

function _default_dist_crosscomp() {
    echo "buster"
}

function depends_crosscomp() {
    getDepends distcc
}

function sources_crosscomp() {
    local dist="$1"
    [[ -z "$dist" ]] && return

    declare -A pkgs
    case "$dist" in
        stretch)
            pkgs=(
                [binutils]=2.28
                [gcc]=6.4.0
                [glibc]=2.24
                [gmp]=6.1.2
                [kernel]=4.9.80
                [mpfr]=3.1.5
                [mpc]=1.0.3
            )
            ;;
        buster)
            pkgs=(
                [binutils]=2.31.1
                [gcc]=8.3.0
                [glibc]=2.28
                [gmp]=6.1.2
                [kernel]=4.19.50
                [mpfr]=4.0.2
                [mpc]=1.1.0
            )
            ;;
        bullseye)
            pkgs=(
                [binutils]=2.35.2
                [gcc]=10.2.0
                [glibc]=2.31
                [gmp]=6.2.1
                [kernel]=5.15.61
                [mpfr]=4.1.0
                [mpc]=1.2.0
            )
            ;;
        *)
            md_ret_errors+=("Unsupported distribution $dist")
            return 1
            ;;
    esac

    downloadAndExtract "https://ftp.gnu.org/gnu/binutils/binutils-${pkgs[binutils]}.tar.gz" binutils --strip-components 1

    downloadAndExtract "https://ftp.gnu.org/gnu/mpfr/mpfr-${pkgs[mpfr]}.tar.gz" mpfr --strip-components 1
    downloadAndExtract "https://ftp.gnu.org/gnu/gmp/gmp-${pkgs[gmp]}.tar.bz2" gmp --strip-components 1
    downloadAndExtract "https://ftp.gnu.org/gnu/mpc/mpc-${pkgs[mpc]}.tar.gz" mpc --strip-components 1

    downloadAndExtract "https://ftp.gnu.org/gnu/glibc/glibc-${pkgs[glibc]}.tar.bz2" glibc --strip-components 1
    downloadAndExtract "https://ftp.gnu.org/gnu/gcc/gcc-${pkgs[gcc]}/gcc-${pkgs[gcc]}.tar.gz" gcc --strip-components 1

    downloadAndExtract "https://www.kernel.org/pub/linux/kernel/v${pkgs[kernel]:0:1}.x/linux-${pkgs[kernel]}.tar.gz" linux --strip-components 1

    local pkg
    for pkg in gmp mpc mpfr; do
        ln -sf "../$pkg" "gcc/$pkg"
    done

    # apply glibc patch required when compiling with GCC 10+
    # see https://sourceware.org/git/gitweb.cgi?p=glibc.git;h=49348beafe9ba150c9bd48595b3f372299bddbb0
    # as well as a fix for an incorrect header include.
    if [[ "$dist" == "bullseye" ]]; then
        applyPatch "$md_data/bullseye.diff"
    fi
}

function build_crosscomp() {
    local dist="$1"
    [[ -z "$dist" ]] && return

    # remove old build directories
    rm -rf "$md_build/build-"*

    local params=(--with-arch=armv6 --with-fpu=vfp --with-float=hard)
    local target=arm-linux-gnueabihf
    local dest="$md_inst/$dist"

    local old_path="$PATH"
    export PATH="$dest/bin:$old_path"

    export ASFLAGS=""
    export CFLAGS="-O2"
    export CXXFLAGS="-O2"

    # binutils
    printHeading "Building binutils"
    mkdir -p build-binutils
    cd build-binutils
    ../binutils/configure --prefix="$dest" --target="$target" "${params[@]}"
    make
    make install
    cd ..

    # kernel headers
    printHeading "Installing kernel headers"
    cd linux
    make ARCH=arm INSTALL_HDR_PATH="$dest/$target" headers_install
    cd ..

    # gcc
    printHeading "Building gcc"
    mkdir -p build-gcc
    cd build-gcc
    ../gcc/configure --prefix="$dest" --target="$target" --enable-languages=c,c++ --disable-multilib --disable-werror "${params[@]}" 
    make all-gcc
    make install-gcc
    cd ..

    # glibc
    printHeading "Building glibc"
    mkdir -p build-glibc
    cd build-glibc
    ../glibc/configure --prefix="$dest/$target" --build="$MACHTYPE" --host="$target" --target="$target" --with-headers="$dest/$target/include" libc_cv_forced_unwind=yes
    make install-bootstrap-headers=yes install-headers
    make csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o "$dest/$target/lib"

    "$target-gcc" -nostdlib -nostartfiles -shared -x c /dev/null -o "$dest/$target/lib/libc.so"
    touch "$dest/$target/include/gnu/stubs.h"
    cd ..

    # compiler support library
    printHeading "Building libgcc"
    cd build-gcc
    make all-target-libgcc
    make install-target-libgcc
    cd ..

    # standard c library
    printHeading "Building glibc (2)"
    cd build-glibc
    make
    make install
    cd ..

    # standard c++ library
    printHeading "Building libcpp"
    cd build-gcc
    make all
    make install
    cd ..

    export PATH="$old_path"
    export ASFLAGS="$__asflags"
    export CFLAGS="$__cflags"
    export CXXFLAGS="$__cxxflags"
}

function setup_crosscomp() {
    local dist="$1"
    [[ -z "$dist" ]] && dist="$(_default_dist_crosscomp)"
    
    if rp_callModule crosscomp sources "$dist"; then
        rp_callModule crosscomp build "$dist"
        rp_callModule crosscomp clean
        rp_callModule crosscomp switch_distcc "$dist"
    fi
}

function setup_all_crosscomp() {
    local dist
    for dist in stretch buster bullseye; do
        setup_crosscomp "$dist"
    done
}

function switch_distcc_crosscomp() {
    local dist="$1"
    [[ -z "$dist" ]] && return 1

    bins="$md_inst/bin"
    mkdir -p "$bins"

    # symlink the gcc/g++ binaries that match the distro we are cross compiling for
    local name
    for name in cc gcc arm-linux-gnueabihf-gcc; do
        ln -sfv "$md_inst/$dist/bin/arm-linux-gnueabihf-gcc" "$bins/$name"
    done

    for name in c++ g++ arm-linux-gnueabihf-g++; do
        ln -sfv "$md_inst/$dist/bin/arm-linux-gnueabihf-g++" "$bins/$name"
    done

    # make sure the path added to the distcc init.d script
    sed -i "s#^PATH=.*#PATH=$bins:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin#" /etc/init.d/distcc

    # restart distcc
    systemctl daemon-reload
    service distcc restart
}
