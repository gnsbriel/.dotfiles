# shellcheck shell=bash

# .bashrc Location
source "${HOME}"/.config/bash/.bashrc

# Path
export PATH="${PATH}":~/.local/bin/

# Kvantum
export QT_STYLE_OVERRIDE=kvantum
export GTK2_RC_FILES="${HOME}"/.config/gtk-2.0/gtkrc-2.0

# Less
export LESSHISTFILE="${HOME}"/.config/less/.lesshst

# Wget
export WGETRC="${HOME}"/.config/wget/.wgetrc
