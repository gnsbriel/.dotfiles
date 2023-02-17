#!/bin/bash

#==============================================================================
# HEADER
#==============================================================================
#%
#% NAME
#%    Install .dotfiles
#%
#% SYNOPSIS
#+    ${script_name} [Options..] [Arguments..]
#%
#% DESCRIPTION
#%    This shell script will install/setup all dotfiles and configs in their
#%    respective folder based on the chosen system.
#%
#% OPTIONS
#%    -h, --help                    Print this help
#%
#%    -l, --log-file                Custom log file location.
#%                                  Default is '/dev/null'.
#%
#%    -L, --log-level               Change the log level, default is '3':
#%                                      0 -> Log only CRITICAL messages.
#%                                      1 -> Log CRITICAL and ERROR messages.
#%                                      2 -> Log CRITICAL, ERROR and WARNING
#%                                           messages.
#%                                      3 -> Log CRITITAL, ERROR, WARNING and
#%                                           INFO messages.
#%                                      4 -> Log CRITICAL, ERROR, WARNING,
#%                                           INFO and DEBUG messages.
#%                                      5 -> log CRITICAL, ERROR, WARNING,
#%                                           INFO, DEBUG and TRACE messages.
#%
#%    -s, --system                  Choose a Operatinal System:
#%                                      arch - Setup dotfiles for Arch Linux.
#%                                      wsl - Setup dotfiles for WSL.
#%                                      windows - Setup dotfiles for Windows.
#%
#% EXAMPLE
#%    ${script_name} --help
#%    ${script_name} -l script.log -L 5 --system [option..]
#%
#==============================================================================
#/ IMPLEMENTATION
#/    Version         ${script_name} 1.0
#/    Author          Gabriel Nascimento
#/    Copyright       Copyright (c) Gabriel Nascimento (www.gnsilva.com)
#/    License         MIT License
#/
#==============================================================================
#) COPYRIGHT
#)    Copyright (c) Gabriel Nascimento. Licence MIT License:
#)    <https://opensource.org/licenses/MIT>.
#)
#)    Permission is hereby granted, free of charge, to any person obtaining a
#)    copy of this software and associated documentation files (the
#)    "Software"), to deal in the Software without restriction, including
#)    without limitation the rights to use, copy, modify, merge, publish,
#)    distribute, sublicense, and/or sell copies of the Software, and to permit
#)    persons to whom the Software is furnished to do so, subject to the
#)    following conditions:
#)
#)    The above copyright notice and this permission notice shall be included
#)    in all copies or substantial portions of the Software.
#)
#)    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#)    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#)    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
#)    NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#)    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#)    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
#)    USE OR OTHER DEALINGS IN THE SOFTWARE.
#)
#==============================================================================
# DEBUG OPTIONS
    set +o xtrace  # Trace the execution of the script (DEBUG)
    set +o noexec  # Don't execute commands (Ignored by interactive shells)
#
#==============================================================================
# OPTIONS
    set   -o nounset     # Exposes unset variables
    set   -o errexit     # Used to exit upon error, avoiding cascading errors
    set   -o pipefail    # Unveils hidden failures
    set   -o noclobber   # Avoid overwriting files (echo "hi" > foo)
    set   -o errtrace    # Inherit trap on ERR to functions, commands and etc.
    shopt -s nullglob    # Non-matching globs are removed ('*.foo' => '')
    shopt -s failglob    # Non-matching globs throw errors
    shopt -u nocaseglob  # Case insensitive globs
    shopt -s dotglob     # Wildcards match hidden files ("*.sh" => ".foo.sh")
    shopt -s globstar    # Recursive matches ('a/**/*.rb' => 'a/b/c/d.rb')
#
#==============================================================================
# TRAPS
    trap err_trapper ERR     # Trap ERR and call err_trapper
    trap ctrl_c_trapper INT  # Trap CTRL_C and call ctrl_c
    trap exit_trapper EXIT   # Trap EXIT and call exit_trapper
    trap "" SIGTSTP          # Disable CTRL_Z
#
#==============================================================================
# END_OF_HEADER
#==============================================================================

# Section: Functions

function script_init() {

    dotconfig="${XDG_CONFIG_HOME:-${HOME}/.config}"
    dotlocal="${XDG_DATA_HOME:-${HOME}/.local/share}"

    origin_cwd="${PWD}"

    script_head=$(\grep --no-messages --line-number "^# END_OF_HEADER" "${0}" | \head -1 | cut --fields=1 --delimiter=:)
    script_name="$(\basename "${0}")"
    script_dir="$(\cd "$(\dirname "${0}")" && \pwd )"
    script_path="${script_dir}/${script_name}"
    script_params="${*}"

    script_log="${script_dir}/.log" # default is '/dev/null'
    script_loglevel=3  # default is 3

    script_tempdir=$(\mktemp --directory -t tmp.XXXXXXXXXX)
    script_tempfile=$(\mktemp -t tmp.XXXXXXXXXX)

    #IFS=$'\n\t'
}

function ctrl_c_trapper() {

    trap "" INT  # Disable the ctrl_c trap handler to prevent recursion

    inf "Interrupt signal intercepted! Exiting now..."
    exit 130
}

function err_trapper() {

    local exitcode="${?}"

    trap - ERR # Disable the error trap handler to prevent recursion

    critical "An exception ocurred near line ${BASH_LINENO[0]}"
    inf "Script Parameters: '${script_params}'"

    exit "${exitcode}"
}

function exit_trapper {

    local exitcode="${?}"

    trap - ERR # Disable the exit trap handler to prevent recursion

    do_cd "${origin_cwd}"
    do_rm --recursive --force "${script_tempdir}" "${script_tempfile}"
    do_unset

    exit "${exitcode}"
}

function help_usage() {

    do_printf "Usage: "
    do_help "usg"
}

function help_full() {

    do_help "ful"
}

function do_help() {

    local filter_type
    filter_type="${1}"

    if [[ "${filter_type}" == "usg" ]]; then filter="^#+[ ]*" ; fi
    if [[ "${filter_type}" == "ful" ]]; then filter="^#[%/)+]"; fi

    \head -"${script_head:-99}" "${0}"                        \
        | \grep --regexp="${filter:-y^#-}"                    \
        | \sed --expression="s/${filter:-^#-}//g"             \
            --expression="s/\${script_name}/${script_name}/g"
}

function critical() {

    log "0" "${1}"
}

function error() {

    log "1" "${1}"
}

function warning() {

    log "2" "${1}"
}

function inf() {

    log "3" "${1}"
}

function debug() {

    log "4" "${1}"
}

function trace() {

    log "5" "${1}"
}

function log() {

    local loglevels
    local loglevel
    local logcolors
    local logcolor
    local logdate
    local termlogformat
    local filelogformat

    loglevels=( "CRITICAL"   "ERROR"      "WARNING"    "INFO"       "DEBUG"      "TRACE"      )
    logcolors=( "$(color r)" "$(color g)" "$(color y)" "$(color g)" "$(color m)" "$(color b)" )
    loglevel="${loglevels[${1}]}"
    logcolor="${logcolors[${1}]}"
    logdate=$(\date +"%Y/%m/%d %H:%M:%S")

    termlogformat="[${logdate}] ${logcolor}[${loglevel}]$(color nc) ${2}"
    filelogformat="[${logdate}] [${loglevel}] > ${FUNCNAME[3]} | ${2}"

    if [[ "${script_loglevel}" -ge "${1}" ]]; then
        do_printf "${termlogformat}"
    fi

    do_echo "${filelogformat}" | \fold --width=79 --spaces | \sed '2~1s/^/  /' >> "${script_log:-/dev/null}"
}

# shellcheck disable=SC2015
function do_grep() {

    command grep "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'grep ${*}'"                 \
        || error "'grep ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_cd() {

    command cd "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'cd ${*}'"                 \
        || error "'cd ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_cp() {

    command cp "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'cp ${*}'"                 \
        || error "'cp ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_mv() {

    command mv "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'mv ${*}'"                 \
        || error "'mv ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_mkdir() {

    command mkdir "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'mkdir ${*}'"                 \
        || error "'mkdir ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_touch() {

    command touch "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'touch ${*}'"                 \
        || error "'touch ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_ln() {

    command ln "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'ln ${*}'"                 \
        || error "'ln ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_rm() {

    command rm "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'rm ${*}'"                 \
        || error "'rm ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_sed() {
    command sed "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'sed ${*}'"                 \
        || error "'sed ${*}' failed near line ${BASH_LINENO[0]}!"
}

function do_echo() {

    command printf "%s\n" "${*}" 2>/dev/null
}

function do_printf() {

    command printf "%b%b\n" "${*}" "$(color nc)" 2>/dev/null
}

function do_printf_n() {

    command printf "%b%b" "${*}" "$(color nc)" 2>/dev/null
}

function color() {

    local foreground
    foreground="${*}"

    case "${foreground}" in
        'r' ) do_echo '\033[0;31m' ;;  # Red
        'R' ) do_echo '\033[1;31m' ;;  # Bold Red
        'g' ) do_echo '\033[0;32m' ;;  # Green
        'G' ) do_echo '\033[1;32m' ;;  # Bold Green
        'b' ) do_echo '\033[0;34m' ;;  # Blue
        'B' ) do_echo '\033[1;34m' ;;  # Bold Blue
        'c' ) do_echo '\033[0;36m' ;;  # Cyan
        'C' ) do_echo '\033[1;36m' ;;  # Bold Cyan
        'm' ) do_echo '\033[0;35m' ;;  # Magenta
        'M' ) do_echo '\033[1;35m' ;;  # Bold Magenta
        'y' ) do_echo '\033[0;33m' ;;  # Yellow
        'Y' ) do_echo '\033[1;33m' ;;  # Bold Yellow
        'k' ) do_echo '\033[0;30m' ;;  # Black
        'K' ) do_echo '\033[1;30m' ;;  # Gray
        'e' ) do_echo '\033[0;37m' ;;  # Light Gray
        'W' ) do_echo '\033[1;37m' ;;  # White
        'nc') do_echo '\033[0m'    ;;  # No Color code
        * ) warning "Invalid color code near line ${BASH_LINENO[0]}"
        ;;
    esac
}

function check_binary() {

    if [[ "${#}" -lt 1 ]]; then
        error "Missing required argument to 'check_binary()' near line (${BASH_LINENO[0]})"
        exit 1
    fi

    local do_exit

    local i
    for i in "${@}"; do

        if [[ "${i}" =~ ^(-e|--exit)$ ]];then
            do_exit=1
            continue
        fi

        if ! command -v "${i}" > /dev/null 2>&1; then
            critical "Missing dependency: Couldn't locate '${i}'. (${BASH_LINENO[0]})"
            continue
        fi

        inf "Found dependency: '${i}'"
    done

    if [[ "${do_exit:-}" == "1" ]]; then
        exit 1
    fi
}

function validade_str() {

    if [[ "${#}" -lt 1 ]]; then
        error "Missing required argument to 'validade_str()' near line (${BASH_LINENO[0]})"
        exit 1
    fi

    local do_exit

    if [[ "${1}" =~ ^- ]]; then
        if [[ "${2}" =~ ^(-e|--exit)$ ]];then do_exit=1; fi
        warning "Warning: The file name argument '${1}' looks like a flag"
    fi

    if [[ -z "${1}" ]]; then
        if [[ "${2}" =~ ^(-e|--exit)$ ]];then do_exit=1; fi
        warning "Warning: The file name argument '${1}' looks empty"
    fi

    if [[ "${do_exit:-}" == "1" ]]; then
        warning "Try './${script_name} --help' for more information."
        exit 1
    fi
}

# shellcheck disable=SC2120
function do_countdown() {

    local seconds
    seconds="${1:-5}"

    for ((i = seconds ; i > -1 ; i--)); do
        do_printf_n "$(color e)Continuing in: ${i}\r"
        sleep 1
    done

    do_echo ""
}

# shellcheck disable=SC2015
function create() {

    local option
    local path
    option="${1}"; shift
    path=( "${@}" )

    case "${option}" in
        -f | --file )
            for file in "${path[@]}"; do
                if [[ -f "${file}" ]]; then
                    debug "(${BASH_LINENO[0]}) File: '${file}' already found.."
                    continue
                fi
                do_mkdir --parents "$(dirname "${file}")"   \
                    && do_touch "${file}"                   \
                    ||  {
                            error "Couldn't create ${file}"
                            exit 2
                        }
                debug "(${BASH_LINENO[0]}) Created file: ${file}"
            done
            ;;
        -d | --directory )
            for dir in "${path[@]}"; do
                if [[ -d "${dir}" ]]; then
                    debug "(${BASH_LINENO[0]}) Directory: '${dir}' already found.."
                    continue
                fi
                do_mkdir --parents "${dir}"                \
                    ||  {
                            error "Couldn't create ${dir}"
                            exit 2
                        }
                debug "(${BASH_LINENO[0]}) Created directory: ${dir}"
            done
            ;;
        * )
            error "(${BASH_LINENO[0]}) Usage: create [OPTION..] [PATH..]"
            error ""
            error "Options:"
            error "    -f, --file"
            error "    -d, --directory"
            ;;
    esac
}

function arch() {

    inf "Setting up 'HOME'"
    create --directory       \
        "${dotconfig}"       \
        "${HOME}"/.local/bin

    # Binaurial audio with openal
    do_ln --force --no-dereference --symbolic \
        "${script_dir}"/.alsoftrc "${HOME}"

    inf "Setting up 'XDG_CONFIG_HOME'"
    for folder in "${script_dir}"/.config/*; do

        if [[ -f "${folder}" ]]; then
            continue
        fi

        case "${folder##*/}" in
            Code | Thunar | xfce4 | pluma| less | wget ) : ;;
            * )
                inf "Setting up ${folder##*/}.."
                do_rm --force --recursive            \
                    "${dotconfig:?}"/"${folder##*/}"
                do_ln --force --no-dereference --symbolic \
                    "${folder}" "${dotconfig}"

                if [[ "${folder##*/}" == "qtile" ]]; then
                    create --directory "${dotlocal}"/qtile
                    create --file "${script_dir}"/.config/qtile/qtile.log
                    do_rm --force "${dotlocal}"/qtile/qtile.log
                    do_ln --force --no-dereference --symbolic \
                        "${dotconfig}"/qtile/qtile.log        \
                        "${dotlocal}"/qtile/qtile.log
                fi

                if [[ "${folder##*/}" == "bash" ]]; then
                    do_rm --force               \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    do_ln --force --no-dereference --symbolic            \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    do_ln --force --no-dereference --symbolic          \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi

                if [[ "${folder##*/}" == "X11" ]]; then
                    do_ln --force --no-dereference --symbolic    \
                        "${folder}"/xcompose "${HOME}"/.XCompose
                fi

                if [[ "${folder##*/}" == "gtk-3.0" ]]; then
                    git update-index --no-skip-worktree "${folder}"/bookmarks
                    if git status --porcelain | grep -q bookmarks; then
                        do_rm --force "${folder}"/bookmarks
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
                        do_rm --force "${folder}"/flameshot.ini
                        git restore "${folder}"/flameshot.ini
                    fi
                    git update-index --skip-worktree "${folder}"/flameshot.ini
                    sed --expression "s/CURRENTUSERNAME/$USER/g" \
                        --in-place "${folder}"/flameshot.ini
                fi
                ;;
        esac
    done

    inf "Setting up code.."
    create --directory "${dotconfig}"/Code/User
    do_ln --force --no-dereference --symbolic      \
        "${script_dir}"/.config/Code/User/snippets \
        "${dotconfig}"/Code/User
    do_ln --force --no-dereference --symbolic           \
        "${script_dir}"/.config/Code/User/settings.json \
        "${dotconfig}"/Code/User
    do_ln --force --no-dereference --symbolic              \
        "${script_dir}"/.config/Code/User/keybindings.json \
        "${dotconfig}"/Code/User

    inf "Setting up thunar.."
    create --directory                                  \
        "${dotconfig}"/Thunar                           \
        "${dotconfig}"/xfce4/xfconf/xfce-perchannel-xml
    do_ln --force --no-dereference --symbolic                        \
        "${script_dir}"/.config/Thunar/uca.xml "${dotconfig}"/Thunar
    do_ln --force --no-dereference --symbolic                               \
        "${script_dir}"/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml \
        "${dotconfig}"/xfce4/xfconf/xfce-perchannel-xml

    inf "Setting up pluma.."
    create --directory "${dotconfig}"/pluma/styles
    do_ln --force --no-dereference --symbolic             \
        "${script_dir}"/.config/pluma/styles/arc-dark.xml \
        "${dotconfig}"/pluma/styles

    do_rm --force            \
        "${HOME}"/wgetrc     \
        "${HOME}"/.wget-hsts

    create --file                              \
        "${script_dir}"/.config/wget/wget-hsts \
        "${script_dir}"/.config/wget/wgetrc

    do_ln --force --no-dereference --symbolic       \
        "${script_dir}"/.config/wget "${dotconfig}"

    inf "Setting up less.."
    create --file "${script_dir}"/.config/less/lesshst
    do_ln --force --no-dereference --symbolic       \
        "${script_dir}"/.config/less "${dotconfig}"

    inf "Setting up MIME types.."
    create --directory "${dotlocal}"/applications
    do_ln --force --no-dereference --symbolic                            \
        "${script_dir}"/.config/mimeapps.list "${dotlocal}"/applications
    do_ln --force --no-dereference --symbolic                \
        "${script_dir}"/.config/mimeapps.list "${dotconfig}"

    inf "Setting up 'HOME/.local/bin'.."
    do_ln --force --no-dereference --symbolic             \
        "${script_dir}"/.local/bin/* "${HOME}"/.local/bin
}

function wsl() {

    inf "Setting up 'HOME'.."
    create --directory       \
        "${dotconfig}"       \
        "${HOME}"/.local/bin

    inf "Setting up 'XDG_CONFIG_HOME'.."
    for folder in "${script_dir}"/.config/*; do

        if [[ -f "${folder}" ]]; then
            continue
        fi

        case "${folder##*/}" in
            bash | git )
                inf "Setting up '${folder##*/}'.."
                do_rm --force --recursive            \
                    "${dotconfig:?}"/"${folder##*/}"
                do_ln --force --no-dereference --symbolic \
                    "${folder}" "${dotconfig}"

                if [[ "${folder##*/}" == "bash" ]]; then
                    do_rm --force               \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    do_ln --force --no-dereference --symbolic            \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    do_ln --force --no-dereference --symbolic          \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi
                ;;
            * )
                :
                ;;
        esac
    done

    inf "Setting up 'wget'.."
    do_rm --force            \
        "${HOME}"/wgetrc     \
        "${HOME}"/.wget-hsts

    create --file                                   \
        "${script_dir}"/wsl/.config/wget/.wget-hsts \
        "${script_dir}"/wsl/.config/wget/.wgetrc

    do_ln --force --no-dereference --symbolic           \
        "${script_dir}"/wsl/.config/wget "${dotconfig}"

    inf "Setting up 'less'.."
    do_rm --force "${HOME}"/.lesshst
    create --file "${script_dir}"/wsl/.config/less/.lesshst
    do_ln --force --no-dereference --symbolic           \
        "${script_dir}"/wsl/.config/less "${dotconfig}"

    # inf "Setting up 'HOME/.local/bin'.."
    # :
}

function windows() {

    inf "Setting up 'HOME'.."
    create --directory       \
        "${HOME}"/.config    \
        "${HOME}"/.local/bin

    inf "Setting up '.config'.."
    for folder in "${script_dir}"/.config/*; do

        if [[ -f "${folder}" ]];then
            continue
        fi

        case "${folder##*/}" in
            bash | git | Code )
                inf "Setting up '${folder##*/}'.."
                do_rm --force --recursive             \
                    "${HOME}"/.config/"${folder##*/}"
                do_ln --force --no-dereference --symbolic \
                    "${folder}" "${HOME}"/.config

                if [[ "${folder##*/}" == "bash" ]]; then
                    do_rm --force               \
                        "${HOME}"/.profile      \
                        "${HOME}"/.bashrc       \
                        "${HOME}"/.bash_profile \
                        "${HOME}"/.bash_logout  \
                        "${HOME}"/.bash_history

                    do_ln --force --no-dereference --symbolic            \
                        "${folder}"/bash_profile "${HOME}"/.bash_profile
                    do_ln --force --no-dereference --symbolic          \
                        "${folder}"/bash_logout "${HOME}"/.bash_logout
                fi

                if [[ "${folder##*/}" == "git" ]]; then
                    do_rm --force  "${HOME}"/.gitconfig
                    do_ln --force --no-dereference --symbolic   \
                        "${folder}"/config "${HOME}"/.gitconfig
                fi

                if [[ "${folder##*/}" == "Code" ]]; then
                    do_rm --force --recursive           \
                        "${APPDATA}"/Code/User/snippets

                    do_rm --force                               \
                        "${APPDATA}"/Code/User/settings.json    \
                        "${APPDATA}"/Code/User/keybindings.json

                    do_ln --force --no-dereference --symbolic        \
                        "${folder}"/Code/User/snippets               \
                        "${APPDATA}"/Code/User
                    do_ln --force --no-dereference --symbolic        \
                        "${folder}"/Code/User/settings.json          \
                        "${APPDATA}"/Code/User
                    do_ln --force --no-dereference --symbolic        \
                        "${folder}"/Code/User/keybindings.json       \
                        "${APPDATA}"/Code/User
                fi
                ;;
            * )
                :
                ;;
        esac
    done

    inf "Setting up 'wget'.."
    do_rm --force            \
        "${HOME}"/.wgetrc    \
        "${HOME}"/.wget-hsts

    create --file                               \
        "${script_dir}"/.config/wget/.wget-hsts \
        "${script_dir}"/.config/wget/.wgetrc

    inf "Setting up 'less'.."
    do_rm --force "${HOME}"/.lesshst
    create --file "${script_dir}"/.config/less/.lesshst
}

function do_unset() {

    unset -v origin_cwd script_head script_name script_dir script_path      \
        script_params script_log script_loglevel script_tempdir             \
        script_tempfile IFS filter_type filter loglevels loglevel logcolors \
        logcolor logdate termlogformat filelogformat foreground do_exit i   \
        system
    unset -f script_init ctrl_c_trapper err_trapper exit_trapper help_usage  \
        help_full do_help critical error warning inf debug trace log do_grep \
        do_cd do_cp do_mv do_mkdir do_touch do_ln do_rm do_echo do_printf    \
        do_printf_n color check_binary validade_str do_countdown create main \
        arch wsl windows

    unset -f do_unset # Ensures this function is the last one to unset.
}

# Section: Main Program

function main() {

    script_init "${@}"
    cd "${script_dir}"

    if [[ "${#}" -lt 1 ]]; then
        main --help
        return 0
    fi

    local i
    for i in "${@}"; do
        case "${i}" in
            -h | help | --help )
                help_full
                return 0
                ;;
        esac
    done

    local system
    while [[ "${#}" -gt 0 ]]; do
        case "${1:-}" in
            -l | --log-file )
                shift
                validade_str "${1:-}" --exit
                [[ ! -f "${1}" ]]                             \
                    && do_mkdir --parents "$(dirname "${1}")" \
                    && do_touch "${1}"
                script_log="${1}"
                ;;
            -L | --log-level )
                shift
                if [[ ! "${1:-}" =~ ^(0|1|2|3|4|5)$ ]]; then
                    warning "Logging levels are: [0 (CRITICAL)] [1 (ERROR)] [2 (WARNING)] [3 (INFO)] [4 (DEBUG)] [5 (TRACE)]"
                    warning "Try './${script_name} --help' for more information."
                    exit 1
                fi
                script_loglevel="${1}"
                ;;
            -s | --system )
                shift
                if [[ ! "${1:-}" =~ ^(arch|wsl|windows)$ ]]; then
                    warning "Operational Systems are: [arch] [wsl] [windows]"
                    warning "Try './${script_name} --help' for more information."
                    exit 1
                fi
                system="${1}"
                ;;
            * )
                help_usage
                warning "Invalid or missing option '${1:-}' !"
                warning "Try './${script_name} --help' for more information."
                exit 1
                ;;
        esac
        shift
    done

    trace "Origin cwd: '${origin_cwd}'"
    trace "Header size: ${script_head}"
    trace "Script name: '${script_name}'"
    trace "Script directory: '${script_dir}'"
    trace "Script path: '${script_path}'"
    trace "Script param: '${script_params}'"
    trace "Script log file: '${script_log}'"
    trace "Script log level: ${script_loglevel}"
    trace "Temporary directory: '${script_tempdir}'"
    trace "Temporary file: '${script_tempfile}'"

    # Define script logic from here
    warning "Installing .dotfiles for '${system}'."
    do_countdown

    if [[ "${system}" == "arch" ]]; then
        arch
    fi

    if [[ "${system}" == "wsl" ]]; then
        wsl
    fi

    if [[ "${system}" == "windows" ]]; then
        windows
    fi
}

# Invoke main with args only if not sourced
if ! (return 0 2> /dev/null); then
    main "${@}"
fi
