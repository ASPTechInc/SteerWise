#!/bin/bash

# Purpose
# This script converts Markdown files to HTML files.
# It can process a single file or all Markdown files in a directory.

# Usage:
# ./scripts/md-to-html.sh <input_file_or_dir> <output_dir>

# Permissions:
# chmod +x ./scripts/md-to-html.sh


# Example
# Single file to single HTML file
# ./scripts/md-to-html.sh docs/md/project-setup.md docs/html/project-setup.html

# Single file to folder (auto name)
# ./scripts/md-to-html.sh docs/md/project-setup.md docs/html

# All .md files in folder
# ./scripts/md-to-html.sh docs/md docs/html

echo "Running Markdown to HTML converter using pandoc..."

set -e

INPUT="$1"
OUTPUT="$2"

# Determine web page title
get_title_from_filename() {
  local filename=$(basename "$1" .md)
  local title=$(echo "$filename" | sed 's/-/ /g' | awk '{ for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print }')
  echo "$title"
}

# HTML wrappers
HTML_HEAD="<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1'>
  <title>{{TITLE}} | SteerWise Documentation</title>
  <style>
    body { font-family: sans-serif; margin: 40px; max-width: 800px; }
    code { background: #f5f5f5; padding: 2px 4px; border-radius: 3px; }
    pre code { display: block; padding: 10px; overflow-x: auto; }
    h1, h2, h3 { color: #333; }
  </style>
</head>
<body>"

HTML_FOOT="</body></html>"

# Ensure pandoc is available
if ! command -v pandoc &> /dev/null; then
  echo "Error: 'pandoc' not found in PATH."
  exit 1
fi

# Function to convert Markdown to HTML
convert_md_to_html() {
  local md_file="$1"
  local html_file="$2"
  local head_template="$3"

  local title
  title=$(get_title_from_filename "$md_file")

  # Replace {{TITLE}} in template with actual title
  local HTML_HEAD="${head_template//\{\{TITLE\}\}/$title}"
#   local HTML_FOOT="</body></html>"

  if [[ ! -f "$md_file" ]]; then
    echo "Error: Markdown file not found: $md_file"
    return
  fi

  body=$(pandoc "$md_file")

  {
    echo "$HTML_HEAD"
    echo "$body"
    echo "$HTML_FOOT"
  } > "$html_file"

  echo "Converted $md_file -> $html_file"
}

# Logic for handling file or directory input
if [[ -f "$INPUT" && "$INPUT" == *.md ]]; then
  if [[ "$OUTPUT" == *.html ]]; then
    mkdir -p "$(dirname "$OUTPUT")"
    convert_md_to_html "$INPUT" "$OUTPUT" "$HTML_HEAD"
  else
    mkdir -p "$OUTPUT"
    base_name=$(basename "$INPUT" .md)
    convert_md_to_html "$INPUT" "$OUTPUT/$base_name.html" "$HTML_HEAD"
  fi

elif [[ -d "$INPUT" ]]; then
  if [[ -z "$OUTPUT" ]]; then
    echo "Error: please specify an output directory for folder input."
    exit 1
  fi
  mkdir -p "$OUTPUT"
  for file in "$INPUT"/*.md; do
    [[ -e "$file" ]] || continue
    base_name=$(basename "$file" .md)
    convert_md_to_html "$file" "$OUTPUT/$base_name.html" "$HTML_HEAD"
  done

else
  echo "Error: invalid input path: $INPUT"
  echo "Please make sure the file exists and ends with .md, or that it's a valid folder."
  exit 1
fi

echo "All conversions have completed successfully!
The HTML files are located in $OUTPUT."
