#!/bin/bash

# Caffeine Toggle Script - Gentle Activity Simulation
# Usage: caffeine-toggle.sh [on|off|status]

PIDFILE="/tmp/caffeine-panel.pid"
LOCKFILE="/tmp/caffeine-panel.lock"

simulate_activity() {
    while [ -f "$LOCKFILE" ]; do
        # Method: Touch the X11 server to show activity (completely non-intrusive)
        xset q > /dev/null 2>&1
        
        # Wait 3 minutes before next activity simulation
        sleep 180
    done
}

case "$1" in
    "on")
        if [ -f "$PIDFILE" ]; then
            echo "Caffeine is already active"
            exit 0
        fi
        
        echo "Enabling caffeine to prevent system suspension..."
        
        # Create lock file first
        touch "$LOCKFILE"
        
        # Start activity simulation in background
        simulate_activity &
        ACTIVITY_PID=$!
        echo $ACTIVITY_PID > "$PIDFILE"
        
        # Also disable screen saver gently
        xset s noblank
        xset s 0 0  # Disable screen saver timeout
        
        # Send notification
        notify-send "Caffeine Enabled" "System suspension blocked" -i caffeine
        
        echo "Caffeine enabled - system suspension blocked (PID: $ACTIVITY_PID)"
        ;;
        
    "off")
        if [ ! -f "$LOCKFILE" ]; then
            echo "Caffeine is not active"
            exit 0
        fi
        
        echo "Disabling caffeine to allow system suspension..."
        
        # Remove lock file to stop activity simulation
        rm -f "$LOCKFILE"
        
        # Wait a moment for the loop to detect the file removal
        sleep 2
        
        # Gently stop the activity process if still running
        if [ -f "$PIDFILE" ]; then
            PID=$(cat "$PIDFILE")
            if ps -p $PID > /dev/null; then
                kill $PID 2>/dev/null
            fi
            rm "$PIDFILE"
        fi
        
        # Restore screen saver to system default (usually 10 minutes)
        xset s blank
        xset s 600 600  # 10 minutes
        
        # Send notification
        notify-send "Caffeine Disabled" "System can suspend normally" -i caffeine
        
        echo "Caffeine disabled - system can suspend normally"
        ;;
        
    "status")
        if [ -f "$LOCKFILE" ] && [ -f "$PIDFILE" ]; then
            PID=$(cat "$PIDFILE")
            if ps -p $PID > /dev/null; then
                echo "on"
            else
                echo "off"
            fi
        else
            echo "off"
        fi
        ;;
        
    *)
        echo "Usage: $0 [on|off|status]"
        echo "  on     - Enable caffeine (simulate user activity)"
        echo "  off    - Disable caffeine (stop activity simulation)"
        echo "  status - Check current status"
        exit 1
        ;;
esac