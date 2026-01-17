PID_FILE=/dev/shm/rp-splashscreen.pid
if [ "`tty`" = "/dev/tty1" ] && [ -z "$DISPLAY" ] && [ -f "$PID_FILE" ]; then
    PID=`cat $PID_FILE`
    if ps -p $PID >/dev/null; then
        kill $PID >/dev/null 2>&1
    fi
    rm $PID_FILE
fi
