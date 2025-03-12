#!/bin/bash

# Check if a target domain is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <target_domain>"
    echo "Example: $0 example.com"
    exit 1
fi

TARGET="$1"
fullp="$(pwd)"
OUTPUT_DIR="recon/$TARGET"
WORDLIST="/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt"  # Adjust this path to your wordlist

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo "[+] Output directory: $OUTPUT_DIR"

# Run amass
#echo "[+] Running amass..."
#amass enum -d "$TARGET" -passive -o "$OUTPUT_DIR/amass_subdomains.txt"


echo "[*] Starting SUB DOMAIN ENUM"
echo "[!] Target locked: $1"
echo "[+] Probing subdomains..."

echo "[+] Running AssetFinder..."
assetfinder --subs-only "$TARGET"  | anew "$OUTPUT_DIR/subdomains.txt"
echo "[+] Running Subfinder"
subfinder -d "$TARGET" -silent | anew "$OUTPUT_DIR/subdomain.txt"

echo "[>] Output: $OUTPUT_DIR/subdomains.txt"


echo "[+] Running httprobe..."
cat "$OUTPUT_DIR/subdomain.txt" | httprobe -prefer-https | tee -a "$OUTPUT_DIR/alive.txt" 

smap "$TARGET" -oG "$OUTPUT_DIR/Scan.txt"

# Run httpx
echo "[+] General Response Running httpx..."
cat "$OUTPUT_DIR/filtered_subdomains.txt" | httpx-pd -o "$OUTPUT_DIR/alive_subdomains.txt"

echo "[+] General Response Running httpx..."
cat "$OUTPUT_DIR/filtered_subdomains.txt" | httpx-pd -sc -o "$OUTPUT_DIR/sc-alive_subdomains.txt"
#Run gau
echo "[+] Running gau..."
echo "$TARGET" | gau > "$OUTPUT_DIR/gau_urls.txt"

gowitness scan file -f "$OUTPUT_DIR/alive_subdomains.txt"

mv "screenshots/" "$OUTPUT_DIR" 



