#!/bin/bash

# Change directory to the script's location
cd "$(dirname "$0")" || exit
killall conky
# Wait for a short period to ensure conky processes are terminated
sleep 1

# Start conky with the specified configuration file
( set -x; setsid conky -c conky-BG.conf )

# Wait for a short period to ensure conky starts properly
sleep 1

( set -x; setsid conky -c conky-clock.conf )

exit