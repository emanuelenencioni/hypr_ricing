#!/bin/bash

if nmcli -t -f STATE g | grep -q "connected"; then
    ACTIVE_CONNECTION_TYPE=$(nmcli -t -f TYPE,DEVICE c show --active | head -n 1 | cut -d':' -f1)

    if [[ "$ACTIVE_CONNECTION_TYPE" == "wifi" ]]; then
        echo "󰤨"
    elif [[ "$ACTIVE_CONNECTION_TYPE" == "ethernet" ]]; then
        echo "󰈀"
    else
        echo "󰤋"
    fi
else
    echo "󰤮"
fi
