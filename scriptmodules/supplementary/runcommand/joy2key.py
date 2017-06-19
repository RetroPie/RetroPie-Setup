#!/usr/bin/python

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

import os, sys, struct, time, fcntl, termios, signal
import curses, errno, re
from pyudev import Context


#    struct js_event {
#        __u32 time;     /* event timestamp in milliseconds */
#        __s16 value;    /* value */
#        __u8 type;      /* event type */
#        __u8 number;    /* axis/button number */
#    };

JS_MIN = -32768
JS_MAX = 32768
JS_REP = 0.20

JS_THRESH = 0.75

JS_EVENT_BUTTON = 0x01
JS_EVENT_AXIS = 0x02
JS_EVENT_INIT = 0x80

CONFIG_DIR = '/opt/retropie/configs/'
RETROARCH_CFG = CONFIG_DIR + 'all/retroarch.cfg'

def ini_get(key, cfg_file):
    pattern = r'[ |\t]*' + key + r'[ |\t]*=[ |\t]*'
    value_m = r'"*([^"\|\r]*)"*'
    value = ''
    with open(cfg_file, 'r') as ini_file:
        for line in ini_file:
            if re.match(pattern, line):
                value = re.sub(pattern + value_m + '.*\n', r'\1', line)
                break
    return value

def get_btn_num(btn, cfg):
    num = ini_get('input_' + btn + '_btn', cfg)
    if num: return num
    num = ini_get('input_player1_' + btn + '_btn', cfg)
    if num: return num
    return ''

def get_button_codes(dev_path):
    js_cfg_dir = CONFIG_DIR + 'all/retroarch-joypads/'
    js_cfg = ''
    dev_name = ''

    # getting joystick name
    for device in Context().list_devices(DEVNAME=dev_path):
        dev_name_file = device.get('DEVPATH')
        dev_name_file = '/sys' + os.path.dirname(dev_name_file) + '/name'
        for line in open(dev_name_file, 'r'):
            dev_name = line.rstrip('\n')
            break
    if not dev_name:
        return default_button_codes

    # getting retroarch config file for joystick
    for f in os.listdir(js_cfg_dir):
        if f.endswith('.cfg'):
            if ini_get('input_device', js_cfg_dir + f) == dev_name:
                js_cfg = js_cfg_dir + f
                break
    if not js_cfg:
        js_cfg = RETROARCH_CFG

    # getting configs for buttons A, B, X and Y
    btn_num = {}
    biggest_num = 0
    i = 0
    for btn in 'a', 'b', 'x', 'y':
        i += 1
        if i > len(default_button_codes):
            break
        btn_num[btn] = get_btn_num(btn, js_cfg)
        try:
            btn_num[btn] = int(btn_num[btn])
        except ValueError:
            return default_button_codes
        if btn_num[btn] > biggest_num:
            biggest_num = btn_num[btn]

    # building the button codes list
    btn_codes = [''] * (biggest_num + 1)
    i = 0
    for btn in 'a', 'b', 'x', 'y':
        btn_codes[btn_num[btn]] = default_button_codes[i]
        i += 1
        if i >= len(default_button_codes): break

    # if button A is <enter> and menu_swap_ok_cancel_buttons is true, swap buttons A and B functions
    if btn_codes[btn_num['a']] == '\n' and ini_get('menu_swap_ok_cancel_buttons', RETROARCH_CFG) == 'true':
        btn_codes[btn_num['a']] = btn_codes[btn_num['b']]
        btn_codes[btn_num['b']] = '\n'

    return btn_codes

def signal_handler(signum, frame):
    close_fds(js_fds)
    sys.exit(0)

def get_hex_chars(key_str):
    if (key_str.startswith("0x")):
        return key_str[2:].decode('hex')
    else:
        return curses.tigetstr(key_str)

def get_devices():
    devs = []
    if sys.argv[1] == '/dev/input/jsX':
        for dev in os.listdir('/dev/input'):
            if dev.startswith('js'):
                devs.append('/dev/input/' + dev)
    else:
        devs.append(sys.argv[1])

    return devs

def open_devices():
    devs = get_devices()

    fds = []
    for dev in devs:
        try:
            fds.append(os.open(dev, os.O_RDONLY | os.O_NONBLOCK ))
            js_button_codes[fds[-1]] = get_button_codes(dev)
        except:
            pass

    return devs, fds

def close_fds(fds):
    for fd in fds:
        os.close(fd)

def read_event(fd):
    while True:
        try:
            event = os.read(fd, event_size)
        except OSError, e:
            if e.errno == errno.EWOULDBLOCK:
                return None
            return False

        else:
            return event

def process_event(event):

    (js_time, js_value, js_type, js_number) = struct.unpack(event_format, event)

    # ignore init events
    if js_type & JS_EVENT_INIT:
        return False

    hex_chars = ""

    if js_type == JS_EVENT_BUTTON:
        if js_number < len(button_codes) and js_value == 1:
            hex_chars = button_codes[js_number]

    if js_type == JS_EVENT_AXIS and js_number <= 7:
        if js_number % 2 == 0:
            if js_value <= JS_MIN * JS_THRESH:
                hex_chars = axis_codes[0]
            if js_value >= JS_MAX * JS_THRESH:
                hex_chars = axis_codes[1]
        if js_number % 2 == 1:
            if js_value <= JS_MIN * JS_THRESH:
                hex_chars = axis_codes[2]
            if js_value >= JS_MAX * JS_THRESH:
                hex_chars = axis_codes[3]

    if hex_chars:
        for c in hex_chars:
            fcntl.ioctl(tty_fd, termios.TIOCSTI, c)
        return True

    return False

signal.signal(signal.SIGINT, signal_handler)

js_button_codes = {}
button_codes = []
default_button_codes = []
axis_codes = []

curses.setupterm()

i = 0
for arg in sys.argv[2:]:
    chars = get_hex_chars(arg)
    if i < 4:
        axis_codes.append(chars)
    else:
        default_button_codes.append(chars)
    i += 1

event_format = 'IhBB'
event_size = struct.calcsize(event_format)

try:
    tty_fd = open('/dev/tty', 'w')
except:
    print 'Unable to open /dev/tty'
    sys.exit(1)

js_fds = []
rescan_time = time.time()
while True:
    if not js_fds:
        js_devs, js_fds = open_devices()
        if js_fds:
            i = 0
            current = time.time()
            js_last = [None] * len(js_fds)
            for js in js_fds:
                js_last[i] = current
                i += 1
        else:
            time.sleep(1)
    else:
        i = 0
        for fd in js_fds:
            event = read_event(fd)
            if event:
                if time.time() - js_last[i] > JS_REP:
                    if fd in js_button_codes:
                        button_codes = js_button_codes[fd]
                    else:
                        button_codes = default_button_codes
                    if process_event(event):
                        js_last[i] = time.time()
            elif event == False:
                close_fds(js_fds)
                js_fds = []
                break
            i += 1

    if time.time() - rescan_time > 2:
        rescan_time = time.time()
        if cmp(js_devs, get_devices()):
            close_fds(js_fds)
            js_fds = []

    time.sleep(0.01)
