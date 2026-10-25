#!/bin/bash

# Purpose:
# This script logs errors with timestamps to a log
# file in the logs directory.

# Usage:
# chmod +x ./scripts/log-errors.sh
# ./scripts/log-errors.sh

# Example:
# ./scripts/log-errors.sh "An error occurred while processing the request."
# ./scripts/log-errors.sh clear
# ./scripts/log-errors.sh --help

# Function to display help
show_help() {
  echo "Usage: ./scripts/log-errors.sh [message|clear|--help]"
  echo ""
  echo "Options:"
  echo "  message    Log the provided error message with a timestamp"
  echo "  clear      Delete all logs and the logs directory"
  echo "  --help     Show this help message"
  exit 0
}

# Function to find the root directory by searching for the .git directory
find_root_dir() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/.git" ]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo "Error: .git directory not found."
  exit 1
}

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Find the root directory
ROOT_DIR=$(find_root_dir "$SCRIPT_DIR")

# Define log directory and file
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/$(date +'%Y-%m-%d').txt"

# Handle arguments
case "$1" in
  --help)
    show_help
    ;;
  clear)
    echo "Clearing logs directory at: $LOG_DIR"
    rm -rf "$LOG_DIR"
    echo "Logs directory deleted."
    exit 0
    ;;
  "")
    echo "Error: No message provided. Use --help for usage."
    exit 1
    ;;
esac

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log errors with timestamp
log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: $1" >> "$LOG_FILE"
}

# Example usage if this script is called with an argument
if [ "$1" ]; then
  log_error "$1"
fi
