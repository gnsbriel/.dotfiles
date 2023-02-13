#!/bin/bash

#==============================================================================
# HEADER
#==============================================================================
#%
#% NAME
#%    Install code extentions
#%
#% SYNOPSIS
#+    ${script_name}
#%
#% DESCRIPTION
#%    This shell script will install all code extentions listed in the file
#%    'extentions.txt'.
#%
#% EXAMPLE
#%    ${script_name}
#%
#===============================================================================
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

    origin_cwd="${PWD}"

    script_head=$(grep --no-messages --line-number "^# END_OF_HEADER" "${0}" | head -1 | cut --fields=1 --delimiter=:)
    script_name="$(basename "${0}")"
    script_dir="$(cd "$(dirname "${0}")" && \pwd )"
    script_path="${script_dir}/${script_name}"
    script_params="${*}"

    script_log="${script_name}-$(date +"%Y-%m-%d %H:%M:%S").log" # default is '/dev/null'
    script_loglevel=3  # default is 3

    script_tempdir=$(mktemp --directory -t tmp.XXXXXXXXXX)
    script_tempfile=$(mktemp -t tmp.XXXXXXXXXX)

    #IFS=$'\n\t'
}

# shellcheck disable=SC2317
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

    do_cd "${origin_cwd}" || warning "Couldn't cd back to '${origin_cwd}'"

    do_rm --recursive --force "${script_tempdir}"        \
        || warning "Couldn't remove '${script_tempdir}'"
    do_rm --recursive --force "${script_tempfile}"        \
        || warning "Couldn't remove '${script_tempfile}'"

    do_unset

    exit "${exitcode}"
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
    logdate=$(date +"%Y/%m/%d %H:%M:%S")

    termlogformat="[${logdate}] ${logcolor}[${loglevel}]$(color nc) ${2}"
    filelogformat="[${logdate}] [${loglevel}] > ${FUNCNAME[3]} | ${2}"

    if [[ "${script_loglevel}" -ge "${1}" ]]; then
        do_printf "${termlogformat}"
    fi

    do_echo "${filelogformat}" | fold -w79 -s | sed '2~1s/^/  /' >> "${script_log:-/dev/null}"
}

# shellcheck disable=SC2015
function do_cd() {

    command cd "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'cd ${*}'"                 \
        || error "'cd ${*}' failed near line ${BASH_LINENO[0]}!"
}

# shellcheck disable=SC2015
function do_rm() {

    command rm "${@}"                                            \
        && debug "(${BASH_LINENO[0]}) 'rm ${*}'"                 \
        || error "'rm ${*}' failed near line ${BASH_LINENO[0]}!"
}

function do_echo() {

    command printf "%s\n" "${*}" 2>/dev/null
}

function do_printf() {

    command printf "%b%b\n" "${*}" "$(color nc)" 2>/dev/null
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

function do_unset() {

    unset -v origin_cwd script_head script_name script_dir script_path \
        script_params script_log script_loglevel script_tempdir        \
        script_tempfile loglevels loglevel logcolors logcolor logdate  \
        termlogformat filelogformat foreground p
    unset -f script_init ctrl_c_trapper err_trapper exit_trapper critical \
        error warning inf debug trace log do_cd do_rm do_echo do_printf   \
        color main

    unset -f do_unset # this ensures the 'do_unset' function is the last one.
}

# Section: Main Program

# shellcheck disable=SC2015
function main() {

    script_init "${@}"
    cd "${script_dir}"

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

    while IFS="" read -r p || [ -n "${p}" ]; do
        inf "Installing Extention ${p}.."
        sleep 1
        code --install-extension "${p}" > /dev/null 2>&1   \
            && inf "Installed !"                           \
            || error "Extention ${p} didn't get installed"
    done < extentions.txt
}

# Invoke main with args only if not sourced
if ! (return 0 2> /dev/null); then
    main "${@}"
fi
