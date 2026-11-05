#!/bin/bash

# Check for active network connection using nmcli
if nmcli -t -f STATE g | grep -q "connected"; then
    # Get active connection type
    ACTIVE_CONNECTION_TYPE=$(nmcli -t -f TYPE,DEVICE c show --active | head -n 1 | cut -d':' -f1)

    if [[ "$ACTIVE_CONNECTION_TYPE" == "wifi" ]]; then
        # Wi-Fi icon
        echo "󰤨"
    elif [[ "$ACTIVE_CONNECTION_TYPE" == "ethernet" ]]; then
        # Ethernet icon
        echo "󰈀"
    else
        # A generic connected icon if it's something else (like vpn, etc.)
        echo "󰤋"
    fi
else
    echo "󰤮" # Disconnected icon
fi