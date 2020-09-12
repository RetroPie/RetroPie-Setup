namespace eval retropie {

proc init {} {
    set rom_name [guess_title]
    set config_dir [file normalize "$::env(OPENMSX_USER_DATA)/joystick"]

    # Sanitize rom name
    regsub -all {[\?\<\>\\\/:\*\|]} $rom_name "" rom_name

    # Auto-configure the 1st plugged in joystick, but only if present
    # openMSX automatically loads the plugged in joysticks in 'autoplug.tcl'
    if {![info exists ::joystick1_config]} {
        return
    }

    # Disable the OSD menu box added by osd_menu.tcl
    osd destroy main_menu_pop_up_button

    if { !($rom_name eq "") } {
        if { [ file exists "$config_dir/game/$rom_name.tcl" ] } {
            load_config_joystick $rom_name "$config_dir/game/$rom_name.tcl"
            return
        }
    }

    if { [catch {exec udevadm info --name=/dev/input/js0 | grep -q "ID_INPUT_JOYSTICK=1"}] == 0 } {
        set path [exec udevadm info --name=/dev/input/js0 --query=name]
        set joy_name [exec cat /sys/class/$path/device/name]
        regsub -all {[\?\<\>\\\/:\*\|]} $joy_name "" joy_name$
        if { [file exists "$config_dir/$joy_name.tcl"] } {
                load_config_joystick $joy_name "$config_dir/$joy_name.tcl"
        }
    }
}

proc load_config_joystick { conf_name conf_script } {
    source "$conf_script"
    # Check for auto configuration function
    if { [info procs "auto_config_joypad"] == "" } {
        return
    }
    auto_config_joypad
    message "Loaded joystick configuration for '$conf_name'"
}

}; # namespace: retropie

after boot retropie::init
