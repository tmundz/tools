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
assetfinder --subs-only "$TARGET"  | anew "$OUTPUT_DIR/subdomain.txt"
echo "[+] Running Subfinder"
subfinder -d "$TARGET" -silent | anew "$OUTPUT_DIR/subdomain.txt"

echo "[>] Output: $OUTPUT_DIR/subdomains.txt"


echo "[+] Running Katana..."
katana -u "$TARGET" -d 3 - jc -rl 5 -j "$OUTPUT_DIR/Katana.json"

echo "[+] Running httprobe..."
cat "$OUTPUT_DIR/subdomain.txt" | httprobe | rg "https://" | tee -a "$OUTPUT_DIR/alive.txt" 

smap "$TARGET" -oG "$OUTPUT_DIR/Scan.txt"



gowitness scan file -f "$OUTPUT_DIR/alive.txt"

mv "screenshots/" "$OUTPUT_DIR" 



