#!/bin/bash

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
#    printf "'%b' 'TEXT' '%s' '%b'\n" "${color}" "${var}" "${reset}"

# msextentions=("ms-vscode-remote.vscode-remote-extensionpack visualstudioexptteam.vscodeintellicode ms-dotnettools.csharp ms-vscode.cpptools")

while IFS="" read -r p || [ -n "${p}" ]; do
    # if [[ "${msextentions[*]}" =~ "${p}" ]]; then
    #     # whatever you want to do when array contains value
    #     printf "\n%bInstall Extention '%s' Manually%b\n" "${purple}" "${p}" "${reset}" ; sleep 1
    #     xdg-open https://marketplace.visualstudio.com/items?itemName="${p}"
    # elif [[ ! "${msextentions[*]}" =~ "${p}" ]]; then
          # whatever you want to do when array doesn't contain value
          printf "\n%bInstalling Extention '%s' %b\n" "${yellow}" "${p}" "${reset}" ; sleep 1
          code --install-extension "${p}" > /dev/null 2>&1 && printf "%bInstalled !%b\n" "${green}" "${reset}" || printf "%bExtention '%s' didn't get installed%b\n" "${red}" "${p}" "${reset}"
    # fi
done < "${PWD}"/.linux/.config/Code/User/extentions.txt
