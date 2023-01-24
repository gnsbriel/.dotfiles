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
        printf "%bIncorrect use of 'timer' Function !%b\nSyntax:\vtimer_ 'PHRASE';%b\n" "${purple}" "${light_gray}" "${reset}" 1>&2
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
        printf "%bIncorrect use of 'mkfile' Function !%b\nSyntax:\vmkfile [PATH]... ;%b" "${red}" "${light_gray}" "${reset}" 1>&2 ;
        exit 2 ;
    fi

    # Create File and Folder if needed
    mkdir --parents --verbose "$(dirname "${1}")" && touch "${1}" || exit 2 ;

}

function backup-file() {

    if [ ! -d "${PWD}"/Backup ]; then mkdir "${PWD}"/Backup; fi
    case "${1}" in
        -f | --file )
            if [ ! -f "${PWD}"/Backup/"${1}" ]; then cp --recursive --verbose "${1}" "${PWD}"/Backup; fi
            ;;
        -d | --directory )
            if [ ! -d "${PWD}"/Backup/"${1}" ]; then cp --recursive --verbose "${1}" "${PWD}"/Backup; fi
            ;;
        * )
            echo ""
            echo "Syntax: backup-file [OPTION..] [PATH..]"
            echo ""
            echo "Options:"
            echo "-f, --file"
            echo "-d, --directory"
            exit 0
            ;;
    esac


}

backup-file

#Section: "--arch"

function install-dotfiles-arch() {

    # Setup ".config"
    mkdir --parents --verbose "${HOME}"/.config

    # Setup "bin"
    printf "%bSetting up \"bin\"...%b\n" "${yellow}" "${reset}"
    if [ ! -d "${HOME}"/.local/bin ]; then mkdir --parents --verbose "${HOME}"/.local/bin; fi
    ln --force --no-dereference --symbolic --verbose "${PWD}"/.local/bin "${HOME}"/.local

    # Setup "Bash"
    printf "%bSetting up \"bash\"...%b\n" "${yellow}" "${reset}"
    rm --force "${HOME}"/.bashrc
    rm --force "${HOME}"/.bash_profile
    rm --force "${HOME}"/.bash_history
    rm --force "${HOME}"/.bash_logout
    ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash "${HOME}"/.config
    ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_profile "${HOME}"
    ln --force --no-dereference --symbolic --verbose "${PWD}"/.config/bash/.bash_logout "${HOME}"

}

#Section: "--ubuntu"


function install-dotfiles-ubuntu() {

    :

}

#Section: "--wsl"


function install-dotfiles-wsl() {

    :

}

#Section: "--windows"

function install-dotfiles-windows() {

    :

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
            shift
            ;;
        -u | --ubuntu)
            shift
            ;;
        -wsl | --wsl)
            shift
            ;;
        -w | --windows)
            shift
            ;;
        *)
            Help
            exit 0
            ;;
    esac
done
