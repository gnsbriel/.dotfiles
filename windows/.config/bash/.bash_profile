# shellcheck shell=bash

# .bashrc Location
source "${HOME}"/.dotfiles/windows/.config/bash/.bashrc

# ".bash_history" file location
HIST_FILE="${HOME}/.dotfiles/windows/.config/bash/.bash_history"
[ ! -f "${HIST_FILE}" ] && touch "${HIST_FILE}"
export HISTFILE="${HIST_FILE}"

# Path
export PATH="${PATH}":~/bin/

# Less
export LESSHISTFILE="${HOME}/.dotfiles/windows/.config/less/.lesshst"

# Wget
export WGETRC="${HOME}/.dotfiles/windows/.config/wget/.wgetrc"
