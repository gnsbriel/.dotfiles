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
rm --force --recursive "${HOME}"/.local/bin
ln --force --no-dereference --symbolic --verbose "${PWD}"/.local/bin "${HOME}"/.local

# Setup "Bash"
printf "%bSetting up \"bash\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}"/.bashrc
rm --force "${HOME}"/.bash_profile
rm --force "${HOME}"/.bash_history
rm --force "${HOME}"/.bash_logout
sed --expression 's/#export QT_STYLE_OVERRIDE=kvantum/export QT_STYLE_OVERRIDE=kvantum/g' --in-place "${PWD}"/.config/bash/.bash_profile
sed --expression 's/#export GTK2_RC_FILES=\"${HOME}\"\/.config\/gtk-2.0\/gtkrc-2.0/export GTK2_RC_FILES=\"${HOME}\"\/.config\/gtk-2.0\/gtkrc-2.0/g' --in-place "${PWD}"/.config/bash/.bash_profile
{
    printf "\nif ! groups \"\${USER}\" | grep -q i2c; then" ;
    printf "\n    printf \"\\\n Consider adding \\\\\"%%s\\\\\" to \\\\\"i2c\\\\\" group.\\\n     $ sudo usermod --append --groups i2c %%s \\\n\" \"\${USER}\" \"\${USER}\" ;" ;
    printf "\nfi\n"
} | tee --append "${PWD}/.config/bash/.bashrc" > /dev/null 2>&1 ;
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash "${HOME}"/.config
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_profile "${HOME}"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_logout "${HOME}"

# Setup "Alacritty"
printf "%bSetting up \"Alacritty\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/alacritty
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/alacritty "${HOME}"/.config

# Setup "Btop"
printf "%bSetting up \"Btop\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/btop
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/btop "${HOME}"/.config

# Setup "Dunst"
printf "%bSetting up \"Dunst\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/dunst
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/dunst "${HOME}"/.config

# Setup "Git"
printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}"/.gitconfig
rm --force --recursive "${HOME}"/.config/git
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/git "${HOME}"/.config

# Setup "Picom"
printf "%bSetting up \"Picom\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/picom
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/picom "${HOME}"/.config

# Setup "Qtile"
printf "%bSetting up \"Qtile\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/qtile
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/qtile "${HOME}"/.config

# Setup "Rofi"
printf "%bSetting up \"Rofi\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/rofi
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/rofi "${HOME}"/.config

# Setup "Kvantum"
printf "%bSetting up \"Kvantum\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/Kvantum
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Kvantum "${HOME}"/.config

# Setup "Lxappearane"
printf "%bSetting up \"Lxappearane\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/gtk-2.0
rm --force --recursive "${HOME}"/.config/gtk-3.0
rm --force --recursive "${HOME}"/.config/gtk-4.0
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/gtk-2.0 "${HOME}"/.config
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/gtk-3.0 "${HOME}"/.config
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/gtk-4.0 "${HOME}"/.config
if git status --porcelain | grep -q bookmarks; then
    rm --force "${PWD}"/.config/gtk-3.0/bookmarks
    git restore "${PWD}"/.config/gtk-3.0/bookmarks
fi
git update-index --skip-worktree "${PWD}"/.config/gtk-3.0/bookmarks
sed --expression "s/CURRENTUSERNAME/$USER/g" --in-place "${PWD}"/.config/gtk-3.0/bookmarks

# Setup "Flameshot"
printf "%bSetting up \"Flameshot\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/flameshot
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/flameshot "${HOME}"/.config
if git status --porcelain | grep -q flameshot.ini; then
    rm --force "${PWD}"/.config/flameshot/flameshot.ini
    git restore "${PWD}"/.config/flameshot/flameshot.ini
fi
git update-index --skip-worktree "${PWD}"/.config/flameshot/flameshot.ini
sed --expression "s/CURRENTUSERNAME/$USER/g" --in-place "${PWD}"/.config/flameshot/flameshot.ini

# Setup "Volumeicon"
printf "%bSetting up \"Volumeicon\"...%b\n" "${yellow}" "${reset}"
rm --force --recursive "${HOME}"/.config/volumeicon
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/volumeicon "${HOME}"/.config

# Setup "VSCode"
printf "%bSetting up \"VSCode\"...%b\n" "${yellow}" "${reset}"
mkdir --parents --verbose "${HOME}"/.config/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/snippets "${HOME}"/.config/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/settings.json "${HOME}"/.config/Code/User
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Code/User/keybindings.json "${HOME}"/.config/Code/User

# Setup "Thunar"
printf "%bSetting up \"Thunar\"...%b\n" "${yellow}" "${reset}"
mkdir --parents --verbose "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir --parents --verbose "${HOME}"/.config/Thunar
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/Thunar/uca.xml "${HOME}"/.config/Thunar
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml

# Setup "Pluma"
printf "%bSetting up \"Pluma\"...%b\n" "${yellow}" "${reset}"
mkdir --parents --verbose "${HOME}"/.config/pluma/styles
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/pluma/styles/arc-dark.xml "${HOME}"/.config/pluma/styles

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

# MIME Types
printf "%bSetting up \"MIME Types\"...%b\n" "${yellow}" "${reset}"
rm --force  "${PWD}/.config/mimeapps.list"
rm --force  "${HOME}/.local/share/applications/mimeapps.list"
mkdir --parents --verbose "${HOME}/.local/share/applications"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/mimeapps.list "${HOME}"/.config
ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/mimeapps.list "${HOME}"/.local/share/applications

# Keyboard Layouts
printf "%bSetting up \"Keyboard Layouts\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.XCompose"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.XCompose "${HOME}"

# Binaural audio with OpenAL
printf "%bSetting up \"OpenAl\"...%b\n" "${yellow}" "${reset}"
rm --force "${HOME}/.alsoftrc"
ln --force --no-dereference --symbolic --verbose "${PWD}"/.alsoftrc "${HOME}"
