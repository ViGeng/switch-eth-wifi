#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title switch-net
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🌐
# @raycast.argument1 { "type": "text", "placeholder": "eth or wifi" }

# Documentation:
# @raycast.description switch between wifi and ethernet
# @raycast.author ViGeng
# @raycast.authorURL https://raycast.com/ViGeng

MODE=$1

# 1. Input Validation
if [[ "$MODE" != "eth" && "$MODE" != "wifi" ]]; then
    echo "Error: Please specify mode 'eth' or 'wifi'"
    exit 1
fi

# 2. Get all services (skipping disabled ones marked with *)
IFS=$'\n'
raw_services=$(networksetup -listallnetworkservices | grep -v "An asterisk" | sed 's/^\*//')

eth_services=()
wifi_services=()
other_services=()

# 3. Categorize Services
for service in $raw_services; do
    # Skip empty lines
    if [[ -z "$service" ]]; then continue; fi
    
    # Convert to lowercase for checking keywords
    lower_service=$(echo "$service" | tr '[:upper:]' '[:lower:]')

    # LOGIC:
    # Wi-Fi = contains "wi-fi"
    # Ethernet = contains "lan", "ethernet", "usb" (but NOT "iphone")
    if [[ "$lower_service" == *"wi-fi"* ]]; then
        wifi_services+=("$service")
    elif [[ "$lower_service" == *"ethernet"* ]] || [[ "$lower_service" == *"lan"* ]] || [[ "$lower_service" == *"usb"* ]]; then
        if [[ "$lower_service" != *"iphone"* ]]; then
            eth_services+=("$service")
        else
            other_services+=("$service")
        fi
    else
        other_services+=("$service")
    fi
done

# 4. Construct the New Order based on requested Mode
if [[ "$MODE" == "eth" ]]; then
    # Eth first, then Wi-Fi, then others
    ordered_list=("${eth_services[@]}" "${wifi_services[@]}" "${other_services[@]}")
else
    # Wi-Fi first, then Eth, then others
    ordered_list=("${wifi_services[@]}" "${eth_services[@]}" "${other_services[@]}")
fi

# 5. Format command arguments (wrap every service name in quotes)
args=""
for s in "${ordered_list[@]}"; do
    args="$args \"$s\""
done

# 6. Execute (Handling Admin Privileges & Quote Escaping)
FINAL_CMD="networksetup -ordernetworkservices $args"

if [ "$EUID" -eq 0 ]; then
    # If running as root (sudo), just run it
    eval $FINAL_CMD
else
    # FIX: Escape quotes for AppleScript
    ESCAPED_CMD=$(echo "$FINAL_CMD" | sed 's/"/\\"/g')
    
    # Execute safely via osascript
    if ! output=$(osascript -e "do shell script \"$ESCAPED_CMD\" with administrator privileges" 2>&1); then
        echo "Failed: $output"
        exit 1
    fi
fi

echo "Successfully switched priority to: $MODE"