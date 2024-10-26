#!/bin/bash

colors=(
  "black"        "0;30"
  "red"          "0;31"
  "green"        "0;32"
  "yellow"       "0;33"
  "blue"         "0;34"
  "magenta"      "0;35"
  "cyan"         "0;36"
  "white"        "0;37"
  "gray"         "1;30"
  "light_red"    "1;31"
  "light_green"  "1;32"
  "light_yellow" "1;33"
  "light_blue"   "1;34"
  "light_magenta" "1;35"
  "light_cyan"   "1;36"
  "light_gray"   "1;37"
  "dark_gray"    "90"
  "dark_red"     "91"
  "dark_green"   "92"
  "dark_yellow"  "93"
  "dark_blue"    "94"
  "dark_magenta" "95"
  "dark_cyan"    "96"
)

# Function to display text in a specific color
color_me() {
    color=$1
    string=$2
    color_index=0
    for i in "${colors[@]}"
    do
        if [[ $i == $color ]]; then
            color_index=$(($color_index + 1))
            break
        fi
        color_index=$(($color_index + 1))
    done

    if [[ $color_index -eq ${#colors[@]} ]]; then
        echo "Invalid color $color_index. Available colors: ${colors[@]}"
    else
        echo -e "\033[${colors[$color_index]}m$string\033[0m"
    fi
}

# Get the input color and string
while [ $# -gt 0 ]; do
    case "$1" in
        -c|--color)
            color=$2
            shift 2
            ;;
        -h|--help)
            echo "Usage: color_me [color] 'text' or color_me -c [color] 'text'"
            echo "Available colors: ${colors[@]}"
            shift
            exit 0
            ;;
        *)
            color=$1
            string=$2
            shift 2
            ;;
    esac
done

color_me $color "$string"
