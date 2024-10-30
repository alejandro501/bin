#!/bin/bash

# Load Shodan API key
API_KEY=$(grep 'API_KEY' /home/rojo/.config/.sol/shodan.env | cut -d '=' -f2)
if [[ -z "$API_KEY" ]]; then
    echo "Error: Shodan API key not found in /home/rojo/.config/.sol/shodan.env"
    exit 1
fi

# Global Variables
TARGET_ORGANIZATION=''
ORGANIZATION_LIST=()
WORDLIST_SHODAN_DEFAULT=~/hack/resources/wordlists/dorking/shodan.txt
WORDLIST_API_SHODAN_DEFAULT=~/hack/resources/wordlists/dorking/api-shodan.txt
USE_API_WORDLIST=false
DORKING_DIR="$(pwd)/dorking"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "
    Input:
    -oR,  --org <org>                Specify a single organization.
    -L,   --list <file>              Specify a file with a list of organizations.

    Output:
    -wL,  --wordlist <file>          Specify a custom wordlist file (default: $WORDLIST_SHODAN_DEFAULT).

    Specified queries:
    --aP, --api                      Use API-specific wordlist (default: $WORDLIST_API_SHODAN_DEFAULT).

    Help:
    -H,   --help                     Display this help message.
    "
}

get_params() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -oR|--org) TARGET_ORGANIZATION="$2"; shift ;;
            -L|--list) ORGANIZATION_LIST_FILE="$2"; shift ;;
            -wL|--wordlist) WORDLIST="$2"; shift ;;
            --aP|--api) USE_API_WORDLIST=true ;;
            -H|--help) usage; exit 0 ;;
            *) echo "Unknown parameter: $1"; exit 1 ;;
        esac
        shift
    done
}

query_shodan() {
    local org=$1
    local wordlist=$2

    mkdir -p "$DORKING_DIR"

    while IFS= read -r query; do
        local formatted_query=$(echo "$query" | tr ' ' '_')
        local output_file="$DORKING_DIR/${org}_${formatted_query}_shodan.json"
        local url="https://api.shodan.io/shodan/host/search?key=${API_KEY}&query=hostname:${org}+${query}"

        echo "Searching Shodan for organization '$org' with query 'hostname:${org} ${query}'..."
        response=$(curl -s "$url")
        
        if [[ -z "$response" ]]; then
            echo "No response for query '$query' on '$org'"
        else
            echo "$response" > "$output_file"
            echo "Saved response to $output_file"
        fi
    done < "$wordlist"
}

main() {
    get_params "$@"

    if [[ "$USE_API_WORDLIST" == true ]]; then
        WORDLIST="$WORDLIST_API_SHODAN_DEFAULT"
    elif [[ -z "$WORDLIST" ]]; then
        WORDLIST="$WORDLIST_SHODAN_DEFAULT"
    fi

    # Validate input feed
    if [[ -n "$TARGET_ORGANIZATION" ]]; then
        query_shodan "$TARGET_ORGANIZATION" "$WORDLIST"
    elif [[ -n "$ORGANIZATION_LIST_FILE" ]]; then
        while IFS= read -r org; do
            query_shodan "$org" "$WORDLIST"
        done < "$ORGANIZATION_LIST_FILE"
    else
        echo "No organization specified."
        usage
        exit 1
    fi
}

main "$@"
