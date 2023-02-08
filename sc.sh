#!/bin/bash
# Main Program
function main() {
    # Get Options
    while [[ "${1}" =~ ^- && ! "${1}" == "--" ]]; do
        case ${1} in
            -v | --version )
                echo "${version:-}"
                exit
                ;;
            -s | --string )
                shift; string=${1}
                ;;
            -f | --flag )
                flag=1
                ;;
        esac
        shift
    done
    if [[ "${1}" == '--' ]]; then
        shift
    fi
}

main "${@}"
