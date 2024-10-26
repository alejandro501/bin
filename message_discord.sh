#!/bin/bash

WEBHOOK_URL=$(grep "discord_webhook" $HOME/config/credentials.conf | cut -d "=" -f2 | tr -d '[:space:]')

send_string() {
      curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$1\"}" $WEBHOOK_URL

      if [ $? -eq 0 ]; then
        color_me dark_magenta "String message sent successfully."
      else
        dark_magenta "Error sending string message."
      fi
}

    # Function to send file as a message
    send_file() {
      curl -H "Content-Type: multipart/form-data" -F "file=@$1" $WEBHOOK_URL

      if [ $? -eq 0 ]; then
        echo "File message sent successfully."
      else
        echo "Error sending file message."
      fi
    }

help_message() {
  echo "Usage: message_discord [-f FILE | -s STRING | -h]"
  echo "Options:"
  echo "  -f, --file      Send a file message to Discord"
  echo "  -s, --string    Send a string message to Discord"
  echo "  -h, --help      Show this help message"
}

main() {
    if [ $# -eq 0 ]; then
      send_string "$1"
    else
      while [ $# -gt 0 ]; do
        case "$1" in
          -f|--file)
            send_file "$2"
            shift 2
            ;;
          -s|--string)
            send_string "$2"
            shift 2
            ;;
          -h|--help)
            help_message
            exit 0
            ;;
          *)
            send_string "$1"
            shift 1
            ;;
        esac
      done
    fi
}
main "$@"