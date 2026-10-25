#!/bin/bash

# === SteerWise Header Scaffolder ===

# To run this script, use the command:
# ./scripts/scaffold.sh [dart|md] [optional: filenames...]


# Purpose:
# This script adds a header to files in the SteerWise project.
# It checks if the header already exists and only adds it if it doesn't.
# The script is designed to be run from the root of the project directory.

# Usage:
# Add headers to all Dart/Markdown files:
#   ./scripts/scaffold.sh dart
#   ./scripts/scaffold.sh md

# Add header to specific files (this is how the pre-commit hooks call it):
#   ./scripts/scaffold.sh dart path/to/file.dart path/to/other.dart
#   ./scripts/scaffold.sh md path/to/file.md


# === CONFIG ===
OVERVIEW="SteerWise - Smart Driving Practice App"
REPO_URL="https://github.com/ASPTechInc/SteerWise"
COPYRIGHT="Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved."
LICENSE="Licensed under the MIT License (see LICENSE)."

# === HEADER GENERATORS ===

dart_header() {
cat <<EOF
/// ------------------------------------------------------------------------
/// $OVERVIEW
/// $REPO_URL
///
/// $COPYRIGHT
/// $LICENSE
/// ------------------------------------------------------------------------
library;

EOF
}

md_header() {
cat <<EOF
# $OVERVIEW

**File:** [$FILENAME]($REPO_URL/blob/main/$FILE_DIRNAME/$FILENAME)

**Repo:** [$REPO_URL]($REPO_URL)

$COPYRIGHT

$LICENSE

---
EOF
}

# === APPLY HEADER TO FILE ===

apply_header() {
  local file=$1
  local extension=$2
  local current_header

  case "$extension" in
    dart)
      current_header="/// SteerWise"
      ;;
    md)
      current_header="# SteerWise"
      ;;
    *)
      echo "Warning: unsupported file type: $extension"
      return
      ;;
  esac

  if grep -q "$current_header" "$file"; then
    echo "Header already exists in $file"
  else
    case "$extension" in
      dart)
        { dart_header; cat "$file"; } > temp && mv temp "$file"
        ;;
      md)
        FILENAME=$(basename "$file")
        FILE_DIRNAME=$(dirname "$file")
        FILE_DIRNAME=${FILE_DIRNAME#./}
        eval "md_header" > temp
        echo "" >> temp
        cat "$file" >> temp
        mv temp "$file"
        ;;
    esac
    echo "Header added to $file"
  fi
}

# === MAIN ENTRY ===

TYPE=$1
shift || true

if [ -z "$TYPE" ]; then
  echo "Usage: ./scripts/scaffold.sh [dart|md] [optional: filenames...]"
  exit 1
fi

if [[ "$TYPE" != "dart" && "$TYPE" != "md" ]]; then
  echo "Error: only 'dart' and 'md' file types are supported."
  exit 1
fi

# Specific files
if [ "$#" -gt 0 ]; then
  for file in "$@"; do
    apply_header "$file" "$TYPE"
  done
else
  # All matching files
  echo "Scanning for *.$TYPE files..."
  # Skip hidden directories (.git, .dart_tool, .github), build output and
  # generated platform code.
  find . \( -path '*/.*' -o -path ./build -o -path ./android -o -path ./ios \
    -o -path ./linux -o -path ./macos -o -path ./windows -o -path ./web \) -prune \
    -o -type f -name "*.$TYPE" -print | while read -r file; do
    apply_header "$file" "$TYPE"
  done
fi
