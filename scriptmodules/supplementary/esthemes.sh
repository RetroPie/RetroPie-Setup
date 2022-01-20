#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="esthemes"
rp_module_desc="Install themes for Emulation Station"
rp_module_section="config"

function depends_esthemes() {
    if isPlatform "x11"; then
        getDepends feh
    else
        getDepends fbi
    fi
}

function _has_pixel_pos_esthemes() {
    local pixel_pos=0
    # get the version of emulationstation installed so we can check whether to show
    # themes that use the new pixel based positioning - we run as $user as the
    # emulationstation launch script will exit if run as root
    local es_ver="$(sudo -u $user /usr/bin/emulationstation --help | grep -oP "Version \K[^,]+")"
    # if emulationstation is newer than 2.10, enable pixel based themes
    compareVersions "$es_ver" ge "2.10" && pixel_pos=1
    echo "$pixel_pos"
}

function install_theme_esthemes() {
    local theme="$1"
    local repo="$2"
    local branch="$3"

    local pixel_pos="$(_has_pixel_pos_esthemes)"

    if [[ -z "$repo" ]]; then
        repo="RetroPie"
    fi

    if [[ -z "$theme" ]]; then
        theme="carbon"
        repo="RetroPie"
        [[ "$pixel_pos" -eq 1 ]] && theme+="-2021"
    fi

    local name="$theme"

    if [[ -z "$branch" ]]; then
        # Get the name of the default branch, fallback to 'master' if not found
        branch=$(runCmd git ls-remote --symref --exit-code "https://github.com/$repo/es-theme-$theme.git" HEAD | grep -oP ".*/\K[^\t]+")
        [[ -z "$branch" ]] && branch="master"
    else
        name+="-$branch"
    fi

    mkdir -p "/etc/emulationstation/themes"
    gitPullOrClone "/etc/emulationstation/themes/$name" "https://github.com/$repo/es-theme-$theme.git" "$branch"
}

function uninstall_theme_esthemes() {
    local theme="$1"
    if [[ -d "/etc/emulationstation/themes/$theme" ]]; then
        rm -rf "/etc/emulationstation/themes/$theme"
    fi
}

function gui_esthemes() {
    local themes=()

    local pixel_pos="$(_has_pixel_pos_esthemes)"

    if [[ "$pixel_pos" -eq 1 ]]; then
        themes+=(
            'RetroPie carbon-2021'
            'RetroPie carbon-2021 centered'
            'RetroPie carbon-2021 nometa'
        )
    fi

    local themes+=(
        'RetroPie carbon'
        'RetroPie carbon-centered'
        'RetroPie carbon-nometa'
        'RetroPie simple'
        'RetroPie simple-dark'
        'RetroPie clean-look'
        'RetroPie color-pi'
        'RetroPie nbba'
        'RetroPie simplified-static-canela'
        'RetroPie turtle-pi'
        'RetroPie zoid'
        'ehettervik pixel'
        'ehettervik pixel-metadata'
        'ehettervik pixel-tft'
        'ehettervik luminous'
        'ehettervik minilumi'
        'ehettervik workbench'
        'AmadhiX eudora'
        'AmadhiX eudora-bigshot'
        'AmadhiX eudora-concise'
        'Omnija simpler-turtlepi'
        'Omnija simpler-turtlemini'
        'Omnija metro'
        'lilbud material'
        'mattrixk io'
        'mattrixk metapixel'
        'mattrixk spare'
        'robertybob space'
        'robertybob simplebigart'
        'robertybob tv'
        'HerbFargus tronkyfran'
        'lilbud flat'
        'lilbud flat-dark'
        'lilbud minimal'
        'lilbud switch'
        'lilbud angular'
        'FlyingTomahawk futura-V'
        'FlyingTomahawk futura-dark-V'
        'G-rila fundamental'
        'ruckage nes-mini'
        'ruckage famicom-mini'
        'ruckage snes-mini'
        'anthonycaccese crt'
        'anthonycaccese crt-centered'
        'anthonycaccese art-book'
        'anthonycaccese art-book-4-3'
        'anthonycaccese art-book-pocket'
        'anthonycaccese art-book-micro'
        'anthonycaccese tft'
        'anthonycaccese picade'
        'TMNTturtleguy ComicBook'
        'TMNTturtleguy ComicBook_4-3'
        'TMNTturtleguy ComicBook_SE-Wheelart'
        'TMNTturtleguy ComicBook_4-3_SE-Wheelart'
        'ChoccyHobNob cygnus'
        'DTEAM-1 cygnus-blue-flames'
        'dmmarti steampunk'
        'dmmarti hurstyblue'
        'dmmarti maximuspie'
        'dmmarti showcase'
        'dmmarti kidz'
        'dmmarti unified'
        'dmmarti gamehat'
        'rxbrad freeplay'
        'rxbrad gbz35'
        'rxbrad gbz35-dark'
        'garaine marioblue'
        'garaine bigwood'
        'MrTomixf Royal_Primicia'
        'lostless playstation'
        'mrharias superdisplay'
        'coinjunkie synthwave'
        'nickearl retrowave'
        'nickearl retrowave_4_3'
        'pacdude minijawn'
        'RetroHursty69 magazinemadness'
        'RetroHursty69 stirling'
        'RetroHursty69 boxalloyred'
        'RetroHursty69 boxalloyblue'
        'RetroHursty69 greenilicious'
        'RetroHursty69 retroroid'
        'RetroHursty69 merryxmas'
        'RetroHursty69 cardcrazy'
        'RetroHursty69 license2game'
        'RetroHursty69 comiccrazy'
        'RetroHursty69 snazzy'
        'RetroHursty69 tributeGoT'
        'RetroHursty69 tributeSTrek'
        'RetroHursty69 tributeSWars'
        'RetroHursty69 crisp'
        'RetroHursty69 crisp_light'
        'RetroHursty69 primo'
        'RetroHursty69 primo_light'
        'RetroHursty69 back2basics'
        'RetroHursty69 retrogamenews'
        'RetroHursty69 bluray'
        'RetroHursty69 soda'
        'RetroHursty69 lightswitch'
        'RetroHursty69 darkswitch'
        'RetroHursty69 whiteslide'
        'RetroHursty69 graffiti'
        'RetroHursty69 whitewood'
        'RetroHursty69 sublime'
        'RetroHursty69 infinity'
        'RetroHursty69 neogeo_only'
        'RetroHursty69 boxcity'
        'RetroHursty69 vertical_arcade'
        'RetroHursty69 cabsnazzy'
        'RetroHursty69 garfieldism'
        'RetroHursty69 halloweenspecial'
        'RetroHursty69 heychromey'
        'RetroHursty69 homerism'
        'RetroHursty69 spaceinvaders'
        'RetroHursty69 disenchantment'
        'RetroHursty69 minions'
        'RetroHursty69 tmnt'
        'RetroHursty69 pacman'
        'RetroHursty69 dragonballz'
        'RetroHursty69 minecraft'
        'RetroHursty69 incredibles'
        'RetroHursty69 mario_melee'
        'RetroHursty69 evilresident'
        'RetroHursty69 hurstyspin'
        'RetroHursty69 cyber'
        'RetroHursty69 supersweet'
        'RetroHursty69 donkeykonkey'
        'RetroHursty69 snapback'
        'RetroHursty69 heman'
        'RetroHursty69 pitube'
        'RetroHursty69 batmanburton'
        'RetroHursty69 NegativeColor'
        'RetroHursty69 NegativeSepia'
        'RetroHursty69 corg'
        'RetroHursty69 mysticorb'
        'RetroHursty69 joysticks'
        'RetroHursty69 orbpilot'
        'RetroHursty69 bitfit'
        'RetroHursty69 circuit'
        'RetroHursty69 retroboy'
        'RetroHursty69 retroboy2'
        'RetroHursty69 hurstybluetake2'
        'RetroHursty69 fabuloso'
        'RetroHursty69 arcade1up_aspectratio54'
        'RetroHursty69 supersweet_aspectratio54'
        'RetroHursty69 heychromey_aspectratio54'
        'RetroHursty69 mariobrosiii'
        'RetroHursty69 vertical_limit_verticaltheme'
        'RetroHursty69 CapcomColorHorizontal'
        'RetroHursty69 CapcomColorSpin'
        'RetroHursty69 CapcomColorVertical'
        'RetroHursty69 bluesteel'
        'RetroHursty69 blueprism'
        'RetroHursty69 bluesmooth'
        'RetroHursty69 floyd'
        'RetroHursty69 floyd_arcade'
        'RetroHursty69 floyd_room'
        'RetroHursty69 Slick_Bluey'
        'RetroHursty69 Slick_Red'
        'RetroHursty69 ghostbusters'
        'RetroHursty69 realghostbusters'
        'RetroHursty69 stirlingness'
        'RetroHursty69 marco'
        'RetroHursty69 swatch'
        'RetroHursty69 meshy'
        'RetroHursty69 magazinemadness2'
        'RetroHursty69 CosmicRise'
        'RetroHursty69 uniflyered'
        'RetroHursty69 gametime'
        'RetroHursty69 CRTBlast'
        'RetroHursty69 CRTNeonBlast'
        'RetroHursty69 CRTCabBlast'
        'RetroHursty69 ComicCRASHB'
        'RetroHursty69 ComicPACMAN'
        'RetroHursty69 ComicSONIC'
        'RetroHursty69 ComicXMEN'
        'RetroHursty69 ComicZELDA'
        'RetroHursty69 synthy16x9'
        'RetroHursty69 synthyA1UP'
        'RetroHursty69 supersynthy16x9'
        'RetroHursty69 supersynthyA1UP'
        'RetroHursty69 HyperCab'
        'RetroHursty69 NeonFantasy'
        'Saracade scv720'
        'chicueloarcade Chicuelo'
        'SuperMagicom nostalgic'
        'lipebello retrorama'
        'lipebello retrorama-turbo'
        'lipebello strangerstuff'
        'lipebello spaceoddity'
        'lipebello spaceoddity-43'
        'lipebello spaceoddity-wide'
        'lipebello swineapple'
        'waweedman pii-wii'
        'waweedman Blade-360'
        'waweedman Venom'
        'waweedman Spider-Man'
        'blowfinger77 locomotion'
        'justincaseurskynet Arcade1up-5x4-Horizontal'
        'KALEL1981 Super-Retroboy'
        'xovox RetroCRT-240p'
        'xovox RetroCRT-240p-Vertical'
        'arcadeforge push-a'
        'arcadeforge push-a-v'
        'arcadeforge pixel-heaven'
        'arcadeforge pixel-heaven-text'
        'arcadeforge 240p_Bubblegum'
        'arcadeforge 240p-honey'
        'dionmunk clean'
        'c64-dev epicnoir'
        'AndreaMav arcade-crt'
        'AndreaMav arcade-crt2020'
        'Zechariel VectorPie'
        'KALEL1981 nes-box'
        'KALEL1981 super-arcade1up-5x4'
        'KALEL1981 gold-standard'
        'Elratauru angular-artwork'
        'cjonasw raspixel-320-240'
    )
    while true; do
        local theme
        local theme_dir
        local branch
        local name

        local installed_themes=()
        local repo
        local options=()
        local status=()
        local default

        local gallerydir="/etc/emulationstation/es-theme-gallery"
        if [[ -d "$gallerydir" ]]; then
            status+=("i")
            options+=(G "View or Update Theme Gallery")
        else
            status+=("n")
            options+=(G "Download Theme Gallery")
        fi

        options+=(U "Update all installed themes")

        local i=1
        for theme in "${themes[@]}"; do
            theme=($theme)
            repo="${theme[0]}"
            theme="${theme[1]}"
            branch="${theme[2]}"
            name="$repo/$theme"
            theme_dir="$theme"
            if [[ -n "$branch" ]]; then
                name+=" ($branch)"
                theme_dir+="-$branch"
            fi
            if [[ -d "/etc/emulationstation/themes/$theme_dir" ]]; then
                status+=("i")
                options+=("$i" "Update or Uninstall $name (installed)")
                installed_themes+=("$theme $repo $branch")
            else
                status+=("n")
                options+=("$i" "Install $name")
            fi
            ((i++))
        done
        local cmd=(dialog --default-item "$default" --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        [[ -z "$choice" ]] && break
        case "$choice" in
            G)
                if [[ "${status[0]}" == "i" ]]; then
                    options=(1 "View Theme Gallery" 2 "Update Theme Gallery" 3 "Remove Theme Gallery")
                    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option for gallery" 12 40 06)
                    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                    case "$choice" in
                        1)
                            cd "$gallerydir"
                            if isPlatform "x11"; then
                                feh --info "echo %f" --slideshow-delay 6 --fullscreen --auto-zoom --filelist images.list
                            else
                                fbi --timeout 6 --once --autozoom --list images.list
                            fi
                            ;;
                        2)
                            gitPullOrClone "$gallerydir" "https://github.com/wetriner/es-theme-gallery"
                            ;;
                        3)
                            if [[ -d "$gallerydir" ]]; then
                                rm -rf "$gallerydir"
                            fi
                            ;;
                    esac
                else
                    gitPullOrClone "$gallerydir" "http://github.com/wetriner/es-theme-gallery"
                fi
                ;;
            U)
                for theme in "${installed_themes[@]}"; do
                    theme=($theme)
                    rp_callModule esthemes install_theme "${theme[0]}" "${theme[1]}" "${theme[2]}"
                done
                ;;
            *)
                theme=(${themes[choice-1]})
                repo="${theme[0]}"
                theme="${theme[1]}"
                branch="${theme[2]}"
                name="$repo/$theme"
                theme_dir="$theme"
                if [[ -n "$branch" ]]; then
                    name+=" ($branch)"
                    theme_dir+="-$branch"
                fi
                if [[ "${status[choice]}" == "i" ]]; then
                    options=(1 "Update $name" 2 "Uninstall $name")
                    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option for theme" 12 60 06)
                    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                    case "$choice" in
                        1)
                            rp_callModule esthemes install_theme "$theme" "$repo" "$branch"
                            ;;
                        2)
                            rp_callModule esthemes uninstall_theme "$theme_dir"
                            ;;
                    esac
                else
                    rp_callModule esthemes install_theme "$theme" "$repo" "$branch"
                fi
                ;;
        esac
    done
}
