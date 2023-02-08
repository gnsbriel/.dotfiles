#!/bin/bash
#
# This script will install all dotfiles/configs in their correct folder
# based on the chosen system.
#
# Copyright 2023 Gabriel Nascimento
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Options

set -o nounset   # Exposes unset variables
set -o pipefail  # Unveils hidden failures
set +o xtrace    # Trace what gets executed (Debug)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o errtrace  # Inherit trap on ERR to shell functions, cmd substitutions
                 # and commands executed in a sub-shell environment.
trap err ERR     # Trap ERR and call err
trap ctrl_c INT  # Trap CTRL + C and call ctrl_c


# Colors
readonly cyan='\033[0;36m'
readonly red='\033[0;31m'
readonly yellow='\033[1;33m'
readonly purple='\033[0;35m'
readonly blue='\033[0;34m'
readonly light_gray='\033[0;37m'
readonly green='\033[0;32m'
readonly nc='\033[0m'

# %b - Print the argument while expanding backslash escape sequences.
# %q - Print the argument shell-quoted, reusable as input.
# %d, %i - Print the argument as a signed decimal integer.
# %s - Print the argument as a string.
# printf "'%b' 'TEXT' '%s' '%b'\n" "${color}" "${var}" "${nc}"

# Variable definitions
script_path="$(dirname "${0}")"                   ; readonly script_path
dotconfig="${XDG_CONFIG_HOME:-${HOME}/.config}"   ; readonly dotconfig
dotlocal="${XDG_DATA_HOME:-${HOME}/.local/share}" ; readonly dotlocal

# Help Message
function helpmsg() {

   echo ""
   echo "Usage: ./${0##*/} [OPTION]..."
   echo ""
   echo "Options:"
   echo "-h, --help     Print this help message."
   echo ""
   echo "-a, --arch     Current operational system (Arch Linux)."
   echo "-wsl, --wsl    Current operational system (WSL)."
   echo "-w, --windows  Current operational system (Windows)."
}

# Other functions

# shellcheck disable=SC2317
function ctrl_c() {
    # echo "** Trapped CTRL-C"
    exit 0
}

function err() {
    echo "${?}"
    printf "%bERROR: [%s] An exception ocurred near line %s !%b\n" \
        "${red}" "$(date +'%d-%m-%Y %H:%M:%S')" \
        "${BASH_LINENO[0]}" "${nc}" >&2
        exit 2
}

function countdown() {

    if [[ "${#}" == "" ]]; then
        echo "Syntax: countdown [PHRASE..]"
        exit 2
    fi

    printf "%b%s%b\n" "${blue}" "${*}" "${nc}"
    for ((i = 5 ; i > 0 ; i--)); do
        printf "%bContinuing in: %s%b\r" "${light_gray}" "${i}" "${nc}"
        sleep 1
    done
    printf "\n"
}

function create() {

    local option="${1}"; shift
    local path=( "${@}" )

    case "${option}" in
        -f | --file )
            for file in "${path[@]}"; do
                [[ -f "${file}" ]] && return
                mkdir --parents --verbose "$(dirname "${file}")" \
                    && touch "${file}" || exit 2
            done
            ;;
        -d | --directory )
            for dir in "${path[@]}"; do
                [[ -d "${dir}" ]] && return
                mkdir --parents --verbose "${dir}" || exit 2
            done
            ;;
        * )
            echo ""
            echo "Syntax: create [OPTION..] [PATH..]"
            echo ""
            echo "Options:"
            echo "-f, --file"
            echo "-d, --directory"
            exit 0
            ;;
    esac
}

function install-dotfiles-arch() {

    # HOME
    printf "%bSetting up HOME..%b\n" "${yellow}" "${nc}"
    create --directory       \
        "${dotconfig}"       \
        "${HOME}"/.local/bin

    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.alsoftrc "${HOME}" # Binaurial audio with openal

    # XDG_CONFIG_HOME
    for folder in "${PWD}"/.config/*; do

        [[ -f "${folder}" ]] && continue
        case "${folder##*/}" in
            Code | Thunar | xfce4 | pluma| less | wget ) : ;;
            * )
                printf "%bSetting up %s..%b\n"          \
                    "${yellow}" "${folder##*/}" "${nc}"
                rm --force --recursive --verbose     \
                    "${dotconfig:?}"/"${folder##*/}"
                ln --force --no-dereference --symbolic --verbose \
                    "${folder}" "${dotconfig}"

                if [[ "${folder##*/}" == "qtile" ]]; then
                    rm --force --verbose "${dotlocal}"/qtile/qtile.log
                    ln --force --no-dereference --symbolic --verbose \
                        "${dotconfig}"/qtile/qtile.log               \
                        "${dotlocal}"/qtile/qtile.log
                fi

                if [[ "${folder##*/}" == "bash" ]]; then
                    rm --force --verbose        \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    ln --force --no-dereference --symbolic --verbose     \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    ln --force --no-dereference --symbolic --verbose   \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi

                if [[ "${folder##*/}" == "X11" ]]; then
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/xcompose "${HOME}"/.XCompose
                fi

                if [[ "${folder##*/}" == "gtk-3.0" ]]; then
                    git update-index --no-skip-worktree "${folder}"/bookmarks
                    if git status --porcelain | grep -q bookmarks; then
                        rm --force --verbose "${folder}"/bookmarks
                        git restore "${folder}"/bookmarks
                    fi
                    git update-index --skip-worktree "${folder}"/bookmarks
                    sed --expression "s/CURRENTUSERNAME/${USER}/g" \
                        --in-place "${folder}"/bookmarks
                fi

                if [[ "${folder##*/}" == "flameshot" ]]; then
                    git update-index --no-skip-worktree \
                        "${folder}"/flameshot.ini
                    if git status --porcelain | grep -q flameshot.ini; then
                        rm --force --verbose "${folder}"/flameshot.ini
                        git restore "${folder}"/flameshot.ini
                    fi
                    git update-index --skip-worktree "${folder}"/flameshot.ini
                    sed --expression "s/CURRENTUSERNAME/$USER/g" \
                        --in-place "${folder}"/flameshot.ini
                fi
                ;;
        esac
    done

    # code
    printf "%bSetting up code..%b\n" "${yellow}" "${nc}"
    create --directory "${dotconfig}"/Code/User
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Code/User/snippets          \
        "${dotconfig}"/Code/User
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Code/User/settings.json     \
        "${dotconfig}"/Code/User
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Code/User/keybindings.json  \
        "${dotconfig}"/Code/User

    # thunar
    printf "%bSetting up thunar..%b\n" "${yellow}" "${nc}"
    create --directory        \
        "${dotconfig}"/Thunar \
        "${dotconfig}"/xfce4/xfconf/xfce-perchannel-xml
    ln --force --no-dereference --symbolic --verbose          \
        "${PWD}"/.config/Thunar/uca.xml "${dotconfig}"/Thunar
    ln --force --no-dereference --symbolic --verbose                 \
        "${PWD}"/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml \
        "${dotconfig}"/xfce4/xfconf/xfce-perchannel-xml

    # pluma
    printf "%bSetting up pluma..%b\n" "${yellow}" "${nc}"
    create --directory "${dotconfig}"/pluma/styles
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/pluma/styles/arc-dark.xml   \
        "${dotconfig}"/pluma/styles

    # wget
    printf "%bSetting up wget..%b\n" "${yellow}" "${nc}"
    rm --force --verbose      \
        "${HOME}"/wgetrc      \
        "${HOME}"/.wget-hsts

    create --file                       \
        "${PWD}"/.config/wget/wget-hsts \
        "${PWD}"/.config/wget/wgetrc

    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/wget "${dotconfig}"

    # less
    printf "%bSetting up less..%b\n" "${yellow}" "${nc}"
    create --file "${PWD}"/.config/less/lesshst
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/less "${dotconfig}"

    # MIME types
    printf "%bSetting up MIME types..%b\n" "${yellow}" "${nc}"
    create --directory "${dotlocal}"/applications
    ln --force --no-dereference --symbolic --verbose              \
        "${PWD}"/.config/mimeapps.list "${dotlocal}"/applications
    ln --force --no-dereference --symbolic --verbose  \
        "${PWD}"/.config/mimeapps.list "${dotconfig}"

    # .LOCAL

    # bin
    printf "%bSetting up bin..%b\n" "${yellow}" "${nc}"
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.local/bin/* "${HOME}"/.local/bin
}

function install-dotfiles-wsl() {

    # HOME
    printf "%bSetting up HOME..%b\n" "${yellow}" "${nc}"
    create --directory       \
        "${dotconfig}"       \
        "${HOME}"/.local/bin

    # XDG_CONFIG_HOME
    for folder in "${PWD}"/.config/*; do

        [[ -f "${folder}" ]] && continue
        case "${folder##*/}" in
            bash | git )
                printf "%bSetting up %s..%b\n"          \
                    "${yellow}" "${folder##*/}" "${nc}"
                rm --force --recursive --verbose     \
                    "${dotconfig:?}"/"${folder##*/}"
                ln --force --no-dereference --symbolic --verbose \
                    "${folder}" "${dotconfig}"

                if [[ "${folder##*/}" == "bash" ]]; then
                    rm --force --verbose        \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    ln --force --no-dereference --symbolic --verbose     \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    ln --force --no-dereference --symbolic --verbose   \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi
                ;;
            * )
                :
                ;;
        esac
    done

    # wget
    printf "%bSetting up \"wget\"...%b\n" "${yellow}" "${nc}"
    rm --force --verbose     \
        "${HOME}"/wgetrc     \
        "${HOME}"/.wget-hsts

    create --file                            \
        "${PWD}"/wsl/.config/wget/.wget-hsts \
        "${PWD}"/wsl/.config/wget/.wgetrc

    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/wsl/.config/wget "${dotconfig}"

    # less
    printf "%bSetting up \"less\"...%b\n" "${yellow}" "${nc}"
    rm --force --verbose "${HOME}"/.lesshst
    create --file "${PWD}"/wsl/.config/less/.lesshst
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/wsl/.config/less "${dotconfig}"

    # .LOCAL

    # bin
    # printf "%bSetting up bin..%b\n" "${yellow}" "${nc}"
    # :
}

function install-dotfiles-windows() {

    # HOME
    printf "%bSetting up HOME..%b\n" "${yellow}" "${nc}"
    create --directory       \
        "${HOME}"/.config    \
        "${HOME}"/.local/bin

    # .CONFIG
    for folder in "${PWD}"/.config/*; do

        [[ -f "${folder}" ]] && continue
        case "${folder##*/}" in
            bash | git | Code )
                printf "%bSetting up %s..%b\n"          \
                    "${yellow}" "${folder##*/}" "${nc}"
                rm --force --recursive --verbose      \
                    "${HOME}"/.config/"${folder##*/}"
                ln --force --no-dereference --symbolic --verbose \
                    "${folder}" "${HOME}"/.config

                if [[ "${folder##*/}" == "bash" ]]; then
                    rm --force --verbose        \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    ln --force --no-dereference --symbolic --verbose     \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    ln --force --no-dereference --symbolic --verbose   \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi

                if [[ "${folder##*/}" == "git" ]]; then
                    rm --force --verbose  "${HOME}"/.gitconfig
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/config "${HOME}"/.gitconfig
                fi

                if [[ "${folder##*/}" == "Code" ]]; then
                    rm --force --recursive --verbose    \
                        "${APPDATA}"/Code/User/snippets

                    rm --force --verbose                        \
                        "${APPDATA}"/Code/User/settings.json    \
                        "${APPDATA}"/Code/User/keybindings.json

                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/Code/User/snippets               \
                        "${APPDATA}"/Code/User
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/Code/User/settings.json          \
                        "${APPDATA}"/Code/User
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/Code/User/keybindings.json       \
                        "${APPDATA}"/Code/User
                fi
                ;;
            * )
                :
                ;;
        esac
    done

    # Wget
    printf "%bSetting up \"Wget\"...%b\n" "${yellow}" "${nc}"
    rm --force --verbose     \
        "${HOME}"/.wgetrc    \
        "${HOME}"/.wget-hsts

    create --file                        \
        "${PWD}"/.config/wget/.wget-hsts \
        "${PWD}"/.config/wget/.wgetrc

    # Less
    printf "%bSetting up \"Less\"...%b\n" "${yellow}" "${nc}"
    rm --force --verbose "${HOME}"/.lesshst
    create --file "${PWD}"/.config/less/.lesshst
}

# Main Program
function main() {

    while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
        case $1 in
            -v | --version )
                echo "${version:-}"
                exit
                ;;
            -s | --string )
                shift; string=$1
                ;;
            -f | --flag )
                flag=1
                ;;
        esac
        shift
    done
    if [[ "$1" == '--' ]]; then
        shift
    fi
}

cd "${script_path}"  # cd to executable path

main "${@}"
