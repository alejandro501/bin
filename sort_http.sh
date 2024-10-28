#!/bin/bash

PREPEND=""
HELP=false

usage() {
    echo "Usage: $0 -I <input_file> [-O <prepend>]"
    echo "  -I, --input    Input file containing subdomains (required)"
    echo "  -O, --output   Optional prepend for output files (default: none)"
    echo "  -h, --help     Display this help message"
}

# args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -I|--input) input="$2"; shift ;;
        -O|--output) PREPEND="$2"; shift ;;
        -h|--help) HELP=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ $HELP == true || -z "$input" ]]; then
    usage
    exit 0
fi

while read -r sub; do
    code=$(curl -o /dev/null -s -w "%{http_code}" "$sub")
    if [[ -n "$PREPEND" ]]; then
        echo "$sub" >> "${PREPEND}_${code}"
    else
        echo "$sub" >> "${code}"
    fi
done < "$input"
