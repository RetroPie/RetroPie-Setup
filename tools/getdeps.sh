#!/bin/bash
echo fetching dependancies 
apt install -y build-essential mercurial make cmake autoconf automake libtool libasound2-dev libpulse-dev libaudio-dev libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxi-dev libxinerama-dev libxxf86vm-dev libxss-dev libgl1-mesa-dev libesd0-dev libdbus-1-dev libudev-dev  libgles2-mesa-dev libegl1-mesa-dev libibus-1.0-dev fcitx-libs-dev libsamplerate0-dev libwayland-dev libxkbcommon-dev wayland-protocols git mc pulseaudio pavucontrol mpg123 mpv libev-dev libboost-locale-dev libboost-system-dev libboost-filesystem-dev libboost-date-time-dev libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev libasound2-dev libsm-dev libvlc-dev libvlccore-dev vlc libusb-1.0-0-dev mpg123 mpv joystick fbi dos2unix samba
echo fetching r12p0 wayland gpu driver
  wget https://developer.arm.com/-/media/Files/downloads/mali-drivers/user-space/odroid-xu3/malit62xr12p004rel0linux1wayland.tar.gz
       tar -xzf malit62xr12p004rel0linux1wayland.tar.gz
	   mv wayland /usr/lib/arm-linux-gnueabihf/wayland-egl
	   chown -R root:root /usr/lib/arm-linux-gnueabihf/wayland-egl
       echo "/usr/lib/arm-linux-gnueabihf/wayland-egl" | sudo tee /usr/lib/arm-linux-gnueabihf/wayland-egl/ld.so.conf > /dev/null
	   chmod 644 /usr/lib/arm-linux-gnueabihf/wayland-egl/*.*
	   update-alternatives --install /etc/ld.so.conf.d/arm-linux-gnueabihf_EGL.conf arm-linux-gnueabihf_egl_conf /usr/lib/arm-linux-gnueabihf/wayland-egl/ld.so.conf 1
     update-alternatives --set arm-linux-gnueabihf_egl_conf  /usr/lib/arm-linux-gnueabihf/wayland-egl/ld.so.conf 