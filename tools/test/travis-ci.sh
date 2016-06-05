#!/bin/bash
# Based on a test script from avsm/ocaml repo https://github.com/avsm/ocaml
# based on the script from https://www.tomaz.me/2013/12/02/running-travis-ci-tests-on-arm.html

CHROOT_DIR=$HOME/arm-chroot
MIRROR=http://archive.raspbian.org/raspbian

VERSION=jessie
CHROOT_ARCH=armhf

# Debian package dependencies for the host
HOST_DEPENDENCIES="debootstrap qemu-user-static binfmt-support sbuild"

# Debian package dependencies for the chrooted environment
GUEST_DEPENDENCIES="build-essential git m4 sudo cmake g++-4.9 gcc-4.9 python locales"

function setup_arm_chroot {
    # Host dependencies
    sudo apt-get install -qq -y ${HOST_DEPENDENCIES}

    # Create chrooted environment
    sudo mkdir -p ${CHROOT_DIR}
    pushd /usr/share/debootstrap/scripts; sudo ln -s sid jessie; popd

    export QEMU_CPU=cortex-a15

    sudo debootstrap --foreign --no-check-gpg --include=fakeroot,build-essential \
        --arch=${CHROOT_ARCH} ${VERSION} ${CHROOT_DIR} ${MIRROR}
    sudo cp /usr/bin/qemu-arm-static ${CHROOT_DIR}/usr/bin/
    sudo chroot ${CHROOT_DIR} ./debootstrap/debootstrap --second-stage
    sudo sbuild-createchroot --arch=${CHROOT_ARCH} --foreign --setup-only \
        ${VERSION} ${CHROOT_DIR} ${MIRROR}

    sudo cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"

    sudo cat << EOF > "${CHROOT_DIR}/etc/default/keyboard"
# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.
XKBMODEL="pc105"
XKBLAYOUT="gb"
XKBVARIANT=""
XKBOPTIONS="lv3:ralt_switch"

BACKSPACE="guess"
EOF

    sudo mount -o bind /proc "${CHROOT_DIR}/proc"
    sudo mount -o bind /dev "${CHROOT_DIR}/dev"
    sudo mount -o bind /dev/pts "${CHROOT_DIR}/dev/pts"
    sudo mount -o bind /sys "${CHROOT_DIR}/sys"
    sudo mount -o bind /run "${CHROOT_DIR}/run"

    # Create file with environment variables which will be used inside chrooted
    # environment
    echo "export ARCH=${ARCH}" > envvars.sh
    echo "export TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR}" >> envvars.sh
    echo "export __platform=${__platform}" >> envvars.sh

    sudo echo -e "echo \"en_US.UTF-8 UTF-8\" > /etc/locale.gen" >> envvars.sh
    sudo echo "/usr/sbin/locale-gen" >> envvars.sh

    chmod a+x envvars.sh

    # Install dependencies inside chroot
    sudo chroot ${CHROOT_DIR} apt-get update
    sudo chroot ${CHROOT_DIR} apt-get --allow-unauthenticated install \
        -qq -y ${GUEST_DEPENDENCIES}

    # Create build dir and copy travis build files to our chroot environment
    sudo mkdir -p ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}
    sudo rsync -av ${TRAVIS_BUILD_DIR}/ ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}/

    # Indicate chroot environment has been set up
    sudo touch ${CHROOT_DIR}/.chroot_is_done

    # Call ourselves again which will cause tests to run
    sudo chroot ${CHROOT_DIR} bash -c "cd ${TRAVIS_BUILD_DIR} && ./tools/test/travis-ci.sh"
}

if [ -e "/.chroot_is_done" ]; then
  # We are inside ARM chroot
  echo "Running inside chrooted environment"

  . ./envvars.sh

  echo "Running tests"
  echo "Environment: $(uname -a)"

  # Commands used to run the tests

  # emulators
  for (( index=100; i <= 150; index++ ))
  do
    sudo __platform=${__platform} ./retropie_packages.sh $index depends || return 1
    sudo __platform=${__platform} ./retropie_packages.sh $index install_bin || return 1
    sudo __platform=${__platform} ./retropie_packages.sh $index configure || return 1
  done

  # RetroArch cores
  for (( index=200; i <= 250; index++ ))
  do
    sudo __platform=${__platform} ./retropie_packages.sh ${index} depends || return 1
    sudo __platform=${__platform} ./retropie_packages.sh $index install_bin || return 1
    sudo __platform=${__platform} ./retropie_packages.sh $index configure || return 1
  done

  # ports
  for (( index=300; i <= 350; index++ ))
  do
    sudo __platform=${__platform} ./retropie_packages.sh $index depends || return 1
    sudo __platform=${__platform} ./retropie_packages.sh $index install_bin || return 1
    sudo __platform=${__platform} ./retropie_packages.sh $index configure || return 1
  done

else
  # ARM test run, need to set up chrooted environment first
  echo "Setting up chrooted ARM environment"
  setup_arm_chroot
fi
