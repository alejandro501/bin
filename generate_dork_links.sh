#!/bin/bash

# Define GitHub and Google search URLs
declare -A GITHUB=(["start"]="https://github.com/search?q=%22" ["end"]="&type=Code")
declare -A GOOGLE=(["start"]="https://www.google.com/search?q=%22" ["end"]="&num=100")

# Default directories and wordlists
TARGET=${TARGET:-$(pwd)}
DORKING=${DORKING:-"$TARGET/dorking"}
WORDLIST_GITHUB_DEFAULT=~/hack/resources/wordlists/dorking/dorking-github.txt
WORDLIST_GOOGLE_DEFAULT=~/hack/resources/wordlists/dorking/dorking-google.txt
WORDLIST_API_GITHUB_DEFAULT=~/hack/resources/wordlists/dorking/api-dorking-github.txt
WORDLIST_API_GOOGLE_DEFAULT=~/hack/resources/wordlists/dorking/api-dorking-google.txt

mkdir -p "$DORKING"

is_output_file_missing() {
    if [ -f "$1" ]; then
        echo "" > "$1" 
        return 1
    else
        return 0
    fi
}

write_links() {
    local keyword=$1
    local wordlist_file=$2
    local output_file=$3
    local dork_type=$4

    if is_output_file_missing "$output_file"; then
        while read -r line; do
            local dork_url
            if [ "$dork_type" == "github" ]; then
                dork_url="${GITHUB[start]}${keyword}%22+${line}${GITHUB[end]}"
            else
                dork_url="${GOOGLE[start]}${keyword}%22+${line}${GOOGLE[end]}"
            fi
            echo "$dork_url" >> "$output_file"
        done < "$wordlist_file"
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS] <keyword>"
    echo "
    Options:
    -gH,  --github                  Generate GitHub dork links.
    -gG,  --google                  Generate Google dork links.
    -A,   --all                     Generate both GitHub and Google dork links.
    -aP,  --api                     Use API-specific wordlists.
    -wGh, --wordlist-github <file>  Specify GitHub wordlist file.
    -wGg, --wordlist-google <file>  Specify Google wordlist file.
    -oGh, --output-github <file>    Specify output file for GitHub links.
    -oGg, --output-google <file>    Specify output file for Google links.
    -H,   --help                    Display this help message.
    "
}

main() {
    local dork_type="all"  # Default to generating both dork types
    local keyword=""
    local wordlist_github="$WORDLIST_GITHUB_DEFAULT"
    local wordlist_google="$WORDLIST_GOOGLE_DEFAULT"
    local output_github="$DORKING/github_dork_links.txt"
    local output_google="$DORKING/google_dork_links.txt"
    local use_api_wordlists=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -gH|--github) dork_type="github" ;;
            -gG|--google) dork_type="google" ;;
            -A|--all) dork_type="all" ;;
            -aP|--api) use_api_wordlists=true ;;
            -wGh|--wordlist-github) wordlist_github="$2"; shift ;;
            -wGg|--wordlist-google) wordlist_google="$2"; shift ;;
            -oGh|--output-github) output_github="$2"; shift ;;
            -oGg|--output-google) output_google="$2"; shift ;;
            -H|--help) usage; exit 0 ;;
            *) keyword="$1" ;;
        esac
        shift
    done

    if [ -z "$keyword" ]; then
        echo "Error: No keyword provided."
        usage
        exit 1
    fi

    # Use API wordlists if the API flag is set
    if [ "$use_api_wordlists" = true ]; then
        wordlist_github="$WORDLIST_API_GITHUB_DEFAULT"
        wordlist_google="$WORDLIST_API_GOOGLE_DEFAULT"
    fi

    if [ "$dork_type" == "github" ] || [ "$dork_type" == "all" ]; then
        write_links "$keyword" "$wordlist_github" "$output_github" "github"
    fi
    if [ "$dork_type" == "google" ] || [ "$dork_type" == "all" ]; then
        write_links "$keyword" "$wordlist_google" "$output_google" "google"
    fi
}

main "$@"
