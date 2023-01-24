# shellcheck shell=bash

# .bashrc Location
source "${HOME}"/.dotfiles/.config/bash/.bashrc

# ".bash_history" file location
HIST_FILE="${HOME}/.dotfiles/.config/bash/.bash_history"
if [ ! -f "${HIST_FILE}" ]; then touch "${HIST_FILE}"; fi
export HISTFILE="${HIST_FILE}"

# Path
export PATH="${PATH}":~/bin/

# Less
export LESSHISTFILE="${HOME}/.dotfiles/.config/less/.lesshst"

# Wget
export WGETRC="${HOME}/.dotfiles/.config/wget/.wgetrc"
