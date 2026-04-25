#!/bin/bash
# Stop overshoot dev servers started by dev-start.sh.

PIDFILE=".dev-pids"

if [ ! -f "$PIDFILE" ]; then
    echo "No PID file found. Trying to kill by process name..."
    pkill -f "overshoot serve" 2>/dev/null && echo "Killed backend." || echo "No backend found."
    pkill -f "vite" 2>/dev/null && echo "Killed frontend." || echo "No frontend found."
    exit 0
fi

while read -r pid; do
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null
        echo "Stopped PID $pid"
    fi
done < "$PIDFILE"

rm -f "$PIDFILE"
echo "Dev servers stopped."
