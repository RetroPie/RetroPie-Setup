#!/usr/bin/env python3
"""
This file is part of The RetroPie Project

The RetroPie Project is the legal property of its developers, whose names are
too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.

See the LICENSE.md file at the top-level directory of this distribution and
https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md.

Command line joystick to keyboard translator, using SDL2 for event handling
Example usage:
 <script> kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20 0x1b 0x00 kpp knp [--debug|-d]
See https://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html for termcap codes
NB: not all capabilities are supported, but more can be added to the TERM_EVENTS below

SDL2 event handling is based on EmulationStation's event handling, see
https://github.com/RetroPie/EmulationStation/blob/62fd08c26d2f757259b7d890c98c0d7e212f6f84/es-core/src/InputManager.cpp#L205
EmulationStation is authored by Alec "Aloshi" Lofquist (http://www.aloshi.com,http://www.emulationstation.org)

This script uses the PySDL2 module from https://github.com/py-sdl/py-sdl2
This script uses the Python-uinput module from https://github.com/tuomasjjrasanen/python-uinput
"""

import logging
import sys
import signal
import re
import os
import uinput

from argparse import ArgumentParser
from ctypes import create_string_buffer, byref, POINTER, c_int
from configparser import ConfigParser
from sdl2 import joystick, events, version, \
    SDL_WasInit, SDL_Init, SDL_QuitSubSystem, SDL_GetError, \
    SDL_INIT_JOYSTICK, version_info, \
    SDL_Event, SDL_PollEvent, SDL_FlushEvent, SDL_Delay, SDL_Quit, \
    SDL_JOYDEVICEADDED, SDL_JOYDEVICEREMOVED, SDL_QUIT, \
    SDL_JOYBUTTONDOWN, SDL_JOYBUTTONUP, SDL_JOYHATMOTION, SDL_JOYAXISMOTION, \
    SDL_GetTicks
from sdl2.dll import _bind, nullfunc
from sdl2.stdinc import Uint16

logging.basicConfig(level=logging.INFO, format=u"%(asctime)s %(levelname)-6s %(message)s")
LOG = logging.getLogger(__name__)

# Switch for the HIDAPI driver usage in SDL. Disabled since RetroArch/EmulationStation don't use right now
SDL_USE_HIDAPI = False

# Joystick deadzone threshold, as used by EmulationStation (see es-core/InputManager::parseInput)
JS_AXIS_DEADZONE = 23000

# Event polling interval (ms)
JS_POLL_DELAY = 50

# Event repeat in (ms)
JS_REPEAT_DELAY = 125

# Event delay after a button is pressed (ms)
# Set a bit larger than the default repeat delay to prevent multiple inputs being fired
JS_INIT_DELAY = 250

# Hat values defined here, they're not exported by the sdl2.joystick module
SDL_HAT_CENTERED = 0x00
SDL_HAT_UP = 0x01
SDL_HAT_RIGHT = 0x02
SDL_HAT_DOWN = 0x04
SDL_HAT_LEFT = 0x08
JS_HAT_VALUES = {
    "up": SDL_HAT_UP,
    "down": SDL_HAT_DOWN,
    "left": SDL_HAT_LEFT,
    "right": SDL_HAT_RIGHT
}

# Map termios capabilitu codes to Linux (uinput) event ids, for backwards compatibility
# List of possible event IDs:
# https://github.com/tuomasjjrasanen/python-uinput/blob/master/src/ev.py
TERM_EVENTS = {
    "kcub1": 105, # left
    "kcuf1": 106, # right
    "kcud1": 108, # down
    "kcuu1": 103, # up
    "khome": 102, # home
    "kbs"  : 14,  # backspace
    "kend" : 107, # end
    "knp"  : 109, # page-up
    "kpp"  : 104, # page-down
    "kent" : 28,  # enter
    "kf1"  : 59,  # F1
    "kf2"  : 60,  # F2
    "kf3"  : 61,  # F3
    "kf4"  : 62,  # F4
    "kf5"  : 63,  # F5
    "kf6"  : 64,  # F6
    "kf7"  : 65,  # F7
    "kf8"  : 66,  # F8
    "kf9"  : 67,  # F9
    "kf10" : 68   # F10
}

# A charmap with 'ascii_code': 'event_id', needed to translate hex valued parameters
# Copy the one defined in 'uinput', so we can extend it since it's missing some entries
CHAR_MAP = { ord(x):y[1] for (x,y) in uinput._CHAR_MAP.items() }
# add our entries to the map, so we can translate them
CHAR_MAP[27]  = 1   # Escape 
CHAR_MAP[61]  = 13  # Equals (=)
CHAR_MAP[43]  = 12  # Minus (-)
CHAR_MAP[91]  = 26  # Left bracket ([)
CHAR_MAP[93]  = 27  # Right bracket (])
CHAR_MAP[127] = 111 # Delete

# RetroPie configurations directory
CONFIG_DIR = '/opt/retropie/configs'


class InputDev(object):
    """
    Class representing a joystick device config.
    Maps the inputs of the device to event names
    name: the device's name
    guid: the GUID, as returned by SDL
    pid: the ProductID of the device
    vid: the VendorID of the device
    hats - a dictionary of { <HatNo>: list(<HatValue>, <Event>) }
    buttons - a dict of { <ButtonNo>: <Event> }
    axis - a dict of { <AxisNo>: list(<AxisDirection>, <Event>) }
    """

    def __init__(self, _name: str, _vid: int, _pid: int):
        self.name = _name
        self.guid = None
        self.vid = _vid
        self.pid = _pid
        self.axis = {}
        self.buttons = {}
        self.hats = {}

    def add_mappings(self, _axis: dict, _buttons: dict, _hats: dict):
        self.axis, self.buttons, self.hats = _axis, _buttons, _hats

    def get_btn_event(self, index: int) -> list:
        if index in self.buttons:
            return [self.buttons[index]]
        else:
            return None

    def get_hat_event(self, index: int, value: int) -> list:
        if index in self.hats:
            return [x[1] for x in self.hats[index] if x[0] & value > 0]
        else:
            return None

    def get_axis_event(self, index: int, value: int) -> list:
        if index in self.axis:
            return [x[1] for x in self.axis[index] if x[0] == value]
        else:
            return None

    def __str__(self) -> str:
        return str(f'{self.name} (P:{self.pid}, V:{self.vid}), hats: {self.hats}, buttons: {self.buttons}, axis: {self.axis}')


def generic_event_map(input: str, event_map: dict) -> str:
    for k, v in event_map.items():
        if isinstance(v, list):
            if input in v:
                return k
        elif isinstance(v, str) and input == v:
                return k
    return input


def ra_event_map(input_str: str) -> str:
    """
    Maps a RetroArch input option name to an event name
    Example:
        'input_a_btn' -> 'a'
        'input_l_axis' -> 'pageup'
    """
    ra_event_map = {
        'up': ['l_y_minus', 'r_y_minus'],
        'down': ['l_y_plus', 'r_y_plus'],
        'left': ['l_x_minus', 'r_x_minus'],
        'right': ['l_x_plus', 'r_x_plus'],
        'pageup': 'l',
        'pagedown': 'r'
    }

    input_norm = input_str.replace('input_', '').replace('_axis', '').replace('_btn', '')
    return generic_event_map(input_norm, ra_event_map)


def ra_input_parse(key: str, value: str):
    """
    For a RetroArch input option line ('key = value'), returns a triplet consisting of
     - the type of the input (button, hat, axis)
     - the index of the input (button number, hat number, axis number)
     - the input value associated: 1 for buttons, axis direction (-1/1), hat value (1,2,4,8)
    Ex:
      - ('input_a_btn', '1') -> 'button', 1, 1
      - ('input_left_btn, 'h0left') -> 'hat', '0', 8
      - ('input_r_x_axis_minus, -1) -> 'axis', 1, -1
    """
    try:
        if key.endswith('btn'):
            if value.startswith('h'):
                input_type = 'hat'
                hat_value = re.split(r'([0-9]+)', value)[1:]
                # reject malformed hat values
                if hat_value[1] not in JS_HAT_VALUES:
                    raise ValueError('Not a valid hat value')
                input_index, input_value = int(hat_value[0]), JS_HAT_VALUES[hat_value[1]]
            else:
                input_type = 'button'
                input_index, input_value = int(value), 1
        elif key.endswith('axis'):
            input_type = 'axis'
            input_index, input_value = int(value[1:]), int(f'{value[0]}1')
        else:  # unknown input
            return None, None, None

        return input_type, input_index, input_value
    except ValueError as e:
        return None, None, None


def get_all_ra_config(def_buttons: list) -> list:
    """
    Reads the RetroArch's gamepad auto-configuration folder
    and creates a list with of the configured joystick devices as InputDev objects
    """
    ra_config_list = []
    # add a generic mapping at index 0, to be used for un-configured joysticks
    generic_dev = InputDev("*", None, None)
    generic_dev.add_mappings(
        {},  # no axis
        {0: 'b', 1: 'a', 3: 'y', 4: 'x'},  # 4 buttons
        {0: [(1, 'up'), (8, 'left'), (4, 'down'), (2, 'right')]}  # 1 D-Pad as 'hat0'
    )
    ra_config_list.append(generic_dev)
    js_cfg_dir = CONFIG_DIR + '/all/retroarch-joypads/'

    config = ConfigParser(delimiters="=", strict=False, interpolation=None, converters={'int': (lambda s: s.strip('"'))})
    for file in os.listdir(js_cfg_dir):
        # skip non '.cfg' files
        if not file.endswith('.cfg') or file.startswith('.'):
            continue

        with open(js_cfg_dir + file, 'r') as cfg_file:
            try:
                config.clear()
                # ConfigParser needs a section, make up a section to appease it
                config.read_string('[device]\n' + cfg_file.read())
                LOG.debug(f'Parsing config "{file}"')
                conf_vals = config['device']
                dev_name = conf_vals['input_device'].strip('"')
                # fallback to None if there are no PID/VID in the configuration
                dev_vid = conf_vals.getint('input_vendor_id', None)
                dev_pid = conf_vals.getint('input_product_id', None)

                # translate the RetroArch inputs from the configuration file
                axis, buttons, hats = {}, {}, {}
                for i in conf_vals:
                    if i.startswith('input') and (i.endswith('btn') or i.endswith('axis')):
                        input_type, input_index, input_value = ra_input_parse(i, conf_vals[i].strip('"'))

                        # check if the input is mapped to one of the events we recognize
                        event_name = ra_event_map(i)
                        if event_name not in def_buttons:
                            continue
                        if input_type == 'button':
                            buttons[input_index] = event_name
                        elif input_type == 'hat':
                            hats.setdefault(input_index, []).append((input_value, event_name))
                        elif input_type == 'axis':
                            axis.setdefault(input_index, []).append((input_value, event_name))
                        else:
                            continue
                ra_dev_config = InputDev(dev_name, dev_vid, dev_pid)
                ra_dev_config.add_mappings(axis, buttons, hats)
                ra_config_list.append(ra_dev_config)
                LOG.debug(f'Added config for "{dev_name}" from "{file}"')
            except Exception as e:
                LOG.warning(f'Parsing error for {file}: {e}')
                continue

    return ra_config_list


def filter_active_events(event_queue: dict) -> list:
    """
    Method to filter out the event if the event:
     * fired once within the JS_POLL_DELAY_DEBOUNCE
     * fired multiple times, last fire within JS_POLL_POLL_DELAY_DEFAULT
    """
    current_time = SDL_GetTicks()
    filtered_events = []
    for e in event_queue:
        if event_queue[e][0] is None:
            continue

        last_fire_time = event_queue[e][2]
        repeat_count = event_queue[e][1]

        if repeat_count == 0 or \
             (repeat_count == 1 and current_time > (last_fire_time + JS_INIT_DELAY)) or \
             (repeat_count > 1 and current_time > (last_fire_time + JS_REPEAT_DELAY)):
            filtered_events.extend(event_queue[e][0])
            event_queue[e][2] = current_time
            event_queue[e][1] += 1

    # remove any duplicate events from the list
    return list(set(filtered_events))

"""
Remove all queued events for a device
"""
def remove_events_for_device(event_queue: dict, dev_index: int):
    return { key:value for (key,value) in event_queue.items() if not key.startswith(f"{dev_index}_")}

def event_loop(configs, joy_map):
    event = SDL_Event()

    # keep of dict of active joystick devices as a dict of
    #  instance_id -> (config_id, SDL_Joystick object)
    active_devices = {}

    # keep an event queue populated with the current active inputs
    # indexed by joystick index, input type and input index
    # the values consist of:
    # - the event list (as taked from the event configuration)
    # - the number of times event was emitted (repeated)
    # - the last time when the event was fired
    # e.g. { event_hash -> ([event_list], repeat_no, last_fire_time) }
    event_queue = {}

    # keep track of axis previous values
    axis_prev_values = {}

    # instantiate a keyboard device with uinput to send the translated joypad inputs as keys
    keyboard_events = [ (0x1,code) for code in joy_map.values() ]
    LOG.debug(f'Creating uinput keyboard devices with events: {keyboard_events}')
    kbd = uinput.Device(events=keyboard_events, name="Joy2Key Keyboard")

    def handle_new_input(e: SDL_Event, axis_norm_value: int = 0) -> bool:
        """
        Event handling for button press/hat movement/axis movement
        Only needed when an new input is present
        Returns True when 'event_queue' is modified with a new event
        """
        dev_index = active_devices[event.jdevice.which][0]
        if e.type == SDL_JOYBUTTONDOWN:
            mapped_events = configs[dev_index].get_btn_event(event.jbutton.button)
            event_index = f'{dev_index}_btn{event.jbutton.button}'
        elif e.type == SDL_JOYHATMOTION:
            mapped_events = configs[dev_index].get_hat_event(event.jhat.hat, event.jhat.value)
            event_index = f'{dev_index}_hat{event.jhat.hat}'
        elif e.type == SDL_JOYAXISMOTION and axis_norm_value != 0:
            mapped_events = configs[dev_index].get_axis_event(event.jaxis.axis, axis_norm_value)
            event_index = f'{dev_index}_axis{event.jaxis.axis}'

        if mapped_events is not None:
            event_queue[event_index] = [ mapped_events, 0, SDL_GetTicks() ]
            return True

        return False

    running = True
    while running:
        input_started = False

        while SDL_PollEvent(byref(event)):

            if event.type == SDL_QUIT:
                running = False
                break

            if event.type == SDL_JOYDEVICEADDED:
                stick = joystick.SDL_JoystickOpen(event.jdevice.which)
                name = joystick.SDL_JoystickName(stick).decode('utf-8')
                guid = create_string_buffer(33)
                vid = joystick.SDL_JoystickGetVendor(stick)
                pid = joystick.SDL_JoystickGetProduct(stick)

                _SDL_JoystickGetGUIDString(joystick.SDL_JoystickGetGUID(stick), guid, 33)
                LOG.debug(f'Joystick #{joystick.SDL_JoystickInstanceID(stick)} {name} (P:{pid}, V:{vid}) added')
                conf_found = False
                # try to find a configuration for the joystick, based on name, GUID and Vendor/Product IDs
                for key, dev_conf in enumerate(configs):
                    if dev_conf.name == str(name) or dev_conf.guid == guid.value.decode() or \
                       (dev_conf.pid == str(pid) and dev_conf.vid == str(vid)):
                        # Add the matching joystick configuration to the watched list
                        active_devices[joystick.SDL_JoystickInstanceID(stick)] = (key, stick)
                        LOG.debug(f'Added configuration for known device {configs[key]}')
                        conf_found = True
                        break

                # add the default configuration for unknown/un-configured joysticks
                if not conf_found:
                    LOG.debug(f'Un-configured device "{str(name)}", mapped using generic mapping')
                    active_devices[joystick.SDL_JoystickInstanceID(stick)] = (0, stick)

                # if the device has axis inputs, initialize to zero their initial position
                if joystick.SDL_JoystickNumAxes(stick) > 0:
                    axis_prev_values[joystick.SDL_JoystickInstanceID(stick)] = [0 for x in range(joystick.SDL_JoystickNumAxes(stick))]

                # Remove any spurious axis movements reported by SDL during initialization
                SDL_FlushEvent(SDL_JOYAXISMOTION);
                continue

            if event.jdevice.which not in active_devices:
                continue
            else:
                dev_index = active_devices[event.jdevice.which][0]

            if event.type == SDL_JOYDEVICEREMOVED:
                joystick.SDL_JoystickClose(active_devices[event.jdevice.which][1])
                if event.jdevice.which in active_devices:
                    event_queue = remove_events_for_device(event_queue, active_devices[event.jdevice.which][0])
                active_devices.pop(event.jdevice.which, None)
                axis_prev_values.pop(event.jdevice.which, None)
                LOG.debug(f'Removed joystick #{event.jdevice.which}')

            if event.type == SDL_JOYBUTTONDOWN:
                input_started = handle_new_input(event)

            if event.type == SDL_JOYBUTTONUP:
                event_queue.pop(f'{dev_index}_btn{event.jbutton.button}', None)

            if event.type == SDL_JOYHATMOTION:
                if event.jhat.value != SDL_HAT_CENTERED:
                    input_started = handle_new_input(event)
                else:
                    event_queue.pop(f'{dev_index}_hat{event.jhat.hat}', None)

            if event.type == SDL_JOYAXISMOTION:
                # check if the axis value went over the deadzone threshold
                if (abs(event.jaxis.value) > JS_AXIS_DEADZONE) \
                        != (abs(axis_prev_values[event.jdevice.which][event.jaxis.axis]) > JS_AXIS_DEADZONE):
                    # normalize the axis value to the movement direction or stop the input
                    if abs(event.jaxis.value) <= JS_AXIS_DEADZONE:
                        event_queue.pop(f'{dev_index}_axis{event.jaxis.axis}', None)
                    else:
                        if event.jaxis.value < 0:
                            axis_norm_value = -1
                        else:
                            axis_norm_value = 1
                        input_started = handle_new_input(event, axis_norm_value)
                # store the axis current values for tracking
                axis_prev_values[event.jdevice.which][event.jaxis.axis] = event.jaxis.value

        # process the current events in the queue
        if len(event_queue):
            emitted_events = filter_active_events(event_queue)
            if len(emitted_events):
                LOG.debug(f'Events to emit: {emitted_events}')
            # send the events mapped key code(s) to the terminal
            for k in emitted_events:
                if k in joy_map:
                    c = joy_map[k]
                    LOG.debug(f'Emitting input code {c}')
                    kbd.emit_click( (0x1,c) )

        SDL_Delay(JS_POLL_DELAY)


def parse_arguments(args):
    parser = ArgumentParser(
        description='Translate joystick events to keyboard inputs')

    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        help='print debugging messages',
        default=False)
    parser.add_argument(
        'hex_chars', type=str, nargs='+',
        metavar='0xHEX',
        help='list of mapped character codes to translate')

    args = parser.parse_args()
    return args.debug, args.hex_chars


def ra_btn_swap_config():
    """
    Returns the state of 'menu_swap_ok_cancel_buttons' configuration for RetroArch
    """
    config = ConfigParser(delimiters="=", strict=False, interpolation=None)
    with open(CONFIG_DIR + '/all/retroarch.cfg', 'r') as cfg_file:
        config.read_string('[device]\n' + cfg_file.read())
        try:
            menu_swap = config['device']['menu_swap_ok_cancel_buttons'].strip('"') == 'true'
        except Exception as e:
            menu_swap = False

    return menu_swap

def get_uinput_event(key_str: str):
    """
    For a Termios control string or an ASCII hex code, return the Linux scancode (integer)
    See https://github.com/tuomasjjrasanen/python-uinput/blob/master/src/ev.py for an enumeratin of scancodes

    If 'key_str' starts with '0x', it's assumed to be a hexadecimal value of an ASCII char,
    otherwise it's presumed to be a termios control string tied to the terminal's capabilities
    """
    try:
        if key_str.startswith('/'):
            # ignore any device name - they're not part of our assignment
            return None

        if key_str.startswith('0x'):
            out = int(key_str,0)
            # hex numbers are considered ASCII codes for keyboard keys
            # we need to translate them to Linux input scancodes
            out = CHAR_MAP[out]
        else:
            if (key_str in TERM_EVENTS.keys()):
                out = TERM_EVENTS[key_str]
            else:
                LOG.warning(f'Unsupported termios control code "{key_str}", value ignored')
                return 0
        return out
    except Exception as e:
        LOG.debug(f'Cannot determine input code for "{key_str}", value ignored')
        return 0

def _SDL_JoystickGetGUIDString(guid, pszGUID, cbGUID):
    """
    Local method implementing https://github.com/marcusva/py-sdl2/pull/156
    Prevents a segfault with older (<3.8) Python AND older Py-SDL2 (<0.9.7)
    """
    if sys.version_info >= (3, 8, 0, 'final'):
         joystick.SDL_JoystickGetGUIDString(guid, pszGUID, cbGUID)
    else:
         s = ""
         for g in guid.data:
              s += "{:x}".format(g >> 4)
              s += "{:x}".format(g & 0x0F)

         s = s.encode('utf-8')
         pszGUID.value = s[:(cbGUID * 2)]


def main():
    # install a signal handler so the script can stop safely
    def signal_handler(signum, frame):
        signal.signal(signal.SIGINT, signal.SIG_IGN)
        signal.signal(signal.SIGTERM, signal.SIG_IGN)

        if SDL_WasInit(SDL_INIT_JOYSTICK) == SDL_INIT_JOYSTICK:
            SDL_QuitSubSystem(SDL_INIT_JOYSTICK)
        SDL_Quit()
        LOG.debug(f'{sys.argv[0]} exiting cleanly')
        sys.exit(0)

    debug_flag, hex_chars = parse_arguments(sys.argv)
    if debug_flag:
        LOG.setLevel(logging.DEBUG)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    # when running with no debugging, daemonize after signal handlers are registered
    if not debug_flag:
        if os.fork():
            os._exit(0)
    else:
        LOG.debug(f'Debugging enabled, running in foreground')

    mapped_chars = [get_uinput_event(code) for code in hex_chars if get_uinput_event(code) is not None]
    def_buttons = ['left', 'right', 'up', 'down', 'a', 'b', 'x', 'y', 'pageup', 'pagedown']
    joy_map = {}
    # add for each button the mapped keycode, based on the arguments received
    for i, btn in enumerate(def_buttons):
        if i < len(mapped_chars):
            joy_map[btn] = mapped_chars[i]

    LOG.debug(f'Joy map:\n {joy_map}')
    menu_swap = ra_btn_swap_config()
    # if button A is <enter> and menu_swap_ok_cancel_buttons is true, swap buttons A and B functions
    if menu_swap \
            and 'a' in joy_map.keys() \
            and 'b' in joy_map.keys() \
            and joy_map['a'] == '\n':
        joy_map['a'] = joy_map['b']
        joy_map['b'] = '\n'

    # tell SDL that we don't want to grab and lock the keyboard
    os.environ['SDL_INPUT_LINUX_KEEP_KBD'] = '1'

    # disable the HIDAPI joystick driver in SDL
    if not(SDL_USE_HIDAPI):
        os.environ['SDL_JOYSTICK_HIDAPI'] = '0'

    # tell SDL to not add any signal handlers for TERM/INT
    os.environ['SDL_NO_SIGNAL_HANDLERS'] = '1'

    configs = get_all_ra_config(def_buttons)

    if SDL_Init(SDL_INIT_JOYSTICK) < 0:
        LOG.error(f'Error in SDL_Init: {SDL_GetError()}')
        exit(2)

    if LOG.isEnabledFor(logging.DEBUG):
        sdl_ver = version.SDL_version()
        version.SDL_GetVersion(byref(sdl_ver))
        wrapper_version = '.'.join(str(i) for i in version_info)
        LOG.debug(f'Using SDL Version {sdl_ver.major}.{sdl_ver.minor}.{sdl_ver.patch}, PySDL2 version {wrapper_version}')

    if joystick.SDL_NumJoysticks() < 1:
        LOG.debug(f'No available joystick devices found on startup')

    # 'SDL_JoystickGetVendor' and 'SDL_JoystickGetProduct' are not in PySDL2 before 0.9.6
    # so add a local implementation for them when they're not found
    if 'SDL_JoystickGetVendor' not in dir(joystick):
        LOG.debug(f'Function "SDL_JoystickGetVendor" not found in PySDL2 {wrapper_version}, adding a local definition for it')
        joystick.SDL_JoystickGetVendor = _bind("SDL_JoystickGetVendor", [POINTER(joystick.SDL_Joystick)], Uint16, nullfunc)

    if 'SDL_JoystickGetProduct' not in dir(joystick):
        LOG.debug(f'Function "SDL_JoystickGetProduct" not found in PySDL2 {wrapper_version}, adding a local definition for it')
        joystick.SDL_JoystickGetProduct = _bind("SDL_JoystickGetProduct", [POINTER(joystick.SDL_Joystick)], Uint16, nullfunc)

    event_loop(configs, joy_map)

    SDL_QuitSubSystem(SDL_INIT_JOYSTICK)
    SDL_Quit()
    return 0


if __name__ == "__main__":
    sys.exit(main())
