#!/bin/bash

# Input: Post-reverse state from EXPECTED_RESULT
hex_input="dd 41 c8 5c ca 48 d3 43 da 48 d4 5c dc 5d d0 58"

# Convert hex string to an array
IFS=' ' read -r -a bytes <<< "$hex_input"

# Ensure exactly 16 bytes
if [ ${#bytes[@]} -ne 16 ]; then
    echo "Error: Input must be exactly 16 bytes in hex."
    exit 1
fi

# XOR function
xor_hex() {
    local val=$1
    local key=$2
    printf "%02x" $(( 0x$val ^ 0x$key ))
}

# Define XOR keys for even and odd indices
key_even="bf"
key_odd="2b"

# Apply XOR operation
output=()
ascii_output=""
for i in "${!bytes[@]}"; do
    key=$([ $((i % 2)) -eq 0 ] && echo "$key_even" || echo "$key_odd")
    result=$(xor_hex "${bytes[$i]}" "$key")
    output+=("$result")
    
    # Convert to ASCII (if printable)
    dec=$(( 0x$result ))
    if [[ $dec -ge 32 && $dec -le 126 ]]; then
        ascii_output+=$(printf "\\$(printf '%03o' $dec)")
    else
        ascii_output+="."
    fi
done

# Print results
echo "Input (post-reverse): $hex_input"
echo "After reversing XOR:  ${output[*]}"
echo "ASCII characters:     $ascii_output"

