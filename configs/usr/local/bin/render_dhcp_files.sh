#!/usr/bin/env bash

COBBLER_SETTINGS="/etc/cobbler/settings.yaml"

# Function to get a setting from settings.yaml
get_setting() {
    local key=$1
    grep "^$key:" "$COBBLER_SETTINGS" | awk '{print $2}'
}

# Function to set a setting in settings.yaml
set_setting() {
    local key=$1
    local value=$2
    sed -i "s|^$key:.*|$key: $value|" "$COBBLER_SETTINGS"
}

echo "[temp-sync] Saving current manage_* settings..."
ORIG_MANAGE_DHCP=$(get_setting "manage_dhcp")
ORIG_MANAGE_DHCP_V4=$(get_setting "manage_dhcp_v4")

echo "[temp-sync] Temporarily enabling manage_* to generate configs..."
set_setting "manage_dhcp" "true"
set_setting "manage_dhcp_v4" "true"

echo "[temp-sync] Running cobbler sync..."

# check if cobblerd is running, if not start it temporarily for the sync
if ! pgrep -x "cobblerd" > /dev/null; then
    echo "[temp-sync] cobblerd not running, starting it temporarily..."
    service httpd start && /usr/local/bin/cobblerd && cobbler sync && sleep 5
    SUPERVISOR_COBBLER=false
else
    echo "[temp-sync] cobblerd is already running, performing sync..."
    supervisorctl restart cobblerd
    supervisorctl restart dhcpd
    cobbler sync && sleep 5
    SUPERVISOR_COBBLER=true
fi

echo "[temp-sync] Restoring original manage_* settings..."
set_setting "manage_dhcp" "$ORIG_MANAGE_DHCP"
set_setting "manage_dhcp_v4" "$ORIG_MANAGE_DHCP_V4"

if [ "$SUPERVISOR_COBBLER" = true ]; then
    set -euo pipefail
    echo "[temp-sync] Restarting cobblerd to apply original settings..."
    supervisorctl restart cobblerd
    cobbler sync && sleep 5
fi

echo "[temp-sync] Sync complete. Original settings restored."