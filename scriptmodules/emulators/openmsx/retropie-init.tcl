namespace eval retropie {

proc init {} {
    set rom_name [guess_title]
    set config_dir [file normalize "$::env(OPENMSX_USER_DATA)/joystick"]

    # sanitize the rom name
    regsub -all {[:><?\"\/\\|*]} $rom_name "" rom_name

    # auto-configure the 1st plugged in joystick, but only if present
    # openMSX automatically loads the plugged in joysticks in 'autoplug.tcl'
    if {![info exists ::joystick1_config]} {
        return
    }

    if { !($rom_name eq "") } {
        if { [ file exists "$config_dir/game/$rom_name.tcl" ] } {
            load_config_joystick $rom_name "$config_dir/game/$rom_name.tcl"
            return
        }
    }

    # get the 1st joystick name
    set joy_name [machine_info pluggable joystick1]
    # ... and sanitize it
    regsub -all {[:><?\"\/\\|*]} $joy_name "" joy_name
    if { [file exists "$config_dir/$joy_name.tcl"] } {
             load_config_joystick $joy_name "$config_dir/$joy_name.tcl"
    }
}

proc load_config_joystick { conf_name conf_script } {
    source "$conf_script"
    # check for the joypad auto-configuration function
    if { [info procs "auto_config_joypad"] == "" } {
        return
    }
    auto_config_joypad
    message "Loaded joystick configuration for '$conf_name'"
}

}; # namespace: retropie

after boot retropie::init
