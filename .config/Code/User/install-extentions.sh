#!/bin/bash
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
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o nounset   # Exposes unset variables
set -o pipefail  # Unveils hidden failures
set +o xtrace    # Trace what gets executed (Debug)
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
script_path="$(dirname "${0}")"; readonly script_path

# Other functions

# shellcheck disable=SC2317
function ctrl_c() {
    # echo "** Trapped CTRL-C"
    exit 0
}

# Main Program
function main() {

    while IFS="" read -r p || [ -n "${p}" ]; do
        printf "\n%bInstalling Extention '%s' %b\n" \
            "${yellow}" "${p}" "${nc}"
        sleep 1
        code --install-extension "${p}" > /dev/null 2>&1      \
        && printf "%bInstalled !%b\n" "${green}" "${nc}"      \
        || printf "%bExtention '%s' didn't get installed%b\n" \
            "${red}" "${p}" "${nc}"
    done < extentions.txt
}

cd "${script_path}"  # cd to executable path
main
