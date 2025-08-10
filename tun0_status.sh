#!/bin/bash

IP=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [ -n "$IP" ]; then
    echo -n "🟢VPN: $IP"
else
    echo -n "🔴VPN: OFF"
fi
