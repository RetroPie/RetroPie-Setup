#!/bin/bash
realpath () {
	if cd $1; then pwd; else return 1; fi
}
runcommandhome="$(realpath "$(dirname "$(readlink "$0")")")"
. "$runcommandhome/lib/include"

usage () {
	echo "$0 system [rom]"
	exit 1
}
if [[ -z "$1" ]]; then
	usage
fi

is_sys=1
get_sys_command "$1" "$2"


get_all_modes
get_save_vars
load_mode_defaults
main_menu
clear
