#!/usr/bin/env bash
ROOTDIR=""
MD_CONF_ROOT=""
ROMDIR=""
MD_INST=""
DIALOG=(dialog --backtitle "RetroPie Jump n' Bump Launcher")

# source ini functions from RetroPie
source "$ROOTDIR/lib/inifuncs.sh"

# init program args
function init_args() {
    args=(-fullscreen)
    iniConfig " = " "" "$MD_CONF_ROOT/jumpnbump/options.cfg"
    iniGet "nogore" && [[ "$ini_value" -eq 1 ]] && args+=(-nogore)
    iniGet "noflies" && [[ "$ini_value" -eq 1 ]] && args+=(-noflies)
    iniGet "scaleup" && [[ "$ini_value" -eq 1 ]] && args+=(-scaleup)
    iniGet "musicnosound" && [[ "$ini_value" -eq 1 ]] && args+=(-musicnosound)
    return 0
}

# main menu
function main_menu() {
    local cmd
    local options
    local choice
    while true; do
        cmd=("${DIALOG[@]}" --menu "Main Menu" 0 0 0)
        options=(
            L "Local Game Mode"
            S "Net: Start Server"
            C "Net: Connect to Server"
            H "Net: Help"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || return
        case "$choice" in
            L) init_args && select_level_menu && return ;;
            S) init_args && start_server_menu && select_level_menu && return ;;
            C) init_args && connect_server_menu && select_level_menu && return ;;
            H) netplay_help ;;
        esac
    done
}

# select level menu
function select_level_menu() {
    local cmd=("${DIALOG[@]}" --ok-label "Start" --extra-button --extra-label "Start Mirror" --menu "Select Level" 16 0 16)
    local levels=(D "(default level)")
    local idx=1
    local choice
    local ret
    for file in "$ROMDIR"/ports/jumpnbump/*.dat; do
        levels+=("$idx" "${file##*/}")
        ((idx++))
    done
    choice=$("${cmd[@]}" "${levels[@]}" 2>&1 >/dev/tty)
    ret=$?
    [[ "$ret" -eq 1 ]] && return 1
    [[ "$ret" -eq 3 ]] && args+=(-mirror)
    [[ "$choice" == "D" ]] && return
    args+=(-dat "$ROMDIR/ports/jumpnbump/${levels[$((choice * 2 + 1))]}")
}

# start server menu
function start_server_menu() {
    local cmd=("${DIALOG[@]}" --menu "Number of players" 0 0 0)
    local options=(
        1 "One Remote + One Local"
        2 "Two Remotes + One Local"
        3 "Three Remotes + One Local"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || return
    args+=(-server "$choice")
}

# connect to server menu
function connect_server_menu() {
    local cmd=("${DIALOG[@]}" --inputbox "Please enter the address of the remote server" 10 35)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty) || return
    args+=(-connect "$choice")
}

# netplay help
function netplay_help() {
    local help
    read -r -d "" help <<"_EOF_"
1. On the server device, select "Start Server" and choose the number of additional players (1-3) to wait for.

2. On each remote player device, select "Connect to Server" and enter the IP address of the server.

3. All players (server and clients) must select the same level and mirror settings.
_EOF_
    "${DIALOG[@]}" --title "Net Help" --msgbox "$help" 16 50 2>&1 >/dev/tty
}

# start main menu
main_menu || exit
"$MD_INST"/bin/jumpnbump "${args[@]}" "$@"
