namespace eval retropie {

proc init {} {
    set rom_name [guess_title]
    set config_dir [file normalize "$::env(OPENMSX_USER_DATA)/joystick"]

    # sanitize the rom name
    regsub -all {[:><?\"\/\\|*]} $rom_name "" rom_name

    # auto-configure joystick(s), but only if present
    # openMSX automatically loads the plugged in joysticks in 'autoplug.tcl'
    # but does not map them
    if {![info exists ::msxjoystick1_config]} {
        return
    }

    # MSX supports 2 joysticks. Map the first two found host controllers.
    set joy_idx 1
    foreach joy_id [openmsx_info joystick] {
        set host_controller_info [openmsx_info joystick $joy_id]
        set joy_name [dict get $host_controller_info "name"]
        regsub -all {[:><?\"\/\\|*]} $joy_name "" joy_name

        if { !($rom_name eq "") } {
            if { [ file exists "$config_dir/game/${rom_name}_v22.tcl" ] } {
                # map game-specific joystick configuration
                load_config_joystick $joy_idx $joy_id $rom_name "$config_dir/game/${rom_name}_v22.tcl"
                return
            }
        }

        if { [file exists "$config_dir/${joy_name}_v22.tcl"] } {
            load_config_joystick $joy_idx $joy_id $joy_name "$config_dir/${joy_name}_v22.tcl"
        } else {
            # apply default mapping cf. https://github.com/openMSX/openMSX/blob/5ae314755fd1d2e89b0504caad47d2772b043a32/src/input/MSXJoystick.cc#L22
            set cfg_var "msxjoystick${joy_idx}_config"
            upvar #0 $cfg_var joy_cfg
            set joy_cfg {}
            dict set joy_cfg UP    [list [list $joy_id -axis1] [list $joy_id hat0 up] ]
            dict set joy_cfg DOWN  [list [list $joy_id +axis1] [list $joy_id hat0 down] ]
            dict set joy_cfg LEFT  [list [list $joy_id -axis0] [list $joy_id hat0 left] ]
            dict set joy_cfg RIGHT [list [list $joy_id +axis0] [list $joy_id hat0 right] ]
            set num_buttons [dict get $host_controller_info "buttons"]
            for {set i 0} {$i < $num_buttons} {incr i 2} {
                dict lappend joy_cfg A [list $joy_id "button$i"]
                dict lappend joy_cfg B [list $joy_id "button[expr {$i + 1}]"]
            }
            message "Loaded default configuration for joystick$joy_idx '$joy_name'"
        }

        incr joy_idx
        if { $joy_idx > 2 } break
    }
}

proc load_config_joystick { joy_idx joy_id conf_name conf_script } {
    source "$conf_script"
    # check for the joypad auto-configuration function
    if { [info procs "auto_config_joypad"] == "" } {
        return
    }
    auto_config_joypad $joy_idx $joy_id
    message "Loaded configuration for joystick$joy_idx '$conf_name'"
}

}; # namespace: retropie

after boot retropie::init
