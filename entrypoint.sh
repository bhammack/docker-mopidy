#!/bin/bash

# if [ -z "$PULSE_COOKIE_DATA" ]
# then
#     echo -ne $(echo $PULSE_COOKIE_DATA | sed -e 's/../\\x&/g') >$HOME/pulse.cookie
#     export PULSE_COOKIE=$HOME/pulse.cookie
# fi

echo "Running as $(id -u):$(id -g) $(id -un):$(id -gn)"

# groupmod -g $PGID audio
# usermod -u $PUID -g $PGID mopidy

# echo "Now running as $(id -u):$(id -g) $(id -un):$(id -gn)"

exec "$@"
