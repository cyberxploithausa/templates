#!/usr/bin/env bash

# CTF Recon Script - Active Directory Focused Edition
# Usage:
#   ./scan.sh <ip>           # single IP
#   ./scan.sh ips.txt        # list of IPs

# Wordlists
WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
SMALL_WORDLIST="/usr/share/wordlists/dirb/common.txt"
WEB_WORDLIST="/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt"

# Output directory - now directly under current directory
WORKDIR="$(pwd)"
THREADS=30

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Global banners file
BANNERS_FILE=""

# Initialize banners file for a target
init_banners() {
    local target_dir=$1
    BANNERS_FILE="$target_dir/banners.txt"
    echo "=== Service Banners for $(basename $target_dir) ===" > "$BANNERS_FILE"
    echo "Scan started: $(date)" >> "$BANNERS_FILE"
    echo "================================================" >> "$BANNERS_FILE"
    echo "" >> "$BANNERS_FILE"
}

# Append banner to global banners file
append_banner() {
    local service=$1
    local port=$2
    local banner=$3
    
    echo "[*] $service on port $port:" >> "$BANNERS_FILE"
    echo "$banner" >> "$BANNERS_FILE"
    echo "---" >> "$BANNERS_FILE"
}

# Function for comprehensive web enumeration
enumerate_web() {
    local ip=$1
    local port=$2
    local target_dir=$3
    local protocol="http"
    local webdir="$target_dir/web_${port}"
    
    if [ $port -eq 443 ] || [ $port -eq 8443 ]; then
        protocol="https"
    fi
    
    mkdir -p "$webdir"
    
    echo -e "${BLUE}  [*] Starting web enumeration on $protocol://$ip:$port${NC}"
    
    # Basic web server info
    echo -e "    → Grabbing headers..."
    headers=$(curl -k -s -I "http://$ip:$port" 2>/dev/null)
    echo "$headers" | tee "$webdir/headers.txt"
    
    # Check if web server is responding
    if curl -k -s -o /dev/null -w "%{http_code}" "http://$ip:$port" | grep -q "000"; then
        echo -e "    ${RED}→ Web server not responding on port $port${NC}"
        return
    fi
    
    # Save webpage content
    echo -e "    → Saving webpage content..."
    curl -k -s "http://$ip:$port" | tee "$webdir/index.html" > /dev/null
    
    # Directory fuzzing if ffuf is available
    if command_exists ffuf; then
        echo -e "    → Directory fuzzing..."
        
        # CTF-specific wordlist
        cat > "$webdir/ctf_wordlist.txt" << 'EOF'
admin
login
wp-admin
phpmyadmin
dashboard
api
backup
config
git
.git
.htaccess
robots.txt
secret
hidden
uploads
files
data
logs
backups
old
test
dev
stage
app
application
site
cgi-bin
shell
cmd
upload
download
documents
includes
lib
modules
plugins
themes
vendor
node_modules
src
dist
build
public
private
protected
rest
api/v1
api/v2
graphql
swagger
docs
adminer
phpinfo
info
README
readme
CHANGELOG
install
setup
backdoor
shell.php
cmd.php
upload.php
webshell
EOF
        
        # Directory fuzzing
        ffuf -u "$protocol://$ip:$port/FUZZ" \
            -w "$webdir/ctf_wordlist.txt" \
            -c \
            -t 15 \
            -fc 404 \
            -of csv \
            -o "$webdir/ffuf_dirs.csv" 2>/dev/null
        
        # Display results
        if [ -f "$webdir/ffuf_dirs.csv" ] && [ -s "$webdir/ffuf_dirs.csv" ]; then
            echo -e "    → Interesting directories found:"
            grep -v "^#" "$webdir/ffuf_dirs.csv" 2>/dev/null | awk -F',' '{print $2}' | sort -u | grep -v "^$" | head -20 | tee "$webdir/found_dirs.txt"
        fi
    else
        # Basic curl enumeration
        echo -e "    → Basic directory check..."
        for dir in admin login wp-admin phpmyadmin dashboard api backup config git .git .htaccess robots.txt secret hidden uploads; do
            status=$(curl -k -s -o /dev/null -w "%{http_code}" "$protocol://$ip:$port/$dir" 2>/dev/null)
            if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ] || [ "$status" = "403" ]; then
                echo "$dir (HTTP $status)" | tee -a "$webdir/basic_dirs.txt"
            fi
        done
    fi
    
    # Check robots.txt
    echo -e "    → Checking robots.txt..."
    curl -k -s "$protocol://$ip:$port/robots.txt" | tee "$webdir/robots.txt"
    
    # Check for CMS signatures
    echo -e "    → Checking for technology signatures..."
    curl -k -s "$protocol://$ip:$port" | grep -iE "(wordpress|wp-content|joomla|drupal|magento|laravel|express|react|angular|vue)" | head -10 | tee "$webdir/cms_signatures.txt"
}

# Function for CrackMapExec enumeration
run_cme_enum() {
    local ip=$1
    local target_dir=$2
    local cme_dir="$target_dir/crackmapexec"
    
    mkdir -p "$cme_dir"
    
    echo -e "${CYAN}  [*] Running CrackMapExec enumeration...${NC}"
    
    if command_exists crackmapexec; then
        # SMB enumeration
        echo -e "    → SMB enumeration with crackmapexec..."
        crackmapexec smb $ip 2>&1 | tee "$cme_dir/smb.txt"
        
        # SMB shares enumeration
        echo -e "    → Enumerating SMB shares..."
        crackmapexec smb $ip --shares 2>&1 | tee "$cme_dir/smb_shares.txt"
        
        # SMB users enumeration (if credentials available, try null session)
        echo -e "    → Enumerating SMB users (null session)..."
        crackmapexec smb $ip --users 2>&1 | tee "$cme_dir/smb_users.txt"
        
        # Password policy
        echo -e "    → Getting password policy..."
        crackmapexec smb $ip --pass-pol 2>&1 | tee "$cme_dir/password_policy.txt"
        
        # Check for SMB signing
        echo -e "    → Checking SMB signing..."
        crackmapexec smb $ip --gen-relay-list "$cme_dir/relay_targets.txt" 2>&1 | tee -a "$cme_dir/smb.txt"
        
        # LDAP enumeration
        if grep -q "389/tcp" "$target_dir/open_ports.txt" 2>/dev/null; then
            echo -e "    → LDAP enumeration..."
            crackmapexec ldap $ip 2>&1 | tee "$cme_dir/ldap.txt"
            
            # Try to get domain info
            crackmapexec ldap $ip -M get-desc-users 2>&1 | tee "$cme_dir/ldap_users.txt"
        fi
        
        # WinRM enumeration
        if grep -q "5985/tcp\|5986/tcp" "$target_dir/open_ports.txt" 2>/dev/null; then
            echo -e "    → WinRM enumeration..."
            crackmapexec winrm $ip 2>&1 | tee "$cme_dir/winrm.txt"
        fi
        
        # MSSQL enumeration
        if grep -q "6520/tcp\|1433/tcp" "$target_dir/open_ports.txt" 2>/dev/null; then
            echo -e "    → MSSQL enumeration..."
            crackmapexec mssql $ip 2>&1 | tee "$cme_dir/mssql.txt"
        fi
        
        # RDP enumeration
        if grep -q "3389/tcp" "$target_dir/open_ports.txt" 2>/dev/null; then
            echo -e "    → RDP enumeration..."
            crackmapexec rdp $ip 2>&1 | tee "$cme_dir/rdp.txt"
        fi
    else
        echo -e "    ${RED}→ crackmapexec not installed. Skipping.${NC}"
        echo -e "    ${YELLOW}Install with: pip install crackmapexec${NC}"
    fi
}

# Function for additional AD enumeration tools
run_ad_enum() {
    local ip=$1
    local target_dir=$2
    local ad_dir="$target_dir/ad_enum"
    
    mkdir -p "$ad_dir"
    
    echo -e "${CYAN}  [*] Running Active Directory enumeration...${NC}"
    
    # BloodHound Python (if available)
    if command_exists bloodhound-python; then
        echo -e "    → Running BloodHound collector..."
        bloodhound-python -d overwatch.htb -ns $ip -c All 2>&1 | tee "$ad_dir/bloodhound.txt"
    fi
    
    # enum4linux
    if command_exists enum4linux; then
        echo -e "    → Running enum4linux..."
        enum4linux -a $ip 2>&1 | tee "$ad_dir/enum4linux.txt"
    fi
    
    # ldapsearch anonymous bind
    if command_exists ldapsearch; then
        echo -e "    → Testing anonymous LDAP bind..."
        ldapsearch -x -H ldap://$ip -b "dc=overwatch,dc=htb" 2>&1 | head -50 | tee "$ad_dir/ldap_anonymous.txt"
        
        # Try to get domain naming context
        ldapsearch -x -H ldap://$ip -b "" -s base namingContexts 2>&1 | tee "$ad_dir/ldap_namingcontexts.txt"
    fi
    
    # Kerberos enumeration
    if command_exists nmap; then
        echo -e "    → Kerberos user enumeration..."
        nmap -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm='OVERWATCH.HTB' $ip -oN "$ad_dir/kerberos_users.txt" 2>&1
    fi
}

# Function for service enumeration
enumerate_service() {
    local ip=$1
    local port=$2
    local target_dir=$3
    
    echo -e "${GREEN}[+] Enumerating service on port $port${NC}"
    
    case $port in
        21)
            banner=$(echo "quit" | timeout 5 nc -nv $ip $port 2>&1 | head -1)
            append_banner "FTP" $port "$banner"
            ;;
        22)
            banner=$(timeout 5 nc -nv $ip $port 2>&1 | head -1)
            append_banner "SSH" $port "$banner"
            ;;
        25|587)
            banner=$(timeout 5 nc -nv $ip $port 2>&1 | head -1)
            append_banner "SMTP" $port "$banner"
            ;;
        53)
            # DNS enumeration
            echo -e "    → DNS enumeration..."
            dig axfr @$ip 2>&1 | tee -a "$target_dir/dns_axfr.txt" || echo "Zone transfer not allowed" >> "$target_dir/dns_axfr.txt"
            dig @$ip overwatch.htb ANY 2>&1 | tee -a "$target_dir/dns_records.txt"
            ;;
        80|443|8080|8000|8443|8888|3000|5000|7000|9000)
            enumerate_web $ip $port $target_dir
            ;;
        88)
            banner=$(timeout 5 nc -nv $ip $port 2>&1 | head -1)
            append_banner "Kerberos" $port "$banner"
            echo -e "    → Kerberos realm: OVERWATCH.HTB" | tee -a "$target_dir/kerberos_info.txt"
            ;;
        135|49664|49667)
            banner="Microsoft Windows RPC"
            append_banner "MSRPC" $port "$banner"
            ;;
        139|445)
            # SMB enumeration
            echo -e "    → SMB enumeration..."
            if command_exists smbclient; then
                smbclient -L //$ip -N 2>&1 | tee -a "$target_dir/smb_shares.txt"
            fi
            if command_exists smbmap; then
                smbmap -H $ip 2>&1 | tee -a "$target_dir/smbmap.txt"
            fi
            banner="SMB on port $port"
            append_banner "SMB" $port "$banner"
            ;;
        389|636|3268|3269)
            banner="LDAP - Active Directory"
            append_banner "LDAP" $port "$banner"
            echo -e "    → LDAP base DN: DC=overwatch,DC=htb" | tee -a "$target_dir/ldap_info.txt"
            ;;
        464)
            banner="Kerberos kpasswd5"
            append_banner "Kerberos Password Change" $port "$banner"
            ;;
        593)
            banner="Microsoft RPC over HTTP"
            append_banner "RPC over HTTP" $port "$banner"
            ;;
        3389)
            banner=$(timeout 5 nc -nv $ip $port 2>&1 | head -1)
            append_banner "RDP" $port "$banner"
            echo -e "    → RDP certificate info saved in nmap scan"
            ;;
        5985|5986)
            banner="WinRM - Windows Remote Management"
            append_banner "WinRM" $port "$banner"
            if command_exists crackmapexec; then
                echo -e "    → Testing WinRM access..."
                crackmapexec winrm $ip 2>&1 | tee -a "$target_dir/winrm_test.txt"
            fi
            ;;
        6520|1433)
            banner="Microsoft SQL Server"
            append_banner "MSSQL" $port "$banner"
            if command_exists crackmapexec; then
                echo -e "    → Testing MSSQL access..."
                crackmapexec mssql $ip 2>&1 | tee -a "$target_dir/mssql_test.txt"
            fi
            ;;
        9389)
            banner=".NET Message Framing"
            append_banner ".NET Message Framing" $port "$banner"
            ;;
        *)
            # Generic banner grab for other ports
            banner=$(timeout 3 nc -nv $ip $port 2>&1 | head -1)
            if [ -n "$banner" ] && [ "$banner" != "Connection refused" ]; then
                append_banner "Generic" $port "$banner"
            fi
            ;;
    esac
}

# Main scanning function
scan_target() {
    local ip=$1
    local target_dir="$WORKDIR/$ip"
    
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${GREEN}[*] Scanning target: $ip${NC}"
    echo -e "${BLUE}================================${NC}"
    
    # Create target directory
    mkdir -p "$target_dir"
    init_banners "$target_dir"
    
    # Check if nmap is available
    if ! command_exists nmap; then
        echo -e "${RED}[!] nmap is not installed. Please install nmap first.${NC}"
        exit 1
    fi
    
    # Quick port scan with nmap using -Pn
    echo -e "${YELLOW}[*] Running initial port scan with nmap (-Pn)...${NC}"
    nmap -Pn -p- --min-rate 1000 -T4 "$ip" -oN "$target_dir/nmap_quick.txt" 2>&1
    
    # Extract open ports
    ports=$(grep -E '^[0-9]+/tcp' "$target_dir/nmap_quick.txt" | grep -i open | cut -d'/' -f1 | sort -n | tr '\n' ' ')
    
    if [ -z "$ports" ]; then
        echo -e "${YELLOW}[*] No ports found in full scan, trying top 1000 ports...${NC}"
        nmap -Pn -T4 -F "$ip" -oN "$target_dir/nmap_fast.txt" 2>&1
        ports=$(grep -E '^[0-9]+/tcp' "$target_dir/nmap_fast.txt" | grep -i open | cut -d'/' -f1 | sort -n | tr '\n' ' ')
    fi
    
    if [ -z "$ports" ]; then
        echo -e "${RED}[!] No open ports detected. Target might be down or filtering.${NC}"
        echo "No open ports found" > "$target_dir/open_ports.txt"
        return
    fi
    
    echo -e "${GREEN}[*] Open ports detected: $ports${NC}"
    echo "$ports" | tr ' ' '\n' > "$target_dir/open_ports.txt"
    
    # Service version scan
    echo -e "${YELLOW}[*] Running service version detection...${NC}"
    if [ -n "$ports" ]; then
        port_list=$(echo $ports | tr ' ' ',')
        nmap -Pn -sV -sC -p "$port_list" "$ip" -oN "$target_dir/nmap_services.txt" 2>&1
    fi
    
    # Enumerate each open port
    for port in $ports; do
        enumerate_service $ip $port $target_dir
    done
    
    # Run CrackMapExec enumeration
    run_cme_enum $ip $target_dir
    
    # Run AD specific enumeration
    if echo "$ports" | grep -qE '(389|445|88)'; then
        run_ad_enum $ip $target_dir
    fi
    
    # Create comprehensive summary
    cat > "$target_dir/SUMMARY.txt" << EOF
=== CTF Recon Summary for $ip ===
Scan completed: $(date)
Target: $ip

=== Open Ports ===
$(cat "$target_dir/open_ports.txt" 2>/dev/null)

=== Key Findings ===

Active Directory Domain: overwatch.htb
Domain Controller detected: Yes
SMB Signing: Required
Kerberos Realm: OVERWATCH.HTB

=== Interesting Services ===
- LDAP (port 389/3268) - Can enumerate users/groups
- SMB (port 445) - Check for null sessions, enumerate shares
- WinRM (port 5985) - Possible remote management
- MSSQL (port 6520) - Database service, check for default creds
- Kerberos (port 88) - AD authentication

=== Web Services ===
$(find "$target_dir" -name "found_dirs.txt" -exec echo "Web directories found:" \; -exec cat {} \; 2>/dev/null)

$(find "$target_dir" -name "robots.txt" -exec echo "robots.txt entries:" \; -exec cat {} \; 2>/dev/null)

=== CrackMapExec Results ===
SMB Status: $(grep -i "pwn3d\|signing\|SMB" "$target_dir/crackmapexec/smb.txt" 2>/dev/null | head -3)
Domain: $(grep -i "domain" "$target_dir/crackmapexec/smb.txt" 2>/dev/null | head -1)

=== Service Banners ===
$(cat "$target_dir/banners.txt" 2>/dev/null)

=== Recommended Attack Vectors ===

1. LDAP Anonymous Bind:
   ldapsearch -x -H ldap://$ip -b "DC=overwatch,DC=htb"

2. SMB Null Session:
   smbclient -L //$ip -N
   enum4linux $ip

3. Kerberos Users Enumeration:
   nmap -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm='OVERWATCH.HTB' $ip

4. WinRM Access (if credentials found):
   crackmapexec winrm $ip -u user -p pass
   evil-winrm -i $ip -u user -p pass

5. MSSQL Access:
   crackmapexec mssql $ip -u sa -p sa
   sqsh -S $ip -U sa -P sa

6. RDP Access:
   xfreerdp /v:$ip /u:user /p:pass

7. BloodHound Collection:
   bloodhound-python -d overwatch.htb -ns $ip -c All

=== Useful Commands ===

# Enumerate AD users
crackmapexec smb $ip --users
crackmapexec ldap $ip -M get-desc-users

# Check for AS-REP roasting
crackmapexec ldap $ip -M asreproast

# Check for password policy
crackmapexec smb $ip --pass-pol

# Enumerate SMB shares
crackmapexec smb $ip --shares
smbmap -H $ip -u 'null' -p ''

# LDAP enumeration
ldapsearch -x -H ldap://$ip -b "DC=overwatch,DC=htb" '(objectClass=user)' sAMAccountName

# Kerberoasting (if creds)
impacket-GetUserSPNs -dc-ip $ip overwatch.htb/user

EOF
    
    echo -e "${GREEN}[✓] Scan completed for $ip${NC}"
    echo -e "${YELLOW}[*] Results saved in: $target_dir/${NC}"
    echo -e "${YELLOW}[*] Summary available at: $target_dir/SUMMARY.txt${NC}"
    echo -e "${YELLOW}[*] All banners saved in: $target_dir/banners.txt${NC}"
}

# Main execution
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}CTF Recon Script - AD Edition${NC}"
echo -e "${BLUE}================================${NC}"

# Create results directory
mkdir -p "$WORKDIR/results"

# Load targets
if [[ -f "$1" ]]; then
    echo -e "${YELLOW}[*] Reading targets from file: $1${NC}"
    while IFS= read -r target || [ -n "$target" ]; do
        if [[ -n "$target" && ! "$target" =~ ^[[:space:]]*# ]]; then
            scan_target "$target"
        fi
    done < "$1"
else
    scan_target "$1"
fi

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}[✓] All scans completed!${NC}"
echo -e "${GREEN}[✓] Results saved in directories named after each target${NC}"
echo -e "${GREEN}================================${NC}"

# List results
echo -e "\n${YELLOW}Generated directories:${NC}"
ls -d */ 2>/dev/null | grep -v "^results$" | grep -v "^\.\.$" | while read dir; do
    if [ -f "$dir/SUMMARY.txt" ]; then
        echo -e "  ${GREEN}✓${NC} $dir"
    fi
done
