#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="moonlight-embedded"
rp_module_desc="Moonlight Embedded Game Streaming"
rp_module_section="exp"

function depends_moonlight-embedded() {
    getDepends libraspberrypi0 libraspberrypi-dev libopus0 libopus-dev libexpat1 libexpat1-dev libasound2 libasound2-dev libudev0 libudev-dev libavahi-client3 libavahi-client-dev libcurl3 libcurl4-openssl-dev libevdev2 libevdev-dev libenet7 libenet-dev libssl-dev libpulse-dev uuid-dev
}

function sources_moonlight-embedded() {
    gitPullOrClone "$md_build/moonlight" "https://github.com/irtimmer/moonlight-embedded.git"
	cd $md_build/moonlight
	git submodule update --init

    mkdir $md_build/cmake
    wget -q -O- "https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz" | tar -xvz --strip-components=1 -C $md_build/cmake
}

function build_moonlight-embedded() {
    # Compile CMake 3.1+ until is not available on Raspbian repositories
    pushd $md_build/cmake
    ./bootstrap
    make
    popd

    pushd $md_build/moonlight
    mkdir build
    cd build/

    $md_build/cmake/bin/cmake ../
    make
    popd
}

function install_moonlight-embedded() {
    md_ret_files=(
        'moonlight/build/moonlight'
        'moonlight/build/libmoonlight-pi.so'
        'moonlight/build/libgamestream/libgamestream.so'
        'moonlight/build/libgamestream/libgamestream.so.0'
        'moonlight/build/libgamestream/libgamestream.so.2.2.2'
        'moonlight/build/libgamestream/libmoonlight-common.so'
        'moonlight/build/libgamestream/libmoonlight-common.so.0'
        'moonlight/build/libgamestream/libmoonlight-common.so.2.2.2'
        'moonlight/build/docs'
    )
}

function configure_moonlight-embedded() {
    [[ "$md_mode" == "remove" ]] && return

    # Create moonlight embedded config script
    addPort "moonlight-list" "moonlight" "Moonlight Embedded" << _EOF_
#!/usr/bin/env bash
pushd $md_inst

while read line; do
    regex='^([0-9]*)\. (.*)$'
    if [[ "\$line" =~ \$regex ]];    then
        options+=("\${BASH_REMATCH[1]}" "\${BASH_REMATCH[2]}")

        games["\${BASH_REMATCH[1]}"]="\${BASH_REMATCH[2]}"
    fi
done < <($md_inst/moonlight list)
options+=("q" "Quit the application or game being streamed")

cmd=(dialog --keep-tite --menu "Select a game:" 22 76 16)

choice=\$("\${cmd[@]}" "\${options[@]}" 2>&1 >/dev/tty)
if [ "\$choice" == "q" ];then
    $md_inst/moonlight quit
else
    game="\${games[\$choice]}"
    $md_inst/moonlight stream -config $md_inst/moonlight.cfg -app "\$game"
fi

popd
_EOF_
}

function gui_moonlight-embedded() {
    pushd "$md_inst"

    # default config
    width=1280
    height=720
    fps=60
    bitrate=
    packetsize=
    sops=true
    localaudio=false

    # Load config
	while read line; do
	regex='^(.*) = (.*)$'
	if [[ "$line" =~ $regex ]]; then
		case "${BASH_REMATCH[1]}" in
			width)
				width="${BASH_REMATCH[2]}"
				;;
			height)
				height="${BASH_REMATCH[2]}"
				;;
			fps)
				fps="${BASH_REMATCH[2]}"
				;;
			bitrate)
				bitrate="${BASH_REMATCH[2]}"
				;;
			packetsize)
				packetsize="${BASH_REMATCH[2]}"
				;;
			sops)
				sops="${BASH_REMATCH[2]}"
				;;
			localaudio)
				localaudio="${BASH_REMATCH[2]}"
				;;
		esac
	fi
	done < moonlight.cfg

    while true; do
        options=(
            "pair" "Pair with server"
            "res" "Set resolution"
            "fps" "Set fps"
            "bitrate" "Specify the bitrate in Kbps"
            "packetsize" "Specify the maximum packetsize in bytes"
            "nosops" "Don't allow GFE to modify game settings"
            "localaudio" "Play audio locally"
        )
        local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --menu "Select an option:" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        if [[ -z "$choice" ]];then
            cat > $md_inst/moonlight.cfg << EOF
width = $width
height = $height
fps = $fps
bitrate = $bitrate
packetsize = $packetsize
sops = $sops
localaudio = $localaudio
EOF
            break
        fi

        case $choice in
            pair)
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --inputbox "Input ip-address of GeForce PC (left blank to auto-discover):" 8 40)
                local ip=$("${cmd[@]}" 2>&1 >/dev/tty)

                $md_inst/moonlight pair $ip 2>&1 >/dev/tty
                ;;
            res)
                resolutions=(
                    "720" "Use 1280x720 resolution [default]"
                    "1080" "Use 1920x1080 resolution"
                )
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --menu "Select the resolution:" 22 76 16)
                local resolution=$("${cmd[@]}" "${resolutions[@]}" 2>&1 >/dev/tty)
                case $resolution in
                    720)
                        width=1280
                        height=720
                        ;;
                    1080)
                        width=1920
                        height=1080
                        ;;
                esac
                ;;
            fps)
                fps_options=(
                    "30" "Use 30 fps"
                    "60" "Use 60 fps [default]"
                )
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --menu "Select the fps:" 22 76 16)
                fps=$("${cmd[@]}" "${fps_options[@]}" 2>&1 >/dev/tty)
                ;;
            bitrate)
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --inputbox "Input the bitrate in Kbps:" 8 40)
                bitrate=$("${cmd[@]}" "${bitrate}" 2>&1 >/dev/tty)
                ;;
            packetsize)
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --inputbox "Input the packet size in bytes:" 8 40)
                bitrate=$("${cmd[@]}" "${packetsize}" 2>&1 >/dev/tty)
                ;;
            nosops)
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --yesno "Allow GFE to modify game settings?:" 8 40)
                local nosops_option=$("${cmd[@]}" 2>&1 >/dev/tty)
                case $nosops_option in
                   0) nosops=true;;
                   1) nosops=false;;
                esac

                ;;
            localaudio)
                local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --yesno "Play audio locally?:" 8 40)
                local localaudio_option=$("${cmd[@]}" 2>&1 >/dev/tty)
                case $localaudio_option in
                   0) localaudio=true;;
                   1) localaudio=false;;
                esac
                ;;
        esac
    done

    popd
}
