#!/usr/bin/env bash
set -euo pipefail

# ========================================
# TID Wi-Fi Setup
# ========================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

CA_CERT="$SCRIPT_DIR/nacacert-pem.cer"

PROFILE="TID-N1F"
SSID="tid-student_N1F"

IDENTITY="241063kojima"
DOMAIN_SUFFIX="TID-S3F-RD01.local"

# ========================================
# Check dependencies
# ========================================

if ! command -v nmcli >/dev/null 2>&1; then
    echo "Error: nmcli が見つかりません"
    exit 1
fi

if [[ ! -f "$CA_CERT" ]]; then
    echo "Error: CA証明書が見つかりません: $CA_CERT"
    exit 1
fi

# ========================================
# Authentication
# ========================================

read -rsp "Wi-Fiパスワード: " WIFI_PASSWORD
echo

if [[ -z "$WIFI_PASSWORD" ]]; then
    echo "Error: パスワードが空です"
    exit 1
fi

# ========================================
# Create / Update connection
# ========================================

echo "Wi-Fi設定を登録します..."

if nmcli connection show "$PROFILE" >/dev/null 2>&1; then
    echo "[UPDATE] $PROFILE"
else
    echo "[ADD] $PROFILE"

    sudo nmcli connection add \
        type wifi \
        con-name "$PROFILE" \
        ifname "*" \
        ssid "$SSID"
fi

sudo nmcli connection modify "$PROFILE" \
    connection.id "$PROFILE" \
    connection.autoconnect yes \
    802-11-wireless.ssid "$SSID" \
    802-11-wireless-security.key-mgmt wpa-eap \
    802-1x.eap peap \
    802-1x.identity "$IDENTITY" \
    802-1x.password "$WIFI_PASSWORD" \
    802-1x.phase2-auth mschapv2 \
    802-1x.ca-cert "$CA_CERT" \
    802-1x.domain-suffix-match "$DOMAIN_SUFFIX" \
    ipv4.method auto \
    ipv6.method auto

unset WIFI_PASSWORD

echo
echo "[OK] Wi-Fi設定が完了しました"
nmcli -f NAME,TYPE connection show
