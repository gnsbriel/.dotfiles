#!/bin/bash

# {{{ Colors

readonly cyan='\033[0;36m'
readonly red='\033[0;31m'
readonly yellow='\033[1;33m'
readonly purple='\033[0;35m'
readonly blue='\033[0;34m'
readonly light_gray='\033[0;37m'
readonly green='\033[0;32m'
readonly reset='\033[0m'

# %b - Print the argument while expanding backslash escape sequences.
# %q - Print the argument shell-quoted, reusable as input.
# %d, %i - Print the argument as a signed decimal integer.
# %s - Print the argument as a string.

#Syntax:
#    printf "'%b' 'TEXT' '%s' '%b'\n" "${color}" "${var}" "${reset}"
# }}}

# {{{ Help Message

function msghelp() {

   echo ""
   echo "Usage: ${0} [OPTION]..."
   echo ""
   echo "Options:"
   echo "-h, --help     Print this help message."
   echo ""
   echo "-a, --arch     Current operational system (Arch Linux)."
   echo "-wsl, --wsl    Current operational system (WSL)."
   echo "-w, --windows  Current operational system (Windows)."
   echo ""
   exit 2
}
# }}}

# {{{ Main Program

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

function create() {

    case "${1}" in
        -f | --file )
            shift
            [ -f "${1}" ] && return
            mkdir --parents --verbose "$(dirname "${1}")" \
                && touch "${1}" || exit 2
            ;;
        -d | --directory )
            shift
            [ -d "${1}" ] && return
            mkdir --parents --verbose "${1}" || exit 2
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

    # {{{ "${HOME}"

    printf "%bSetting up HOME..%b\n" "${yellow}" "${reset}"
    create --directory "${XDG_CONFIG_HOME}"
    create --directory "${HOME}"/.local/bin

    # Binaurial audio with openal
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.alsoftrc "${HOME}"
    # }}}

    # {{{ "${XDG_CONFIG_HOME}"

    for folder in "${PWD}"/.config/*; do

        [ ! -d "${folder}" ] && continue
        case "${folder##*/}" in
            Code | Thunar | xfce4 | pluma| less | wget ) : ;;
            * )
                printf "%bSetting up %s..%b\n" \
                    "${yellow}" "${folder##*/}" "${reset}"
                rm --force --recursive --verbose \
                    "${XDG_CONFIG_HOME:?}"/"${folder##*/}"
                ln --force --no-dereference --symbolic --verbose \
                    "${folder}" "${XDG_CONFIG_HOME}" || exit 2

                if [ "${folder##*/}" == "qtile" ]; then
                    rm --force --verbose "${XDG_DATA_HOME}"/qtile/qtile.log
                    ln --force --no-dereference --symbolic --verbose \
                        "${XDG_CONFIG_HOME}"/qtile/qtile.log \
                        "${XDG_DATA_HOME}"/qtile/qtile.log
                fi

                if [ "${folder##*/}" == "bash" ]; then
                    rm --force --verbose        \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi

                if [ "${folder##*/}" == "X11" ]; then
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}"/xcompose "${HOME}"/.XCompose
                fi

                if [ "${folder##*/}" == "gtk-3.0" ]; then
                    git update-index --no-skip-worktree "${folder}"/bookmarks
                    if git status --porcelain | grep -q bookmarks; then
                        rm --force --verbose "${folder}"/bookmarks
                        git restore "${folder}"/bookmarks
                    fi
                    git update-index --skip-worktree "${folder}"/bookmarks
                    sed --expression "s/CURRENTUSERNAME/${USER}/g" \
                        --in-place "${folder}"/bookmarks
                fi

                if [ "${folder##*/}" == "flameshot" ]; then
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
    printf "%bSetting up code..%b\n" "${yellow}" "${reset}"
    create --directory "${XDG_CONFIG_HOME}"/Code/User
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Code/User/snippets \
        "${XDG_CONFIG_HOME}"/Code/User
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Code/User/settings.json \
        "${XDG_CONFIG_HOME}"/Code/User
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Code/User/keybindings.json \
        "${XDG_CONFIG_HOME}"/Code/User

    # thunar
    printf "%bSetting up thunar..%b\n" "${yellow}" "${reset}"
    create --directory "${XDG_CONFIG_HOME}"/Thunar
    create --directory \
            "${XDG_CONFIG_HOME}"/xfce4/xfconf/xfce-perchannel-xml
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/Thunar/uca.xml "${XDG_CONFIG_HOME}"/Thunar
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml \
        "${XDG_CONFIG_HOME}"/xfce4/xfconf/xfce-perchannel-xml

    # pluma
    printf "%bSetting up pluma..%b\n" "${yellow}" "${reset}"
    create --directory "${XDG_CONFIG_HOME}"/pluma/styles
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/pluma/styles/arc-dark.xml \
        "${XDG_CONFIG_HOME}"/pluma/styles

    # wget
    printf "%bSetting up wget..%b\n" "${yellow}" "${reset}"
    rm --force --verbose        \
        "${HOME}"/wgetrc        \
        "${HOME}"/.wget-hsts
    create --file "${PWD}"/.config/wget/wget-hsts
    create --file "${PWD}"/.config/wget/wget/wgetrc
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/wget "${XDG_CONFIG_HOME}"

    # less
    printf "%bSetting up less..%b\n" "${yellow}" "${reset}"
    create --file "${PWD}"/.config/less/lesshst
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/less "${XDG_CONFIG_HOME}"

    # MIME types
    printf "%bSetting up MIME types..%b\n" "${yellow}" "${reset}"
    create --directory "${XDG_DATA_HOME}"/applications
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/mimeapps.list "${XDG_DATA_HOME}"/applications
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.config/mimeapps.list "${XDG_CONFIG_HOME}"
    # }}}

    # {{{ .local

    # bin
    printf "%bSetting up bin..%b\n" "${yellow}" "${reset}"
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/.local/bin/* "${HOME}"/.local/bin
    # }}}
}

function install-dotfiles-wsl() {

    # {{{ "${HOME}"

    printf "%bSetting up HOME..%b\n" "${yellow}" "${reset}"
    create --directory "${XDG_CONFIG_HOME}"
    create --directory "${HOME}"/.local/bin
    # }}}


    # {{{ "${XDG_CONFIG_HOME}"

        for folder in "${PWD}"/.config/*; do

            [ ! -d "${folder}" ] && continue
            case "${folder##*/}" in
                bash | git )
                    printf "%bSetting up %s..%b\n" \
                        "${yellow}" "${folder##*/}" "${reset}"
                    rm --force --recursive --verbose \
                        "${XDG_CONFIG_HOME:?}"/"${folder##*/}"
                    ln --force --no-dereference --symbolic --verbose \
                        "${folder}" "${XDG_CONFIG_HOME}" || exit 2

                    if [ "${folder##*/}" == "bash" ]; then
                        rm --force --verbose        \
                            "${HOME}"/.profile      \
                            "${HOME}"/.bashrc       \
                            "${HOME}"/.bash_profile \
                            "${HOME}"/.bash_logout  \
                            "${HOME}"/.bash_history
                        ln --force --no-dereference --symbolic --verbose \
                            "${folder}"/bash_profile "${HOME}"/.bash_profile
                        ln --force --no-dereference --symbolic --verbose \
                            "${folder}"/bash_logout "${HOME}"/.bash_logout
                    fi
                    ;;
                * )
                    :
                    ;;
            esac
        done

    # wget
    printf "%bSetting up \"wget\"...%b\n" "${yellow}" "${reset}"
    rm --force --verbose        \
        "${HOME}"/wgetrc        \
        "${HOME}"/.wget-hsts

    create --file "${PWD}"/wsl/.config/wget/.wget-hsts
    create --file "${PWD}"/wsl/.config/wget/.wgetrc
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/wsl/.config/wget "${XDG_CONFIG_HOME}"

    # less
    printf "%bSetting up \"less\"...%b\n" "${yellow}" "${reset}"
    rm --force --verbose "${HOME}"/.lesshst
    create --file "${PWD}"/wsl/.config/less/.lesshst
    ln --force --no-dereference --symbolic --verbose \
        "${PWD}"/wsl/.config/less "${XDG_CONFIG_HOME}"
    # }}}

    # {{{ local

    # bin
    # printf "%bSetting up bin..%b\n" "${yellow}" "${reset}"
    # }}}
}

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
# }}}

# {{{ Options

# {{{ Checks

[[ "${PWD##*/}" == ".dotfiles" ]] || msghelp
[[ ! -f "${PWD}"/sys ]] && touch "${PWD}"/sys
# }}}

while true; do
    case "${1}" in
        -h | --help)
            msghelp
            ;;
        -a | --arch)
            echo "arch" > "${PWD}"/sys
            timer "Warning: You chose to install .dotfiles for arch.."
            install-dotfiles-arch
            exit 0
            ;;
        -wsl | --wsl)
            echo "wsl" > "${PWD}"/sys
            timer "Warning: You chose to install .dotfiles for wsl.."
            install-dotfiles-wsl
            exit 0
            ;;
        -w | --windows)
            echo "windows" > "${PWD}"/sys
            timer "Warning: You chose to install .dotfiles for windows.."
            install-dotfiles-windows
            exit 0
            ;;
        *)
            msghelp
            ;;
    esac
done

# }}}
