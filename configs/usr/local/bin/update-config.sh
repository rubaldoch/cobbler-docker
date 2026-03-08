#!/usr/bin/env bash
set -euo pipefail

echo "[update] Rendering Cobbler configuration from templates"

# Render templates (fail if variables are missing)
j2 --undefined /etc/cobbler/settings.yaml.j2 > /etc/cobbler/settings.yaml
j2 --undefined /etc/cobbler/dhcp.template.j2 > /etc/cobbler/dhcp.template


echo "[update] Configuring Cobbler default root password"

SECRET_FILE="/run/secrets/cobbler_root_password"

if [[ ! -r "$SECRET_FILE" ]]; then
  echo "[update][ERROR] Cobbler root password secret not found or not readable: $SECRET_FILE"
  exit 1
fi

# Read secret safely (no logging, no exporting)
PASSWORD="$(<"$SECRET_FILE")"

if [[ -z "$PASSWORD" ]]; then
  echo "[update][ERROR] Cobbler root password secret is empty"
  exit 1
fi

# Hash password (MD5-crypt, required by Cobbler)
ENCRYPTED_PASS="$(openssl passwd -1 -salt "777" "$PASSWORD")"

# Clear plaintext immediately
unset PASSWORD

# Update settings.yaml safely
sed -i \
  "s|^default_password_crypted:.*|default_password_crypted: \"$ENCRYPTED_PASS\"|" \
  /etc/cobbler/settings.yaml

echo "[update] Cobbler root password configured successfully"

echo "[update] Cobbler enable DHCP management"

# sed -i \
#   "s|^manage_dhcp:.*|manage_dhcp: true|" \
#   /etc/cobbler/settings.yaml
# sed -i \
#   "s|^manage_dhcp_v4:.*|manage_dhcp_v4: true|" \
#   /etc/cobbler/settings.yaml
sed -i \
  "s|^pxe_just_once:.*|pxe_just_once: "$COBBLER_PXE_JUST_ONE"|" \
  /etc/cobbler/settings.yaml
sed -i \
  "s|^enable_ipxe:.*|enable_ipxe: "$COBBLER_ENABLE_IPXE"|" \
  /etc/cobbler/settings.yaml

echo "[update] Cobbler configuration update completed successfully"