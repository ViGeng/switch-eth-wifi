# Switch Eth/WiFi

A simple bash script to quickly toggle network priority between **Ethernet** and **Wi-Fi** on macOS. 

This is useful when you want to force your Mac to prioritize a wired connection when available, or revert to Wi-Fi without turning off interfaces.

## Usage

Make the script executable:

```bash
chmod +x switch-net.sh
```

### Prioritize Ethernet
Moves all Ethernet/LAN/USB network services to the top of the service order.

```bash
./switch-net.sh eth
```

### Prioritize Wi-Fi
Moves Wi-Fi services to the top.

```bash
./switch-net.sh wifi
```

## How it works

1. Reads all available network services via `networksetup`.
2. Categorizes them into **Ethernet**, **Wi-Fi**, and **Other** based on keywords.
3. Reorders the services based on the selected mode.
4. Uses macOS `osascript` to prompt for administrator privileges if required.
