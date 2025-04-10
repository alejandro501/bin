#!/bin/bash

# Define GitHub, Google, Shodan, and Wayback search URLs
declare -A GITHUB=(["start"]="https://github.com/search?q=%22" ["end"]="&type=Code")
declare -A GOOGLE=(["start"]="https://www.google.com/search?q=%22" ["end"]="&num=100")
declare -A SHODAN=(["start"]="https://www.shodan.io/search?query=%22" ["end"]="")
declare -A WAYBACK=(["start"]="https://web.archive.org/web/*/" ["end"]="")

# Default directories and wordlists
TARGET=${TARGET:-$(pwd)}
DORKING=${DORKING:-"$TARGET/dorking"}

# general
WORDLIST_GITHUB_DEFAULT=~/hack/resources/wordlists/dorking/dorking-github.txt
WORDLIST_GOOGLE_DEFAULT=~/hack/resources/wordlists/dorking/dorking-google.txt
WORDLIST_SHODAN_DEFAULT=~/hack/resources/wordlists/dorking/shodan.txt

# api-specific
WORDLIST_API_GITHUB_DEFAULT=~/hack/resources/wordlists/dorking/api-dorking-github.txt
WORDLIST_API_GOOGLE_DEFAULT=~/hack/resources/wordlists/dorking/api-dorking-google.txt
WORDLIST_API_SHODAN_DEFAULT=~/hack/resources/wordlists/dorking/api-shodan.txt
WORDLIST_API_WAYBACK_DEFAULT=~/hack/resources/wordlists/dorking/api-wayback.txt

mkdir -p "$DORKING"

urlencode() {
    local input="$1"
    local encoded=""
    for ((i = 0; i < ${#input}; i++)); do
        char="${input:$i:1}"
        case "$char" in
        [a-zA-Z0-9.~_-]) encoded+="$char" ;;
        *) encoded+="$(printf '%%%02X' "'$char")" ;;
        esac
    done
    echo "$encoded"
}

is_output_file_missing() {
    if [ -f "$1" ]; then
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

            # URL encode the search term
            encoded_line=$(urlencode "$line")

            if [ "$dork_type" == "github" ]; then
                # Generate BOTH versions (org and in:url)
                org_url="${GITHUB[start]}${encoded_line}%22+org:${org_name}${GITHUB[end]}"
                inurl_url="${GITHUB[start]}${encoded_line}%22+%22${org_name}%22${GITHUB[end]}"
                echo "$org_url" >>"$output_file"
                echo "$inurl_url" >>"$output_file"
            elif [ "$dork_type" == "google" ]; then
                dork_url="${GOOGLE[start]}${encoded_line}%22+site:${org_name}${GOOGLE[end]}"
                echo "$dork_url" >>"$output_file"
            elif [ "$dork_type" == "shodan" ]; then
                dork_url="${SHODAN[start]}${encoded_line}+hostname:\"${org_name}\"${SHODAN[end]}"
                echo "$dork_url" >>"$output_file"
            elif [ "$dork_type" == "wayback" ]; then
                dork_url="${WAYBACK[start]}${org_name}%20${encoded_line}${WAYBACK[end]}"
                echo "$dork_url" >>"$output_file"
            fi
        done <"$wordlist_file"
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
    -oWb, --output-wayback <file>   Specify output file for Wayback links.

    Dorking types:
    -gH,  --github                  Generate GitHub dork links.
    -gG,  --google                  Generate Google dork links.
    -gS,  --shodan                  Generate Shodan links.
    -gW,  --wayback                 Generate Wayback Machine links.
    -A,   --all                     Generate all dork links.
    -aP,  --api                     Use API-specific wordlists.

    Custom Wordlist:
    -wGh, --wordlist-github <file>  Specify GitHub wordlist file.
    -wGg, --wordlist-google <file>  Specify Google wordlist file.
    -wSh, --wordlist-shodan <file>  Specify Shodan wordlist file.
    -wWb, --wordlist-wayback <file>  Specify Wayback wordlist file.

    Help:
    -H,   --help                    Display this help message.
    "
}

main() {
    local dork_type="all" # Default to generating all dork types
    local wordlist_github="$WORDLIST_GITHUB_DEFAULT"
    local wordlist_google="$WORDLIST_GOOGLE_DEFAULT"
    local wordlist_shodan="$WORDLIST_SHODAN_DEFAULT"
    local wordlist_wayback="$WORDLIST_API_WAYBACK_DEFAULT"
    local use_api_wordlists=false
    local output_prefix=""
    local org_name=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -gH | --github) dork_type="github" ;;
        -gG | --google) dork_type="google" ;;
        -gS | --shodan) dork_type="shodan" ;;
        -gW | --wayback) dork_type="wayback" ;;
        -A | --all) dork_type="all" ;;
        -aP | --api) use_api_wordlists=true ;;
        -wGh | --wordlist-github)
            wordlist_github="$2"
            shift
            ;;
        -wGg | --wordlist-google)
            wordlist_google="$2"
            shift
            ;;
        -wSh | --wordlist-shodan)
            wordlist_shodan="$2"
            shift
            ;;
        -wWb | --wordlist-wayback)
            wordlist_wayback="$2"
            shift
            ;;
        -oGh | --output-github)
            output_github="$2"
            shift
            ;;
        -oGg | --output-google)
            output_google="$2"
            shift
            ;;
        -oSh | --output-shodan)
            output_shodan="$2"
            shift
            ;;
        -oWb | --output-wayback)
            output_wayback="$2"
            shift
            ;;
        -O | --output)
            output_prefix="$2"
            shift
            ;;
        -oR | --organization)
            org_name="$2"
            shift
            ;;
        -L | --list)
            org_list_file="$2"
            shift
            ;;
        -H | --help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unrecognized option $1"
            usage
            exit 1
            ;;
        esac
        shift
    done

    # Validate input
    if [ -z "$org_name" ] && [ -z "$org_list_file" ]; then
        echo "Error: No organization or list provided."
        usage
        exit 1
    fi

    # Use API wordlists if the API flag is set
    if [ "$use_api_wordlists" = true ]; then
        wordlist_github="$WORDLIST_API_GITHUB_DEFAULT"
        wordlist_google="$WORDLIST_API_GOOGLE_DEFAULT"
        wordlist_shodan="$WORDLIST_API_SHODAN_DEFAULT"
        wordlist_wayback="$WORDLIST_API_WAYBACK_DEFAULT"
    fi

    # Function to process a single organization
    process_organization() {
        local org="$1"
        
        # Determine output filenames
        if [ -n "$output_prefix" ]; then
            local org_output_github="$DORKING/${output_prefix}_${org}_github_dork_links.txt"
            local org_output_google="$DORKING/${output_prefix}_${org}_google_dork_links.txt"
            local org_output_shodan="$DORKING/${output_prefix}_${org}_shodan_links.txt"
            local org_output_wayback="$DORKING/${output_prefix}_${org}_wayback_links.txt"
        else
            local org_output_github="$DORKING/${org}_github_dork_links.txt"
            local org_output_google="$DORKING/${org}_google_dork_links.txt"
            local org_output_shodan="$DORKING/${org}_shodan_links.txt"
            local org_output_wayback="$DORKING/${org}_wayback_links.txt"
        fi

        case "$dork_type" in
            "all")
                [ -f "$wordlist_github" ] && write_links "$wordlist_github" "$org_output_github" "github" "$org"
                [ -f "$wordlist_google" ] && write_links "$wordlist_google" "$org_output_google" "google" "$org"
                [ -f "$wordlist_shodan" ] && write_links "$wordlist_shodan" "$org_output_shodan" "shodan" "$org"
                [ -f "$wordlist_wayback" ] && write_links "$wordlist_wayback" "$org_output_wayback" "wayback" "$org"
                ;;
            "github")
                [ -f "$wordlist_github" ] && write_links "$wordlist_github" "$org_output_github" "github" "$org"
                ;;
            "google")
                [ -f "$wordlist_google" ] && write_links "$wordlist_google" "$org_output_google" "google" "$org"
                ;;
            "shodan")
                [ -f "$wordlist_shodan" ] && write_links "$wordlist_shodan" "$org_output_shodan" "shodan" "$org"
                ;;
            "wayback")
                [ -f "$wordlist_wayback" ] && write_links "$wordlist_wayback" "$org_output_wayback" "wayback" "$org"
                ;;
        esac
    }

    # Process either single organization or list file
    if [ -n "$org_list_file" ] && [ -f "$org_list_file" ]; then
        while read -r org || [[ -n "$org" ]]; do
            [ -z "$org" ] && continue  # Skip empty lines
            process_organization "$org"
        done < "$org_list_file"
    else
        process_organization "$org_name"
    fi
}

main "$@"

