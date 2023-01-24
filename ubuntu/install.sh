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

#Section: ----- Setup Config Files -----

# Setup ".config"
mkdir --parents --verbose "${HOME}"/.config

# Setup "bin"
printf "%bSetting up \"bin\"...%b\n" "${yellow}" "${reset}"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.local/bin/* "${HOME}"/.local/bin

# Setup "Bash"
printf "%bSetting up \"bash\"...%b\n" "${yellow}" "${reset}"
rm --force --verbose "${HOME}"/.bashrc ;
rm --force --verbose "${HOME}"/.bash_profile ;
rm --force --verbose "${HOME}"/.bash_history ;
rm --force --verbose "${HOME}"/.bash_logout ;
rm --force --verbose "${HOME}"/.profile ;
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash "${HOME}"/.config
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_profile "${HOME}"/.profile
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_logout "${HOME}"

# Setup "Git"
printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}"/.gitconfig
rm --force --recursive "${HOME}"/.config/git
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/git "${HOME}"/.config

# Setup GTK
printf "%bSetting up \"GTK\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/gtk-3.0
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/gtk-3.0 "${HOME}"/.config
if git status --porcelain | grep -q bookmarks; then
    rm --force "${PWD}"/.config/gtk-3.0/bookmarks
    git restore "${PWD}"/.config/gtk-3.0/bookmarks
fi
git update-index --skip-worktree "${PWD}"/.config/gtk-3.0/bookmarks
{
    printf "file:///home/%s/Projects\n" "${USER}";
    printf "file:///home/%s/Repositories\n" "${USER}";
    printf "file:///home/%s/Video%%20Games\n" "${USER}";
    printf "file:///home/%s/Virtual%%20Machine\n" "${USER}";
    printf "file:///home/%s/.config .Config\n" "${USER}";
    printf "file:///home/%s/.dotfiles .Dotfiles\n" "${USER}";
    printf "file:///home/%s/Documents\n" "${USER}";
    printf "file:///home/%s/Music\n" "${USER}";
    printf "file:///home/%s/Pictures\n" "${USER}";
    printf "file:///home/%s/Videos\n" "${USER}";
    printf "file:///home/%s/Downloads\n" "${USER}";
} | tee "${PWD}/.config/gtk-3.0/bookmarks" > /dev/null 2>&1 ;
sed --expression "s/CURRENTUSERNAME/${USER}/g" --in-place "${PWD}"/.config/gtk-3.0/bookmarks

# Setup "Flameshot"
printf "%bSetting up \"Flameshot\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/flameshot
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/flameshot "${HOME}"/.config
if git status --porcelain | grep -q flameshot.ini; then
    rm --force "${PWD}"/.config/flameshot/flameshot.ini
    git restore "${PWD}"/.config/flameshot/flameshot.ini
fi
git update-index --skip-worktree "${PWD}"/.config/flameshot/flameshot.ini
sed --expression "s/CURRENTUSERNAME/${USER}/g" --in-place "${PWD}"/.config/flameshot/flameshot.ini
sed --expression "s/Media\/Screenshots/Pictures\/Screenshots/g" --in-place "${PWD}"/.config/flameshot/flameshot.ini

# Setup "VSCode"
printf "%bSetting up \"VSCode\"...%b\n" "${yellow}" "${reset}"
mkdir --parents --verbose "${HOME}"/.config/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/snippets "${HOME}"/.config/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/settings.json "${HOME}"/.config/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/keybindings.json "${HOME}"/.config/Code/User

# Wget
printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.wgetrc "
rm --force "${HOME}/.wget-hsts"
mkfile "${PWD}/.config/wget/.wget-hsts"
mkfile "${PWD}/.config/wget/.wgetrc"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/wget "${HOME}"/.config

# Less
printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.lesshst"
mkfile "${PWD}/.config/less/.lesshst"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/less "${HOME}"/.config

# Keyboard Layouts
printf "%bSetting up \"Keyboard Layouts\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.XCompose"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.XCompose "${HOME}"

# Binaural audio with OpenAL
printf "%bSetting up \"OpenAl\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.alsoftrc"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.alsoftrc "${HOME}"
