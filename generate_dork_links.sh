#!/bin/bash

# Define GitHub, Google, and Shodan search URLs
declare -A GITHUB=(["start"]="https://github.com/search?q=%22" ["end"]="&type=Code")
declare -A GOOGLE=(["start"]="https://www.google.com/search?q=%22" ["end"]="&num=100")
declare -A SHODAN=(["start"]="https://www.shodan.io/search?query=%22" ["end"]="")

# Default directories and wordlists
TARGET=${TARGET:-$(pwd)}
DORKING=${DORKING:-"$TARGET/dorking"}
WORDLIST_GITHUB_DEFAULT=~/hack/resources/wordlists/dorking/dorking-github.txt
WORDLIST_GOOGLE_DEFAULT=~/hack/resources/wordlists/dorking/dorking-google.txt
WORDLIST_API_GITHUB_DEFAULT=~/hack/resources/wordlists/dorking/api-dorking-github.txt
WORDLIST_API_GOOGLE_DEFAULT=~/hack/resources/wordlists/dorking/api-dorking-google.txt

# Default Shodan wordlists
WORDLIST_SHODAN_DEFAULT=~/hack/resources/wordlists/dorking/shodan.txt
WORDLIST_API_SHODAN_DEFAULT=~/hack/resources/wordlists/dorking/api-shodan.txt

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
    local wordlist_file=$1
    local output_file=$2
    local dork_type=$3
    local org_name=$4

    if is_output_file_missing "$output_file"; then
        # Read from the wordlist_file and generate URLs
        while read -r line || [[ -n "$line" ]]; do
            # Skip empty lines
            [ -z "$line" ] && continue
            
            local dork_url
            if [ "$dork_type" == "github" ]; then
                dork_url="${GITHUB[start]}${line}%22+org:${org_name}${GITHUB[end]}"
            elif [ "$dork_type" == "google" ]; then
                dork_url="${GOOGLE[start]}${line}%22+site:${org_name}${GOOGLE[end]}"
            elif [ "$dork_type" == "shodan" ]; then
                dork_url="${SHODAN[start]}${line}+hostname:\"${org_name}\"${SHODAN[end]}"
            fi
            
            echo "$dork_url" >> "$output_file"
        done < "$wordlist_file"
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "
    Input Feed:
    -oR,  --organization <org>      Specify a single organization.
    -L,   --list <file>             Specify a file with a list of organizations.

    Output:
    -O,   --output <word>           Prepend a word to the output filenames.
    -oGh, --output-github <file>    Specify output file for GitHub links.
    -oGg, --output-google <file>    Specify output file for Google links.
    -oSh, --output-shodan <file>    Specify output file for Shodan links.

    Dorking types:
    -gH,  --github                  Generate GitHub dork links.
    -gG,  --google                  Generate Google dork links.
    -gS,  --shodan                  Generate Shodan links.
    -A,   --all                     Generate both GitHub and Google dork links.
    -aP,  --api                     Use API-specific wordlists.

    Custom Wordlist:
    -wGh, --wordlist-github <file>  Specify GitHub wordlist file.
    -wGg, --wordlist-google <file>  Specify Google wordlist file.
    -wSh, --wordlist-shodan <file>  Specify Shodan wordlist file.

    Help:
    -H,   --help                    Display this help message.
    "
}

main() {
    local dork_type="all"  # Default to generating both dork types
    local wordlist_github="$WORDLIST_GITHUB_DEFAULT"
    local wordlist_google="$WORDLIST_GOOGLE_DEFAULT"
    local wordlist_shodan="$WORDLIST_SHODAN_DEFAULT"
    local use_api_wordlists=false
    local output_prefix=""
    local org_name=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -gH|--github) dork_type="github" ;;
            -gG|--google) dork_type="google" ;;
            -gS|--shodan) dork_type="shodan" ;;
            -A|--all) dork_type="all" ;;
            -aP|--api) use_api_wordlists=true ;;
            -wGh|--wordlist-github) wordlist_github="$2"; shift ;;
            -wGg|--wordlist-google) wordlist_google="$2"; shift ;;
            -wSh|--wordlist-shodan) wordlist_shodan="$2"; shift ;;
            -oGh|--output-github) output_github="$2"; shift ;;
            -oGg|--output-google) output_google="$2"; shift ;;
            -oSh|--output-shodan) output_shodan="$2"; shift ;;
            -O|--output) output_prefix="$2"; shift ;;
            -oR|--organization) org_name="$2"; shift ;;
            -L|--list) org_name="$2"; shift ;;
            -H|--help) usage; exit 0 ;;
            *) echo "Error: Unrecognized option $1"; usage; exit 1 ;;
        esac
        shift
    done

    # Ensure either an organization or a list is provided
    if [ -z "$org_name" ]; then
        echo "Error: No organization or list provided."
        usage
        exit 1
    fi

    # Use API wordlists if the API flag is set
    if [ "$use_api_wordlists" = true ]; then
        wordlist_github="$WORDLIST_API_GITHUB_DEFAULT"
        wordlist_google="$WORDLIST_API_GOOGLE_DEFAULT"
        wordlist_shodan="$WORDLIST_API_SHODAN_DEFAULT"
    fi

    # Determine output filenames based on organization name or prefix
    if [ -n "$output_prefix" ]; then
        output_github="$DORKING/${output_prefix}_${org_name}_github_dork_links.txt"
        output_google="$DORKING/${output_prefix}_${org_name}_google_dork_links.txt"
        output_shodan="$DORKING/${output_prefix}_${org_name}_shodan_links.txt"
    else
        output_github="$DORKING/${org_name}_github_dork_links.txt"
        output_google="$DORKING/${org_name}_google_dork_links.txt"
        output_shodan="$DORKING/${org_name}_shodan_links.txt"
    fi

    # Check if org_name is a file or a single organization
    if [[ -f "$org_name" ]]; then
        while read -r org || [[ -n "$org" ]]; do
            # GitHub Links
            if [[ -f "$wordlist_github" ]]; then
                write_links "$wordlist_github" "$DORKING/${org}_github_dork_links.txt" "github" "$org"
            fi

            # Google Links
            if [[ -f "$wordlist_google" ]]; then
                write_links "$wordlist_google" "$DORKING/${org}_google_dork_links.txt" "google" "$org"
            fi

            # Shodan Links
            if [[ -f "$wordlist_shodan" ]]; then
                write_links "$wordlist_shodan" "$DORKING/${org}_shodan_links.txt" "shodan" "$org"
            fi

        done < "$org_name"
    else
        # Generate links for a single organization
        echo "Generating links for organization: $org_name"
        write_links "$wordlist_github" "$output_github" "github" "$org_name"
        write_links "$wordlist_google" "$output_google" "google" "$org_name"
        write_links "$wordlist_shodan" "$output_shodan" "shodan" "$org_name"
    fi
}

main "$@"
