#!/bin/bash

export SES=$$
export REAL_DIR="$(dirname "$(readlink -f "$0")")"
conf_path="$DIR"/../config/lf-conf

# launch kakoune session
SES=$SES kak -s $SES -d 2&> /dev/null &

# laiunch sub windows
kitty @ set-window-title "editor-$SESS"
SES=$SES kitty @ launch --title "terminal-$SES"
SES=$SES kitty @ launch --title "hover_buf-$SES" kak -c $SES -e 'rename-client hover_buf;e -scratch *hover*'

# lmove the terminal to the right workspace.
i3-msg move container to workspace 2:Editor
i3-msg workspace 2:Editor

# start lf with our custom config.
lf -config $conf_path

