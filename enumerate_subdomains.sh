#!/bin/bash

OUTPUT_FILE="subdomains"

usage() {
    echo "Usage: $0 [OPTIONS] -I <input_file>"
    echo "
    Options:
    -I, --input <file>      Specify input file (mandatory, eg. wildcards).
    -O, --output <file>     Specify output file for results (default: $OUTPUT_FILE).
    -H, --help              Display this help message.
    "
}

check_input_file() {
    if [ ! -f "$1" ]; then
        echo "The input file '$1' does not exist."
        exit 1
    fi
}

check_file_empty() {
    if [ ! -s "$1" ]; then
        echo "Warning: The input file '$1' is empty, skipping enumeration."
        exit 0
    fi
}

main() {
    local INPUT_FILE=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -I|--input) INPUT_FILE="$2"; shift ;;
            -O|--output) OUTPUT_FILE="$2"; shift ;;
            -H|--help) usage; exit 0 ;;
            *) echo "Error: Invalid option '$1'."; usage; exit 1 ;;
        esac
        shift
    done

    if [ -z "$INPUT_FILE" ]; then
        echo "Error: No input file provided."
        usage
        exit 1
    fi

    check_input_file "$INPUT_FILE"
    check_file_empty "$INPUT_FILE"

    echo "Starting subdomain enumeration..."
    
    subfinder -dL "$INPUT_FILE" | httprobe --prefer-https | anew "$OUTPUT_FILE"

    echo "Subdomain enumeration completed."
    echo "Results saved in '$OUTPUT_FILE'."
}

main "$@"
