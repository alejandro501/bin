#!/bin/bash

# Start Tor if it’s not running
if ! pgrep -x "tor" >/dev/null; then
    echo "Starting Tor..."
    tor &
    sleep 5
    if pgrep -x "tor" >/dev/null; then
        echo "Tor started successfully."
    else
        echo "Failed to start Tor. Please check your installation."
        exit 1
    fi
else
    echo "Tor is already running."
fi

# Check if torsocks is installed
if ! command -v torsocks &> /dev/null; then
    echo "torsocks is not installed. Please install it to proceed."
    exit 1
fi
