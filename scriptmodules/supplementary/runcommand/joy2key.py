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

def sysdev_get(key, sysdev_path):
    value = ''
    for line in open(sysdev_path + key, 'r'):
        value = line.rstrip('\n')
        break
    return value

def get_button_codes(dev_path):
    js_cfg_dir = CONFIG_DIR + 'all/retroarch-joypads/'
    js_cfg = ''
    dev_name = ''
    dev_button_codes = list(default_button_codes)

    for device in Context().list_devices(DEVNAME=dev_path):
        sysdev_path = os.path.normpath('/sys' + device.get('DEVPATH')) + '/'
        if not os.path.isfile(sysdev_path + 'name'):
            sysdev_path = os.path.normpath(sysdev_path + '/../') + '/'
        # getting joystick name
        dev_name = sysdev_get('name', sysdev_path)
        # getting joystick vendor ID
        dev_vendor_id = int(sysdev_get('id/vendor', sysdev_path), 16)
        # getting joystick product ID
        dev_product_id = int(sysdev_get('id/product', sysdev_path), 16)
    if not dev_name:
        return dev_button_codes

    # getting retroarch config file for joystick
    for f in os.listdir(js_cfg_dir):
        if f.endswith('.cfg'):
            input_device = ini_get('input_device', js_cfg_dir + f)
            input_vendor_id = ini_get('input_vendor_id', js_cfg_dir + f)
            input_product_id = ini_get('input_product_id', js_cfg_dir + f)
            if (input_device == dev_name and
               (input_vendor_id  == '' or int(input_vendor_id)  == dev_vendor_id) and
               (input_product_id == '' or int(input_product_id) == dev_product_id)):
                js_cfg = js_cfg_dir + f
                break
    if not js_cfg:
        js_cfg = RETROARCH_CFG

    # getting configs for dpad, buttons A, B, X and Y
    btn_map = [ 'left', 'right', 'up', 'down', 'a', 'b', 'x', 'y' ]
    btn_num = {}
    biggest_num = 0
    i = 0
    for btn in list(btn_map):
        if i >= len(dev_button_codes):
            break
        try:
            btn_num[btn] = int(get_btn_num(btn, js_cfg))
        except ValueError:
            btn_map.pop(i)
            dev_button_codes.pop(i)
            btn_num.pop(btn, None)
            continue
        if btn_num[btn] > biggest_num:
            biggest_num = btn_num[btn]
        i += 1

    # building the button codes list
    btn_codes = [''] * (biggest_num + 1)
    i = 0
    for btn in btn_map:
        if i >= len(dev_button_codes):
            break
        btn_codes[btn_num[btn]] = dev_button_codes[i]
        i += 1
    try:
        # if button A is <enter> and menu_swap_ok_cancel_buttons is true, swap buttons A and B functions
        if (ini_get('menu_swap_ok_cancel_buttons', RETROARCH_CFG) == 'true' and
           'a' in btn_num and 'b' in btn_num and btn_codes[btn_num['a']] == '\n'):
            btn_codes[btn_num['a']] = btn_codes[btn_num['b']]
            btn_codes[btn_num['b']] = '\n'
    except (IOError, ValueError):
        pass

    return btn_codes

def signal_handler(signum, frame):
    signal.signal(signal.SIGINT, signal.SIG_IGN)
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    if (js_fds):
        close_fds(js_fds)
    if (tty_fd):
        tty_fd.close()
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
        except (OSError, ValueError):
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

js_fds = []
tty_fd = []

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

# daemonize when signal handlers are registered
if os.fork():
    os._exit(0)

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

    default_button_codes.append(chars)
    i += 1

event_format = 'IhBB'
event_size = struct.calcsize(event_format)

try:
    tty_fd = open('/dev/tty', 'a')
except IOError:
    print 'Unable to open /dev/tty'
    sys.exit(1)

rescan_time = time.time()
while True:
    do_sleep = True
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
                do_sleep = False
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

    if do_sleep:
        time.sleep(0.01)
