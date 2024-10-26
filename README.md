# help

## color me 
```sh
Usage: color_me [color] 'text' or color_me -c [color] 'text'
Available colors: black 0;30 red 0;31 green 0;32 yellow 0;33 blue 0;34 magenta 0;35 cyan 0;36 white 0;37 gray 1;30 light_red 1;31 light_green 1;32 light_yellow 1;33 light_blue 1;34 light_magenta 1;35 light_cyan 1;36 light_gray 1;37 dark_gray 90 dark_red 91 dark_green 92 dark_yellow 93 dark_blue 94 dark_magenta 95 dark_cyan 96

```

## generate dork links
```sh
Usage: ./generate_dork_links.sh [OPTIONS] <keyword>

    Options:
    -gH, --github                Generate GitHub dork links.
    -gG, --google                Generate Google dork links.
    -A, --all                    Generate both GitHub and Google dork links.
    -wGh, --wordlist-github <file>  Specify GitHub wordlist file.
    -wGg, --wordlist-google <file>   Specify Google wordlist file.
    -oGh, --output-github <file>     Specify output file for GitHub links.
    -oGg, --output-google <file>      Specify output file for Google links.
    -h, --help                   Display this help message.
```

## message discord
```sh
Usage: message_discord [-f FILE | -s STRING | -h]
Options:
  -f, --file      Send a file message to Discord
  -s, --string    Send a string message to Discord
  -h, --help      Show this help message
```

