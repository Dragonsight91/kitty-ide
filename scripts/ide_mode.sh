#!/bin/bash

# set env
export SES=$$

conf_path=~/ide/config/lf-conf

# launch kakoune session
SES=$SES kak -s $SES -d 2&> /dev/null &

# laiunch sub windows
kitty @ set-window-title "editor-$SESS"
SES=$SES kitty @ launch --title "terminal-$SES"
SES=$SES kitty @ launch --title "hover_buf-$SES" kak -c $SES -e 'rename-client hover_buf;e -scratch *hover*'

i3-msg move container to workspace 2:Editor
i3-msg workspace 2:Editor
lf -config $conf_path
