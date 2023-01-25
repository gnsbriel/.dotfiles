#!/bin/bash

############################################################
# Colors                                                   #
############################################################

readonly cyan='\033[0;36m'        # Title
readonly red='\033[0;31m'         # Error
readonly yellow='\033[1;33m'      # Warning
readonly purple='\033[0;35m'      # Alert
readonly blue='\033[0;34m'        # Attention
readonly light_gray='\033[0;37m'  # Option
readonly green='\033[0;32m'       # Done
readonly reset='\033[0m'          # No color, end of sentence

# %b - Print the argument while expanding backslash escape sequences.
# %q - Print the argument shell-quoted, reusable as input.
# %d, %i - Print the argument as a signed decimal integer.
# %s - Print the argument as a string.

#Syntax:
#    printf "'%b' 'TEXT' '%s' '%b'\n" "${color}" "${var}" "${reset}"

############################################################
# Help                                                     #
############################################################

function Help() {

   # Display Help
   echo ""
   echo "Syntax: ./install.sh [OPTION..]"
   echo ""
   echo "Options:"
   echo "-h, --help       Print this help message."
   echo ""
   echo "-a, --arch       Current operational system (Arch Linux)."
   echo "-u, --ubuntu     Current operational system (Ubuntu-based Distro)."
   echo "-wsl, --wsl      Current operational system (Windows Subsystem for Linux)."
   echo "-w, --windows    Current operational system (Windows)."
   echo ""

}

############################################################
# Main program                                             #
############################################################

#Section: "Functions"

function timer() {

    if [ "${#}" == "" ]; then
        printf "%bIncorrect use of 'timer' Function !%b\nSyntax:\vtimer 'PHRASE';%b\n" "${purple}" "${light_gray}" "${reset}" 1>&2
        exit 2
    fi

    printf "%b%s%b\n" "${blue}" "${*}" "${reset}"
    local duration=5  # In seconds
    while [ ! "${duration}" == 0 ]; do
        printf "%bContinuing in: %s%b\r" "${light_gray}" "${duration}" "${reset}"
        ((--duration))
        sleep 1
    done
    printf "\n"

}

function mkfile() {

    if [ "${#}" -ne "1" ]; then
        printf "%bIncorrect use of 'mkfile' Function !%b\nSyntax:\vmkfile [PATH]... ;%b" "${red}" "${light_gray}" "${reset}" 1>&2
        exit 2
    fi

    # Create File and Folder if needed
    mkdir --parents --verbose "$(dirname "${1}")" && touch "${1}" || exit 2

}


function mkbackup() {

    if [ ! -d "${PWD}"/.Backup ]; then mkdir "${PWD}"/.Backup; fi

    case "${1}" in
        -f | --file )
            shift
            if [ ! -f "${PWD}"/.Backup/"${1##*/}" ]; then
                cp --verbose "${1}" "${PWD}"/.Backup/ && printf "%bFile '%s' successfully backed-up !%b\n" "${green}" "${1##*/}" "${reset}" || printf "%bCould not backup '%s' !%b\n" "${red}" "${1##*/}" "${reset}"
            fi
            ;;
        -d | --directory )
            shift
            if [ ! -d "${PWD}"/.Backup/"${1##*/}" ]; then
                cp --verbose --recursive "${1}" "${PWD}"/.Backup/ && printf "%bDirectory '%s' successfully backed-up !%b\n" "${green}" "${1##*/}" "${reset}" || printf "%b could not backup '%s' !%b\n" "${red}" "${1##*/}" "${reset}"
            fi
            ;;
        * )
            echo ""
            echo "Syntax: mkbackup [OPTION..] [PATH..]"
            echo ""
            echo "Options:"
            echo "-f, --file"
            echo "-d, --directory"
            exit 0
            ;;
    esac

}

#Section: "--arch"

function install-dotfiles-arch() {

    # Setup ".config"
    printf "%bSetting up \".config\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.config

    # Setup "bin"
    printf "%bSetting up \"bin\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.local/bin
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.local/bin/* "${HOME}"/.local/bin

    # Setup "Bash"
    printf "%bSetting up \"bash\"...%b\n" "${yellow}" "${reset}"
    mkbackup -f "${HOME}"/.bashrc       && rm --force "${HOME}"/.bashrc
    mkbackup -f "${HOME}"/.bash_profile && rm --force "${HOME}"/.bash_profile
    rm --force --verbose "${HOME}"/.bash_history ;
    mkbackup -f "${HOME}"/.bash_logout  && rm --force "${HOME}"/.bash_logout
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/bash "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/bash/.bash_profile "${HOME}"
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/bash/.bash_logout "${HOME}"

    # Setup "Alacritty"
    printf "%bSetting up \"Alacritty\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/alacritty
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/alacritty "${HOME}"/.config

    # Setup "Btop"
    printf "%bSetting up \"Btop\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/btop
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/btop "${HOME}"/.config

    # Setup "Dunst"
    printf "%bSetting up \"Dunst\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/dunst
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/dunst "${HOME}"/.config

    # Setup "Git"
    printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.gitconfig
    rm --force --recursive "${HOME}"/.config/git
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/git "${HOME}"/.config

    # Setup "Picom"
    printf "%bSetting up \"Picom\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/picom
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/picom "${HOME}"/.config

    # Setup "Qtile"
    printf "%bSetting up \"Qtile\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/qtile
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/qtile "${HOME}"/.config

    # Setup "Rofi"
    printf "%bSetting up \"Rofi\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/rofi
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/rofi "${HOME}"/.config

    # Setup "Kvantum"
    printf "%bSetting up \"Kvantum\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/Kvantum
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/Kvantum "${HOME}"/.config

    # Setup "Lxappearane"
    printf "%bSetting up \"Lxappearane\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/gtk-2.0
    rm --force --recursive "${HOME}"/.config/gtk-3.0
    rm --force --recursive "${HOME}"/.config/gtk-4.0
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/gtk-2.0 "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/gtk-3.0 "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/gtk-4.0 "${HOME}"/.config
    if git status --porcelain | grep -q bookmarks; then
        rm --force "${PWD}"/arch/.config/gtk-3.0/bookmarks
        git restore "${PWD}"/arch/.config/gtk-3.0/bookmarks
    fi
    git update-index --skip-worktree "${PWD}"/arch/.config/gtk-3.0/bookmarks
    sed --expression "s/CURRENTUSERNAME/$USER/g" --in-place "${PWD}"/arch/.config/gtk-3.0/bookmarks

    # Setup "Flameshot"
    printf "%bSetting up \"Flameshot\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/flameshot
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/flameshot "${HOME}"/.config
    if git status --porcelain | grep -q flameshot.ini; then
        rm --force "${PWD}"/arch/.config/flameshot/flameshot.ini
        git restore "${PWD}"/arch/.config/flameshot/flameshot.ini
    fi
    git update-index --skip-worktree "${PWD}"/arch/.config/flameshot/flameshot.ini
    sed --expression "s/CURRENTUSERNAME/$USER/g" --in-place "${PWD}"/arch/.config/flameshot/flameshot.ini

    # Setup "Volumeicon"
    printf "%bSetting up \"Volumeicon\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/volumeicon
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/volumeicon "${HOME}"/.config

    # Setup "VSCode"
    printf "%bSetting up \"VSCode\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.config/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/Code/User/snippets "${HOME}"/.config/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/Code/User/settings.json "${HOME}"/.config/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/Code/User/keybindings.json "${HOME}"/.config/Code/User

    # Setup "Thunar"
    printf "%bSetting up \"Thunar\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml
    mkdir --parents --verbose "${HOME}"/.config/Thunar
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/Thunar/uca.xml "${HOME}"/.config/Thunar
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml

    # Setup "Pluma"
    printf "%bSetting up \"Pluma\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.config/pluma/styles
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/pluma/styles/arc-dark.xml "${HOME}"/.config/pluma/styles

    # Wget
    printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.wgetrc
    rm --force "${HOME}"/.wget-hsts
    mkfile "${PWD}"/arch/.config/wget/.wget-hsts
    mkfile "${PWD}"/arch/.config/wget/.wgetrc
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/wget "${HOME}"/.config

    # Less
    printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.lesshst
    mkfile "${PWD}"/arch/.config/less/.lesshst
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/less "${HOME}"/.config

    # MIME Types
    printf "%bSetting up \"MIME Types\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.config/mimeapps.list
    rm --force "${HOME}"/.local/share/applications/mimeapps.list
    mkdir --parents --verbose "${HOME}"/.local/share/applications
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/mimeapps.list "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.config/mimeapps.list "${HOME}"/.local/share/applications

    # Keyboard Layouts
    printf "%bSetting up \"Keyboard Layouts\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.XCompose
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.XCompose "${HOME}"

    # Binaural audio with OpenAL
    printf "%bSetting up \"OpenAl\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.alsoftrc
    ln --force --no-dereference --symbolic --verbose "${PWD}"/arch/.alsoftrc "${HOME}"

}

#Section: "--ubuntu"

function install-dotfiles-ubuntu() {

    # Setup ".config"
    printf "%bSetting up \".config\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.config

    # Setup "bin"
    printf "%bSetting up \"bin\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.local/bin
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.local/bin/* "${HOME}"/.local/bin

    # Setup "Bash"
    printf "%bSetting up \"bash\"...%b\n" "${yellow}" "${reset}"
    mkbackup -f "${HOME}"/.bashrc        && rm --force --verbose "${HOME}"/.bashrc ;
    mkbackup -f "${HOME}"/.bash_profile  && rm --force --verbose "${HOME}"/.bash_profile ;
    mkbackup -f "${HOME}"/.bash_logout   && rm --force --verbose "${HOME}"/.bash_logout ;
    rm --force --verbose "${HOME}"/.bash_history ;
    mkbackup -f "${HOME}"/.profile       && rm --force --verbose "${HOME}"/.profile ;
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/bash "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/bash/.bash_profile "${HOME}"/.profile
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/bash/.bash_logout "${HOME}"

    # Setup "Git"
    printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.gitconfig
    rm --force --recursive "${HOME}"/.config/git
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/git "${HOME}"/.config

    # Setup GTK
    printf "%bSetting up \"GTK\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/gtk-3.0
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/gtk-3.0 "${HOME}"/.config
    if git status --porcelain | grep -q bookmarks; then
        rm --force "${PWD}"/ubuntu/.config/gtk-3.0/bookmarks
        git restore "${PWD}"/ubuntu/.config/gtk-3.0/bookmarks
    fi
    git update-index --skip-worktree "${PWD}"/ubuntu/.config/gtk-3.0/bookmarks
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
    } | tee "${PWD}"/ubuntu/.config/gtk-3.0/bookmarks > /dev/null 2>&1 ;
    sed --expression "s/CURRENTUSERNAME/${USER}/g" --in-place "${PWD}"/ubuntu/.config/gtk-3.0/bookmarks

    # Setup "Flameshot"
    printf "%bSetting up \"Flameshot\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${HOME}"/.config/flameshot
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/flameshot "${HOME}"/.config
    if git status --porcelain | grep -q flameshot.ini; then
        rm --force "${PWD}"/ubuntu/.config/flameshot/flameshot.ini
        git restore "${PWD}"/ubuntu/.config/flameshot/flameshot.ini
    fi
    git update-index --skip-worktree "${PWD}"/ubuntu/.config/flameshot/flameshot.ini
    sed --expression "s/CURRENTUSERNAME/${USER}/g" --in-place "${PWD}"/ubuntu/.config/flameshot/flameshot.ini
    sed --expression "s/Media\/Screenshots/Pictures\/Screenshots/g" --in-place "${PWD}"/ubuntu/.config/flameshot/flameshot.ini

    # Setup "VSCode"
    printf "%bSetting up \"VSCode\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.config/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/Code/User/snippets "${HOME}"/.config/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/Code/User/settings.json "${HOME}"/.config/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/Code/User/keybindings.json "${HOME}"/.config/Code/User

    # Wget
    printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.wgetrc
    rm --force "${HOME}"/.wget-hsts
    mkfile "${PWD}"/ubuntu.config/wget/.wget-hsts
    mkfile "${PWD}"/ubuntu.config/wget/.wgetrc
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/wget "${HOME}"/.config

    # Less
    printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.lesshst
    mkfile "${PWD}"/ubuntu.config/less/.lesshst
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.config/less "${HOME}"/.config

    # Keyboard Layouts
    printf "%bSetting up \"Keyboard Layouts\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.XCompose
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.XCompose "${HOME}"

    # Binaural audio with OpenAL
    printf "%bSetting up \"OpenAl\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.alsoftrc
    ln --force --no-dereference --symbolic --verbose "${PWD}"/ubuntu/.alsoftrc "${HOME}"

}

#Section: "--wsl"

function install-dotfiles-wsl() {

    # Setup ".config"
    printf "%bSetting up \".config\"...%b\n" "${yellow}" "${reset}"
    mkdir --verbose "${HOME}"/.config

    # Setup "bin"
    printf "%bSetting up \"bin\"...%b\n" "${yellow}" "${reset}"
    mkdir --parents --verbose "${HOME}"/.local/bin

    # Setup "Bash"
    printf "%bSetting up \"bash\"...%b\n" "${yellow}" "${reset}"
    mkbackup -f "${HOME}"/.bashrc        && rm --force --verbose "${HOME}"/.bashrc ;
    mkbackup -f "${HOME}"/.profile       && rm --force --verbose "${HOME}"/.profile ;
    rm --force --verbose "${HOME}"/.bash_history ;
    mkbackup -f "${HOME}"/.bash_logout   && rm --force --verbose "${HOME}"/.bash_logout ;
    ln --force --no-dereference --symbolic --verbose "${PWD}"/wsl/.config/bash "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/wsl/.config/bash/.bash_profile "${HOME}"

    # Setup "Git"
    printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive --verbose "${HOME}"/.gitconfig
    rm --force --recursive --verbose "${HOME}"/.config/git
    ln --force --no-dereference --symbolic --verbose "${PWD}"/wsl/.config/git "${HOME}"/.config

    # Wget
    printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive --verbose "${HOME}"/wgetrc
    rm --force --recursive --verbose "${HOME}"/.wget-hst
    mkfile "${PWD}"/wsl/.config/wget/.wget-hsts
    mkfile "${PWD}"/wsl/.config/wget/.wgetrc
    ln --force --no-dereference --symbolic --verbose "${PWD}"/wsl/.config/wget "${HOME}"/.config

    # Less
    printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive --verbose "${HOME}"/.lesshst
    mkfile "${PWD}"/wsl/.config/less/.lesshst
    ln --force --no-dereference --symbolic --verbose "${PWD}"/wsl/.config/less "${HOME}"/.config

}

#Section: "--windows"

function install-dotfiles-windows() {

    # Setup "Bash"
    printf "%bSetting up \"Bash\"...%b\n" "${yellow}" "${reset}"
    mkbackup -f "${HOME}"/.bashrc       && rm --force "${HOME}"/.bashrc
    mkbackup -f "${HOME}"/.bash_profile && rm --force "${HOME}"/.bash_profile
    rm --force "${HOME}"/.bash_history
    mkbackup -f "${HOME}"/.bash_logout  && rm --force "${HOME}"/.bash_logout
    ln --force --no-dereference --symbolic --verbose "${PWD}"/windows/.config/bash/.bash_profile "${HOME}"

    # Setup "Git"
    printf "%bSetting up \"Git\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.gitconfig
    ln --force --no-dereference --symbolic --verbose "${PWD}"/windows/.config/git/config "${HOME}"/.gitconfig

    # Setup "VSCode"
    printf "%bSetting up \"VSCode\"...%b\n" "${yellow}" "${reset}"
    rm --force --recursive "${APPDATA}"/Code/User/snippets
    rm --force "${APPDATA}"/Code/User/settings.json
    rm --force "${APPDATA}"/Code/User/keybindings.json
    ln --force --no-dereference --symbolic --verbose "${PWD}"/windows/.config/Code/User/snippets "${APPDATA}"/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/windows/.config/Code/User/settings.json "${APPDATA}"/Code/User
    ln --force --no-dereference --symbolic --verbose "${PWD}"/windows/.config/Code/User/keybindings.json "${APPDATA}"/Code/User

    # Wget
    printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.wgetrc
    rm --force "${HOME}"/.wget-hsts
    mkfile "${PWD}"/windows/.config/wget/.wget-hsts
    mkfile "${PWD}"/windows/.config/wget/.wgetrc

    # Less
    printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.lesshst
    mkfile "${PWD}"/windows/.config/less/.lesshst

}

############################################################
# Options                                                  #
############################################################

while true; do
    case "${1}" in
        -h | --help)
            Help
            exit 0
            ;;
        -a | --arch)
            timer "$(printf "%bWarning: You chose to Install .dotfiles for arch..%b" "${yellow}" "${reset}")"
            install-dotfiles-arch
            exit 0
            ;;
        -u | --ubuntu)
            timer "$(printf "%bWarning: You chose to Install .dotfiles for ubuntu..%b" "${yellow}" "${reset}")"
            install-dotfiles-ubuntu
            exit 0
            ;;
        -wsl | --wsl)
            timer "$(printf "%bWarning: You chose to Install .dotfiles for wsl..%b" "${yellow}" "${reset}")"
            install-dotfiles-wsl
            exit 0
            ;;
        -w | --windows)
            timer "$(printf "%bWarning: You chose to Install .dotfiles for windows..%b" "${yellow}" "${reset}")"
            install-dotfiles-windows
            exit 0
            ;;
        *)
            Help
            exit 0
            ;;
    esac
done
