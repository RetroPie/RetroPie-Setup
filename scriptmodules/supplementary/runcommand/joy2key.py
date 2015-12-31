#!/usr/bin/python

import sys, struct, time, fcntl, termios, signal

#    struct js_event {
#        __u32 time;     /* event timestamp in milliseconds */
#        __s16 value;    /* value */
#        __u8 type;      /* event type */
#        __u8 number;    /* axis/button number */
#    };

JS_MIN = -32768
JS_MAX = 32768
JS_REP = 0.15

JS_THRESH = 0.75

JS_EVENT_BUTTON = 0x01
JS_EVENT_AXIS = 0x02
JS_EVENT_INIT = 0x80

def signal_handler(signum, frame):
    if js_fd:
        js_fd.close()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

button_codes = []
axis_codes = []

i = 0
for arg in sys.argv[2:]:
    if i < 4:
        axis_codes.append(arg)
    else:
        button_codes.append(arg)
    i += 1

event_format = 'IhBB'
event_size = struct.calcsize(event_format)

tty_fd = open("/dev/tty", "w")
js_fd = open(sys.argv[1], "rb")

buttons_state = 0
last_press = 0
while True:
    try:
        event = js_fd.read(event_size)
    except:
        break

    if time.time() - last_press < JS_REP:
        continue

    (js_time, js_value, js_type, js_number) = struct.unpack(event_format, event)

    # ignore init events
    if js_type & JS_EVENT_INIT:
        continue

    hex_chars = ""

    if js_type == JS_EVENT_BUTTON:
        if js_number < len(button_codes) and js_value == 1:
            hex_chars = button_codes[js_number]
    
    if js_type == JS_EVENT_AXIS:
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
        last_press = time.time()
        for c in hex_chars.decode('hex'):
            fcntl.ioctl(tty_fd, termios.TIOCSTI, c)
