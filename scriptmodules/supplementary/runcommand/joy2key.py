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
import curses, errno


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

button_codes = []
axis_codes = []

curses.setupterm()

i = 0
for arg in sys.argv[2:]:
    chars = get_hex_chars(arg)
    if i < 4:
        axis_codes.append(chars)
    else:
        button_codes.append(chars)
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