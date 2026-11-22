================================================================
# Nmap
```sh
nmap -p- -sT -sV -A $IP
nmap -p- -sC -sV $IP --open
nmap -p- --script=vuln $IP
###HTTP-Methods
nmap --script http-methods --script-args http-methods.url-path='/website' 
###  --script smb-enum-shares
sed IPs:
grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' FILE

nmap -p21,22,23,25,53,80,110,111,135,139,143,161,443,445,465,587,636,993,995,1433,1521,2222,3306,3389,3780,5432,5601,5900,5985,5986,6379,7001,8000,8080,8081,8088,8090,8443,8888,9200,9300,10000,10001,10050,10443,11211,20000,27000,27017,33848,50000,50030,50070,61616,62078 -T4 -sX -oA Host-Discovery-Report --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl -iL full-scope.txt
```
================================================================
# WPScan & SSL
```sh
wpscan --url $URL --disable-tls-checks --enumerate p --enumerate t --enumerate u
### WPScan Brute Forceing:
wpscan --url $URL --disable-tls-checks -U users -P /usr/share/wordlists/rockyou.txt
### Aggressive Plugin Detection:
wpscan --url $URL --enumerate p --plugins-detection aggressive
```
================================================================================
# Nikto with SSL and Evasion
```sh
nikto --host $IP -ssl -evasion 1
```
================================================================================
# dns_recon
```sh
dnsrecon –d yourdomain.com
```
================================================================================
# gobuster directory
```sh
gobuster dir -u $URL -w /opt/SecLists/Discovery/Web-Content/raft-medium-directories.txt -k -t 30
### gobuster files
gobuster dir -u $URL -w /opt/SecLists/Discovery/Web-Content/raft-medium-files.txt -k -t 30

### gobuster for SubDomain brute forcing:
gobuster dns -d domain.org -w /opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -t 30
```
"just make sure any DNS name you find resolves to an in-scope address before you test it"


================================================================================
# Extract IPs from a text file.
```sh
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' nmapfile.txt
```
================================================================================

# Wfuzz XSS Fuzzing

```sh
wfuzz -c -z file,/opt/SecLists/Fuzzing/XSS/XSS-BruteLogic.txt "$URL"

wfuzz -c -z file,/opt/SecLists/Fuzzing/XSS/XSS-Jhaddix.txt "$URL"

### COMMAND INJECTION WITH POST DATA
wfuzz -c -z file,/opt/SecLists/Fuzzing/command-injection-commix.txt -d "doi=FUZZ" "$URL"

### Test for Paramter Existence!
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/burp-parameter-names.txt "$URL"

### AUTHENTICATED FUZZING DIRECTORIES:
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-medium-directories.txt --hc 404 -d "SESSIONID=value" "$URL"

### AUTHENTICATED FILE FUZZING:
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-medium-files.txt --hc 404 -d "SESSIONID=value" "$URL"

### FUZZ Directories:
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-large-directories.txt --hc 404 "$URL"

### FUZZ FILES:
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-large-files.txt --hc 404 "$URL"

### LARGE WORDS:
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-large-words.txt --hc 404 "$URL" 

### USERS:
wfuzz -c -z file,/opt/SecLists/Usernames/top-usernames-shortlist.txt --hc 404,403 "$URL"
```

================================================================================
# Command Injection with commix, ssl, waf, random agent.
```sh
commix --url="https://supermegaleetultradomain.com?parameter=" --level=3 --force-ssl --skip-waf --random-agent
```
================================================================================
# SQLMap

```sh
sqlmap -u $URL --threads=2 --time-sec=10 --level=2 --risk=2 --technique=T --force-ssl
sqlmap -u $URL --threads=2 --time-sec=10 --level=4 --risk=3 --dump
```
================================================================================
# Social Recon
```sh
theharvester -d domain.org -l 500 -b google
```
================================================================================
# Nmap HTTP-methods
```sh
nmap -p80,443 --script=http-methods  --script-args http-methods.url-path='/directory/goes/here'
# Directory & file discovery (built-in wordlist)
nmap -p 80,443 --script http-enum target

# Page title (quick service ID)
nmap -p 80,443 --script http-title target

# Full response headers (server, X-Powered-By, etc.)
nmap -p 80,443 --script http-headers target

# robots.txt — often reveals hidden paths
nmap -p 80,443 --script http-robots.txt target

# Virtual hosts (subdomain/hostname discovery)
nmap -p 80,443 --script http-vhosts target

# Server header only (lighter than http-headers)
nmap -p 80,443 --script http-server-header target

# Security headers check (OWASP)
nmap -p 80,443 --script http-security-headers target 

# Exploitation / Interaction
# Upload a file via PUT (test if PUT is enabled)
nmap -p 80 --script http-put --script-args "http-put.url=/uploads/shell.php,http-put.file=shell.php" target

# Brute-force HTTP Basic/Digest/NTLM auth
nmap -p 80,443 --script http-brute --script-args "http-brute.path=/admin,userdb=users.txt,passdb=pass.txt" target

# Brute-force login forms
nmap -p 80,443 --script http-form-brute --script-args "http-form-brute.path=/login.php,http-form-brute.userdb=users.txt,http-form-brute.passworddb=pass.txt" target

# WebDAV scan (methods, server, auth)
nmap -p 80,443 --script http-webdav-scan target

# HTTP TRACE / XST (cross-site tracing)
nmap -p 80,443 --script http-xst target   

# Vulnerability Detection
# SQL injection (spider + test params)
nmap -p 80,443 --script http-sql-injection target

# Stored XSS
nmap -p 80,443 --script http-stored-xss target

# Reflected XSS
nmap -p 80,443 --script http-xssed target

# Open redirect detection
nmap -p 80,443 --script http-open-redirect target

# Open proxy check
nmap -p 80,443 --script http-open-proxy target

# Default credentials (WordPress, Joomla, etc.)
nmap -p 80,443 --script http-default-accounts target

# Error page crawling (info disclosure)
nmap -p 80,443 --script http-errors target

# Malware signature check
nmap -p 80,443 --script http-malware-host target

# CVE checks (Struts, Apache, etc.)
nmap -p 80,443 --script "http-vuln-cve*" target   

# DoS (KoTH / Lab Only)
# Slowloris — check without attacking
nmap -p 80 --script http-slowloris-check target

# Slowloris — actual attack (intrusive!)
nmap -p 80 --script http-slowloris --max-parallelism 400 target   


# Quick Combos
# Full web recon in one shot
nmap -p 80,443 -sV --script "http-enum,http-headers,http-methods,http-title,http-robots.txt,http-vhosts" target

# Vuln sweep (safe category only)
nmap -p 80,443 --script "http-* and safe" target

# Everything HTTP (including intrusive — lab only)
nmap -p 80,443 --script "http-*" target   

# Useful --script-args
| Arg | Script | Purpose |
|---|---|---|
| `http-methods.url-path=/admin` | `http-methods` | Check methods on a specific path |
| `http-put.file=shell.php` | `http-put` | Local file to upload |
| `http-put.url=/uploads/shell.php` | `http-put` | Remote destination path |
| `http-brute.path=/admin` | `http-brute` | Target auth path |
| `http-brute.userdb=users.txt` | `http-brute` | Username wordlist |
| `http-brute.passdb=pass.txt` | `http-brute` | Password wordlist |
| `httpspider.maxpagecount=20` | `http-sql-injection` | Limit crawl depth |
| `httpspider.recurse=1` | `http-sql-injection` | Follow links |
| `http-enum.maxpagecount=50` | `http-enum` | Limit requests |

# Tip
List all available HTTP scripts on your system:

ls /usr/share/nmap/scripts/ | grep http
# or
nmap --script "http-*" --script-help "" 2>&1 | grep "^http"   
```
================================================================================
# SMTP USER ENUM

```sh
smtp-user-enum -M VRFY -U /opt/SecLists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M EXPN -U /opt/SecLists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M RCPT -U /opt/SecLists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M EXPN -U /opt/SecLists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M VRFY -U users.txt -t 10.0.0.1
smtp-user-enum -M EXPN -u admin1 -t 10.0.0.1
smtp-user-enum -M RCPT -U users.txt -T mail-server-ips.txt
smtp-user-enum -M EXPN -D example.com -U users.txt -t 10.0.0.1

```
================================================================================

# Packet Capture

```sh
tcpdump -i any -c5 icmp
tcpdump -i eth0 -nn -A
tcpdump -i eth0 -nn -X
tcpdump -i any -nn "host 192.168.1.1"
tcpdump -i any -nn "host 192.168.1.1 and port 22"
tcpdump -i any -nn "src 192.168.1.1"
tcpdump -r file.pcap
```
====
# Network Discovery
```sh
netdiscover /r 0.0.0.0/24
arp-scan -l
arp-scan -l -I wlo1
```
====
#INTO OUTFILE D00R
SELECT “” into outfile “/var/www/WEROOT/backdoor.php”;
====
LFI?
#PHP Filter Checks.
php://filter/convert.base64-encode/resource=
====
UPLOAD IMAGE?
GIF89a1
