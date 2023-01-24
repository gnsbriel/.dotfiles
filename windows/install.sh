#!/bin/bash

#Section: ----- Global Variables -----

readonly param="${1}"

# Colors
readonly cyan='\033[0;36m'        # Title;
readonly red='\033[0;31m'         # Error;
readonly yellow='\033[1;33m'      # Warning;
readonly purple='\033[0;35m'      # Alert;
readonly blue='\033[0;34m'        # Attention;
readonly light_gray='\033[0;37m'  # Option;
readonly green='\033[0;32m'       # Done;
readonly reset='\033[0m'          # No color, end of sentence;

# %b - Print the argument while expanding backslash escape sequences.
# %q - Print the argument shell-quoted, reusable as input.
# %d, %i - Print the argument as a signed decimal integer.
# %s - Print the argument as a string.

#Syntax:
#    printf "'%b' 'TEXT' '%s' '%b'\n" "${COLOR}" "${VAR}" "${reset}"

#Section: ----- General Functions -----

function timer() {
    if [ "${#}" == "" ]; then
        printf "%bIncorrect use of 'timer' Function !%b\nSyntax:\vtimer_ 'PHRASE';%b\n" "${purple}" "${light_gray}" "${reset}" 1>&2 ;
        exit 2 ;
    fi

    for run in {10..0}; do
        clear; printf "%b%s%b\nContinuing in: %ss%b\n" "${blue}" "${*}" "${light_gray}" "${run}" "${reset}" ; sleep 1 ;
    done
}

function mkfile() {
    if [ "${#}" -ne "1" ]; then
        printf "%bIncorrect use of 'mkfile' Function !%b\nSyntax:\vmkfile [PATH]... ;%b" "${red}" "${light_gray}" "${reset}" 1>&2 ;
        exit 2 ;
    fi

    # Create File and Folder if needed
    mkdir --parents --verbose "$(dirname "${1}")" && touch "${1}" || exit 2 ;
}

#Section: ----- Setup config files -----

# Setup "Bash"
printf "%bSetting up \"Bash\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}"/.bashrc
rm --force "${HOME}"/.bash_profile
rm --force "${HOME}"/.bash_history
rm --force "${HOME}"/.bash_logout
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_profile "${HOME}"

# Setup "Git"
printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}"/.gitconfig
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/git/config "${HOME}"/.gitconfig

# Setup "VSCode"
printf "%bSetting up \"VSCode\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${APPDATA}"/Code/User/snippets
rm --force "${APPDATA}"/Code/User/settings.json
rm --force "${APPDATA}"/Code/User/keybindings.json
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/snippets "${APPDATA}"/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/settings.json "${APPDATA}"/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/keybindings.json "${APPDATA}"/Code/User

# Wget
printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.wgetrc "
rm --force "${HOME}/.wget-hsts"
mkfile "${PWD}/.config/wget/.wget-hsts"
mkfile "${PWD}/.config/wget/.wgetrc"

# Less
printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.lesshst"
mkfile "${PWD}/.config/less/.lesshst"
