# shellcheck shell=bash

# If not running interactively, don't do anything
[[ "${-}" != *i* ]] && return

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# History Customization
HISTCONTROL=ignoredups # Ignore duplicates for ".bash_history"
HISTSIZE=10000 # Maximum line size for ".bash_history"
HISTFILESIZE=10000 # Maximum line size for ".bash_history"
HISTFILE="${HOME}"/.config/bash/.bash_history # ".bash_history" file location
shopt -s histappend # Append commands to ".bash_history"
shopt -s checkwinsize # Line wrap on window resize

# Tweaks
shopt -s autocd

# This updates .bash_history after every command
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND}$'\n'}history -a; history -c; history -r"

# Set a fancy prompt (non-color, unless we know we "want" color)
case "${TERM}" in
    xterm-color|*-256color)
        color_prompt=yes
        ;;
esac

# force_color_prompt=yes
if [ -n "${force_color_prompt}" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Tab Suggestions, Completions, Aliases and Source Files

# Aliases
if [ ! "${EUID:-$(id -u)}" -eq 0 ]; then
    source "${HOME}"/.config/bash/.bash_aliases
fi

# Git
if [ ! "${EUID:-$(id -u)}" -eq 0 ]; then
    source "${HOME}"/.config/git/git-prompt.sh
    source "${HOME}"/.config/git/git-completion.bash
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Custom PS1
if [ "${color_prompt}" = yes ]; then
    PS1='\
\[\e[0;37m\]\n\[\e[0m\]\
\[\e[1;3;33m\]$(__git_ps1 " שׂ %s")\[\e[0m\]\
\[\e[0;37m\]\n\[\e[0m\]\
${debian_chroot:+($debian_chroot)}\
\[\e[0;1;37m\] >\[\e[0m\]\
\[\e[0;1;37m\]_ \[\e[0m\]\
'
else
    PS1='\n$(__git_ps1 " שׂ %s")\n${debian_chroot:+($debian_chroot)}>_ '
fi

unset color_prompt force_color_prompt

export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"                    # This loads nvm
[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion

# Run pfetch on every instance
printf "\n"
pfetch

if ! groups "${USER}" | grep -q i2c; then
    printf "\n Consider adding \"%s\" to \"i2c\" group.\n     $ sudo usermod --append --groups i2c %s \n" "${USER}" "${USER}"
fi
