#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="launchingimages"
rp_module_desc="Generate runcommand launching images based on emulationstation themes."
rp_module_help="A runcommand launching image is displayed while loading a game, with this tool you can automatically create some cool images based on a chosen emulationstation theme you have on your system."
rp_module_section="exp"
rp_module_flags="noinstclean"

function depends_launchingimages() {
    local depends=(imagemagick librsvg2-bin)
    if isPlatform "x11"; then
        getDepends feh
    else
        getDepends fbi
    fi
    getDepends "${depends[@]}"
}

function sources_launchingimages() {
    gitPullOrClone "$md_inst" "https://github.com/meleu/generate-launching-images.git"
}

function install_launchingimages() {
    cd "$md_inst"
    chmod a+x generate-launching-images.sh
}

function _show_images() {
    [[ -f "$1" ]] || return 1

    local image="$1"
    local timeout=5
    local is_list=0

    [[ "$(file -i $1)" =~ text/plain ]] && is_list=1

    if isPlatform "x11"; then
        feh \
          --cycle-once \
          --hide-pointer \
          --fullscreen \
          --auto-zoom \
          --no-menus \
          --slideshow-delay $timeout \
          --quiet \
          $([[ "$is_list" -eq 1 ]] && echo --filelist) \
          "$image"
    else
        fbi \
          --once \
          --timeout "$timeout" \
          --noverbose \
          --autozoom \
          $([[ "$is_list" -eq 1 ]] && echo --list) \
          "$image" </dev/tty &>/dev/null
    fi
}

function _dialog_menu() {
    local text="$1"
    shift
    [[ -z "$@" ]] && return 1

    # when there's only one item for the menu the, the 'dialog --menu' expect
    # to receive a "tag" and an "item" even if using '--no-item'. It can be
    # an edge case, but this function shouldn't crash when it happens.
    if [[ "$#" -eq 1 ]]; then
        echo "$1"
        return
    fi

    dialog \
      --backtitle "$__backtitle" \
      --no-items \
      --menu "$text" \
      22 86 16 \
      $@ \
      2>&1 >/dev/tty
}

function _set_theme() {
      _dialog_menu \
        "List of available themes" \
        $("$md_inst/generate-launching-images.sh" --list-themes) \
      || echo "\$theme"
}

function _set_system() {
    local choice=$(
        _dialog_menu \
          "List of available systems.\n\nSelect the system you want to generate a launching image or cancel to generate for all systems." \
          $("$md_inst/generate-launching-images.sh" --list-systems)
    )
    [[ -n "$choice" ]] && echo "--system $choice" \
    || echo "\$system"
}

function _set_extension() {
    _dialog_menu \
      "Choose the file extension of the final launching image." \
      png jpg \
    || echo "\$extension"
}

function _set_show_timeout() {
    _dialog_menu \
      "Set how long the image will be displayed before asking if you accept (in seconds)" \
      1 2 3 4 5 6 7 8 9 10 \
    || echo "\$show_timeout"
}

function _set_loading_text() {
    dialog \
      --backtitle "$__backtitle" \
      --inputbox "Enter the \"NOW LOADING\" text (or leave blank to no text):" \
      0 70 \
      "NOW LOADING" \
      2>&1 >/dev/tty \
    || echo "\$loading_text"
}

function _set_press_button_text() {
    dialog \
      --backtitle "$__backtitle" \
      --inputbox "Enter the \"PRESS A BUTTON\" text (or leave blank to no text):" \
      0 70 \
      "PRESS A BUTTON TO CONFIGURE LAUNCH OPTIONS" \
      2>&1 >/dev/tty \
    || echo "\$press_button_text"
}

function _select_color() {
    _dialog_menu \
      "Pick a color for the $1" \
      white black silver gray gray10 gray25 gray50 gray75 gray90 \
      red orange yellow green cyan blue cyan purple pink brown
}

function _set_loading_text_color() {
    _select_color "\"LOADING\" text" \
    || echo "\$loading_text_color"
}

function _set_press_button_text_color() {
    _select_color "\"PRESS A BUTTON\" text" \
    || echo "\$press_button_text_color"
}

function _set_solid_bg_color() {
    local choice
    local cmd=(dialog --backtitle "$__backtitle" --menu "Color to use as background" 22 86 16)
    local options=(
          0 "Disable \"solid background color\""
          1 "Use the system color defined by theme" \
          2 "Select a color" \
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case "$choice" in
        0)  echo
            ;;
        1)  echo "--solid-bg-color"
            ;;
        2)  echo "--solid-bg-color $(_select_color background)"
            ;;
        *)  echo "\$solid_bg_color"
            ;;
    esac
}

function _dialog_yesno() {
    dialog --backtitle "$__backtitle" --yesno "$@" 20 60 2>&1 >/dev/tty
}

function _set_no_ask() {
    _dialog_yesno "If you enable \"no_ask\" all generated images will be automatically accepted.\n\nDo you want to enable it?" \
    && echo "--no-ask"
}

function _set_no_logo() {
    _dialog_yesno "If you enable \"no_logo\" the images won't have the system logo (useful for tronkyfran theme, for example).\n\nDo you want to enable it?" \
    && echo "--no-logo"
}

function _set_logo_belt() {
    _dialog_yesno "If you enable \"logo_belt\" the image will have a semi-transparent white belt behind the logo.\n\nDo you want to enable it?" \
    && echo "--logo-belt"
}

function _get_all_launching_images() {
    find "$configdir" -type f -regex ".*launching\.\(png\|jpg\)" | sort
}

function _is_theme_chosen() {
    if [[ -z "$1" ]]; then
        printMsgs "dialog" "You didn't choose a theme!\n\nGo to the \"Image generation settings\" and choose one."
        return 1
    fi
}

function _get_presetting_file() {
    local file_list=$(find "$md_inst" -type f -name '*.cfg' | xargs basename -a)
    if [[ -z "$file_list" ]]; then
        printMsgs "dialog" "There's no presettings file saved."
        return 1
    fi
    _dialog_menu "Choose the file" "$file_list" || return 1
}


function gui_launchingimages() {
    local cmd=()
    local options=()
    local choice
    local file

    # image generation settings
    local theme=
    local extension="png"
    local show_timeout=5
    local loading_text="NOW LOADING"
    local press_button_text="PRESS A BUTTON TO CONFIGURE LAUNCH OPTIONS"
    local loading_text_color="white"
    local press_button_text_color="gray50"
    local no_ask=
    local no_logo=
    local solid_bg_color=
    local system=
    local logo_belt=
    local presettings_file=

    while true; do
        cmd=(dialog 
          --backtitle "$__backtitle"
          --title " runcommand launching images generation "
          --menu "Choose an option."
          22 86 16
        )
        options=( 
            1 "Image generation settings"
            2 "Generate launching images"
            3 "View slideshow of all current launching images"
            4 "View a specific system's launching image"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1) # Image generation settings
                    cmd=(dialog
                        --backtitle "$__backtitle"
                        --title " SETTINGS "
                        --menu "runcommand launching images generation settings."
                        22 86 16
                    )
                    while true; do
                        options=( 
                            presettings_file "$(
                               [[ "$theme" = "${presettings_file%.cfg}" ]] && echo "$presettings_file"
                            )"
                            theme "$theme"
                            system "$(
                                if [[ -z "$system" ]]; then
                                    echo "all systems in es_systems.cfg"
                                else
                                    echo "$system" | cut -d' ' -f2
                                fi
                            )"
                            extension ".$extension"
                            loading_text "\"$loading_text\""
                            press_button_text "\"$press_button_text\""
                            loading_text_color "$loading_text_color"
                            press_button_text_color "$press_button_text_color"
                            show_timeout "$( [[ -n "$no_ask" ]] && echo "don't show (see no_ask)" || echo "$show_timeout seconds")"
                            no_ask "$( [[ -n "$no_ask" ]] && echo true || echo false)"
                            no_logo "$( [[ -n "$no_logo" ]] && echo true || echo false)"
                            logo_belt "$( [[ -n "$logo_belt" ]] && echo true || echo false)"
                            solid_bg_color "$(
                                if [[ -z "$solid_bg_color" ]]; then
                                    echo false
                                elif [[ -z "$(echo "$solid_bg_color" | cut -s -d' ' -f2)" ]]; then
                                    echo "get from the theme"
                                else
                                    echo "$solid_bg_color" | cut -s -d' ' -f2
                                fi
                            )"
                        )
                        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

                        [[ -z "$choice" ]] && break

                        if [[ "$choice" = "presettings_file" ]]; then
                            while true; do
                                choice=$(
                                    dialog \
                                      --backtitle "$__backtitle" \
                                      --title " PRE SETTINGS " \
                                      --menu "Choose an option\nCurrent presettings file: $presettings_file" \
                                      22 86 16 \
                                      1 "Load a pre-settings file" \
                                      2 "Save current settings for \"$theme\"" \
                                      3 "Delete a pre-settings file" \
                                      2>&1 >/dev/tty
                                )

                                case "$choice" in
                                    1)
                                        presettings_file=$(_get_presetting_file) || continue
                                        local configs=$(cat "$md_inst/$presettings_file" | tr '\n' ' ')
                                        eval "$configs"
                                        break
                                        ;;

                                    2)
                                        _is_theme_chosen "$theme" || break
                                        file="$md_inst/$theme.cfg"
                                        if [[ -f "$file" ]]; then
                                            _dialog_yesno "\"$file\" exists.\nDo you want to overwrite it?" \
                                            || continue
                                        fi
                                        presettings_file="$(basename $file)"
                                        echo -n > "$file"
                                        local var
                                        for var in \
                                          theme extension show_timeout \
                                          loading_text loading_text_color \
                                          press_button_text \
                                          press_button_text_color no_ask \
                                          no_logo solid_bg_color system \
                                          logo_belt
                                        do
                                            echo "$var"=\"${!var}\" >> "$file"
                                        done
                                        printMsgs "dialog" "\"$file\" saved!"
                                        break
                                        ;;

                                    3)
                                        presettings_file=$(_get_presetting_file) || continue

                                        _dialog_yesno "Are you sure you want to delete \"$presettings_file\"?" \
                                        || continue

                                        rm "$md_inst/$presettings_file" \
                                        && printMsgs "dialog" "\"$presettings_file\" deleted!"

                                        presettings_file=""
                                        ;;

                                    *)
                                        break
                                        ;;
                                esac
                            done
                            continue
                        fi

                        eval "$choice"=\"$(_set_$choice)\"
                    done
                    ;;

                2) # Generate launching images
                    _is_theme_chosen "$theme" || continue
                    "$md_inst/generate-launching-images.sh" \
                      --theme "$theme" \
                      --extension "$extension" \
                      --show-timeout "$show_timeout" \
                      --loading-text "$loading_text" \
                      --press-button-text "$press_button_text" \
                      --loading-text-color "$loading_text_color" \
                      --press-button-text-color "$press_button_text_color" \
                      $system \
                      $solid_bg_color \
                      $no_ask \
                      $no_logo \
                      $logo_belt \
                      2>&1 >/dev/tty
                    if [[ "$?" -ne 0 ]]; then
                        printMsgs "dialog" "Unable to generate launching images. Please check the \"Image generation settings\"."
                        continue
                    fi
                    for file in $(_get_all_launching_images); do
                        chown $user:$user "$file"
                    done
                    ;;

                3) # View slideshow of all current launching images
                    file=$(mktemp)
                    _get_all_launching_images > "$file"
                    if [[ -s "$file" ]]; then
                        _show_images "$file"
                    else
                        printMsgs "dialog" "There are no launching images found on your system."
                    fi
                    rm -f "$file"
                    ;;

                4) # View the launching image of a specific system
                    choice=$(_dialog_menu "Choose the system" $(_get_all_launching_images))
                    [[ -z "$choice" ]] && continue
                    _show_images "$choice"
                    continue
                    ;;

            esac
        else
            break
        fi
    done
}
