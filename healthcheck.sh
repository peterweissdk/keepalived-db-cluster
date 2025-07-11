#!/bin/sh
set -e

# Check if keepalived process is running
if ! pgrep keepalived >/dev/null; then
    echo "Keepalived process is not running"
    exit 1
fi

# Verify VIRTUAL_IPS environment variable is set
if [ -z "$VIRTUAL_IPS" ]; then
    echo "VIRTUAL_IPS environment variable is not set"
    exit 1
fi

echo "Keepalived is healthy"
exit 0
