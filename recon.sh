#!/bin/bash
# ==============================================
# 🔎 Bug Bounty Recon Script
# Author: Cyberxploit-Hausa
# ==============================================

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# Banner
echo -e "${MAGENTA}"
cat << "EOF"
            
██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗    ██╗  ██╗ █████╗ ██╗   ██╗███████╗ █████╗ 
╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝    ██║  ██║██╔══██╗██║   ██║██╔════╝██╔══██╗
 ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║       ███████║███████║██║   ██║███████╗███████║
 ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║       ██╔══██║██╔══██║██║   ██║╚════██║██╔══██║
██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║       ██║  ██║██║  ██║╚██████╔╝███████║██║  ██║
╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝


                                                                     
          ⚡ Cyberxploit-Hausa Recon Framework ⚡
EOF
echo -e "${RESET}"

# Usage
if [ -z "$1" ]; then
    echo -e "\n${RED}[!] Usage:${RESET} $0 <target.com>\n"
    exit 1
fi

domain=$1
outdir="recon-$domain"
mkdir -p "$outdir"

banner() {
    echo -e "\n${CYAN}==============================================${RESET}"
    echo -e " ${BOLD}$1${RESET}"
    echo -e "${CYAN}==============================================${RESET}"
}

# ------------------------------------------------
# 1. Subdomain Enumeration
# ------------------------------------------------
banner "[*] Enumerating subdomains for $domain"
subfinder -d "$domain" -all -recursive -silent -o "$outdir/subs1.txt"
amass db -names -d "$domain" -o "$outdir/subs2.txt"

cat "$outdir"/subs*.txt | sort -u > "$outdir/all-subs.txt"

# crt.sh enumeration with error handling
crt_result=$(curl -s "https://crt.sh/?q=$domain&output=json")
if echo "$crt_result" | jq empty 2>/dev/null; then
    echo "$crt_result" | jq -r '.[].name_value' \
        | sed 's/\*\.//g' | sort -u >> "$outdir/all-subs.txt"
else
    echo -e "${YELLOW}[!] crt.sh returned non-JSON, skipping...${RESET}"
fi

sort -u "$outdir/all-subs.txt" -o "$outdir/all-subs.txt"
echo -e "${GREEN}[+] Total subdomains found:${RESET} $(wc -l < $outdir/all-subs.txt)"

# ------------------------------------------------
# 2. Live Hosts
# ------------------------------------------------
banner "[+] Checking live hosts"
cat "$outdir/all-subs.txt" | httpx-toolkit -silent -threads 200 \
    -ports 80,443,8080,8000,8888 -o "$outdir/subdomains_alive.txt"

echo -e "${GREEN}[+] Live hosts:${RESET} $(wc -l < $outdir/subdomains_alive.txt)"

# ------------------------------------------------
# 3. Port Scanning
# ------------------------------------------------
banner "[+] Scanning for open ports with Naabu + Nmap"
naabu -list "$outdir/all-subs.txt" -c 50 \
    -nmap-cli 'nmap -sC -sV -T4 -Pn' \
    -o "$outdir/naabu_full_nmap.txt"

echo -e "${YELLOW}[i] Ports scanned. Results saved in:${RESET} $outdir/naabu_full_nmap.txt"

# ------------------------------------------------
# 4. Fetch URLs
# ------------------------------------------------
banner "[+] Fetching all URLs from subdomains"
cat "$outdir/subdomains_alive.txt" | gau | tee "$outdir/params.txt" > /dev/null
echo -e "${GREEN}[+] URLs collected:${RESET} $(wc -l < $outdir/params.txt)"

# ------------------------------------------------
# 5. Filter Parameters
# ------------------------------------------------
banner "[+] Filtering Parameters"
cat "$outdir/params.txt" | uro | tee "$outdir/filterparams.txt" > /dev/null
echo -e "${GREEN}[+] Parameters filtered:${RESET} $(wc -l < $outdir/filterparams.txt)"

# ------------------------------------------------
# 6. Extract JS Files
# ------------------------------------------------
banner "[+] Extracting JS Files"
grep -Ei "\.js$" "$outdir/filterparams.txt" | uro | sort -u | tee "$outdir/jsfiles.txt" > /dev/null
echo -e "${GREEN}[+] JS files found:${RESET} $(wc -l < $outdir/jsfiles.txt)"

# ------------------------------------------------
# 7. Sorted Parameters
# ------------------------------------------------
banner "[+] Sorting Parameters"
sort -u "$outdir/filterparams.txt" > "$outdir/sorted_filtered_list.txt"
echo -e "${GREEN}[+] Sorted parameter list saved.${RESET}"

# ------------------------------------------------
# 8. Nuclei Scan
# ------------------------------------------------
banner "[+] Running Nuclei Scan"
nuclei -list "$outdir/filterparams.txt" \
    -c 70 -rl 200 -fhr -lfa \
    -t ~/Desktop/projects/bugbounty/nuclei-templates/ \
    -o "$outdir/nuclei.txt" -es info

echo -e "\n${MAGENTA}✅ Recon completed for $domain.${RESET}"
echo -e "${BLUE}Results saved in:${RESET} $outdir/"

