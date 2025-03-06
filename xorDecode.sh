#!/bin/bash

# Initialize variables
hex_input=""
key=""

# Parse options
while getopts 'h:k:' OPTION; do
  case "$OPTION" in
    h) hex_input="$OPTARG" ;;
    k) key="$OPTARG" ;;
    *) 
      echo "Usage: $0 -h \"hex1 hex2 ...\" -k key"
      echo "Example: $0 -h \"ab db cd ef\" -k bf"
      exit 1
      ;;
  esac
done

# Check if inputs are provided
[ -z "$hex_input" ] || [ -z "$key" ] && {
  echo "Error: Provide -h \"hex values\" and -k key"
  exit 1
}

# Split hex input into array
IFS=' ' read -r -a bytes <<< "$hex_input"

# Process each byte with one key
output=()
ascii_output=""
for hex in "${bytes[@]}"; do
  # Simple XOR reversal
  result=$((16#$hex ^ 16#$key))
  result_hex=$(printf "%02x" "$result")
  output+=("$result_hex")
  
  # ASCII if printable
  [ $result -ge 32 ] && [ $result -le 126 ] && ascii_output+=$(printf "\\x$result_hex") || ascii_output+="."
done

# Print results
echo "Input:          $hex_input"
echo "After XOR ($key): ${output[*]}"
echo "ASCII (if any): $(echo -e "$ascii_output")"
