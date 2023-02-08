#!/bin/bash

#===============================================================================
# HEADER
#===============================================================================
#%
#% NAME
#%    This is a shellscript template.
#%
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-h] [-opt[str]] args ...
#%
#% DESCRIPTION
#%    This is a shellscript template.
#%
#% OPTIONS
#%    -h, --help                    Print this help
#%
#%    -opt1, --option-1                OPTION 1
#%    -opt2, --option-2                OPTION 2
#%
#% EXAMPLE
#%    ${SCRIPT_NAME} --help
#%    ${SCRIPT_NAME} --option
#%
#===============================================================================
#/ IMPLEMENTATION
#/    Version         ${SCRIPT_NAME} (www.gnsilva.com) 1.0
#/    Author          Gabriel Nascimento
#/    Copyright       Copyright (c) http://www.gnsilva.com
#/    License         GNU General Public License
#/
#===============================================================================
# DEBUG OPTIONS
    set +o noexec  # Don't execute commands (Ignored by interactive shells)
    set +o xtrace  # Trace what gets executed (DEBUG)
#
#===============================================================================
# OPTIONS
    set -o nounset    # Exposes unset variables
    set -o errexit    # Used to exit upon error, avoiding cascading errors
    set -o pipefail   # Unveils hidden failures
    set -o noclobber  # Avoid overwriting files (echo "hi" > foo)
    set -o errtrace   # Inherit trap on ERR to functions, commands and etc.
    shopt -s nullglob    # Non-matching globs are removed ('*.foo' => '')
    shopt -s failglob    # Non-matching globs throw errors
    shopt -u nocaseglob  # Case insensitive globs
    shopt -s dotglob     # Wildcards match hidden files ("*.sh" => ".foo.sh")
    shopt -s globstar    # Allow recursive matches ('a/**/*.rb' => 'a/b/c/d.rb')
    IFS=$'\n\t'
#
#===============================================================================
# TRAPS
    trap err_trapper ERR     # Trap ERR and call err_trapper
    trap ctrl_c_trapper INT  # Trap CTRL_C and call ctrl_c
    trap exit_trapper EXIT   # Trap EXIT and call exit_trapper
    trap "" SIGTSTP          # Disable CTRL_Z
#
#===============================================================================
# COLORS
    CYAN='\033[0;36m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    PURPLE='\033[0;35m'
    BLUE='\033[0;34m'
    LIGHT_GRAY='\033[0;37m'
    GREEN='\033[0;32m'
    NC='\033[0m'
#
#===============================================================================
# END_OF_HEADER
#===============================================================================

# Variable Definitions
SCRIPT_HEAD=$(grep -sn "^# END_OF_HEADER" "${0}" | head -1 | cut -f1 -d:)
SCRIPT_NAME="$(basename "${0}")"
SCRIPT_DIR="$(\cd "$(dirname "${0}")" && \pwd )"
SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_NAME}"

SCRIPT_LOG="/dev/null"

SCRIPT_TEMPDIR=$(mktemp -d -t tmp.XXXXXXXXXX)
SCRIPT_TEMPFILE=$(mktemp -t tmp.XXXXXXXXXX)

# Functions

# shellcheck disable=SC2317
function err_trapper() {

    local EXITCODE="${?}"

    do_print "${RED}ERROR ${EXITCODE}: [$(date +'%d-%m-%Y %H:%M:%S')] An exception ocurred near line ${BASH_LINENO[0]} !" >&2
    exit "${EXITCODE}"
}

# shellcheck disable=SC2317
function ctrl_c_trapper() {

    local EXITCODE="${?}"

    do_print "${RED}Interrupt signal intercepted! Exiting now..." | tee --append "${SCRIPT_LOG:-/dev/null}" >&2
    exit "${EXITCODE}"
}

# shellcheck disable=SC2317
function exit_trapper {

    local EXITCODE="${?}"

    rm --recursive --force   \
        "${SCRIPT_TEMPDIR}"  \
        "${SCRIPT_TEMPFILE}"
    do_unset
    exit "${EXITCODE}"
}

function help_usage() {
    printf "Usage: "
    do_help "usg"
}

function help_full() {
    do_help "ful"
}

function do_help() {

    local FILTER

    if [[ "${1}" == "usg" ]]; then FILTER="^#+[ ]*"; fi
    if [[ "${1}" == "ful" ]]; then FILTER="^#[%+]" ; fi

    head -"${SCRIPT_HEAD:-99}" "${0}" | grep --regexp="${FILTER:-y^#-}" | sed \
        --expression="s/${FILTER:-^#-}//g" \
        --expression="s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"
}

function do_cp() {
    \cp "${@}"
}

function do_mkdir() {
    \mkdir "${@}"
}

function do_touch() {
    \touch "${@}"
}

function do_mv() {
    \mv "${@}"
}

function do_ln() {
    \ln "${@}"
}

function do_echo() {
    \echo "${@}"
}

function do_print() {
    printf "%b\n%b" "${*}" "${nc:-}"
}

function do_rm() {
    \rm --force --recursive --verbose "${@}"
}

function do_err() {
    >&2 do_print "${@}"
}

function do_unset() {
    unset -v CYAN RED YELLOW PURPLE BLUE LIGHT_GRAY GREEN NC
}

function main() {

    cd "${SCRIPT_DIR}"

    while true; do
        case "${1:--h}" in
            -h | --help )
                help_fulla
                exit
                ;;
            -a | --arch )
                :
                ;;
            -wsl | --wsl )
                :
                ;;
            -w | --windows )
                :
                ;;
            * )
                help_usage
                do_err "Invalid option !"
                do_err "Try './${SCRIPT_NAME} --help' for more information."
                exit "${?}"
                ;;
        esac
    done
}

main "${@}"
