#!/usr/bin/env bash
set -euo pipefail

# ========================================
# TID Wi-Fi Setup
# ========================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CA_CERT="$SCRIPT_DIR/nacacert-pem.cer"

IDENTITY="241063kojima"
DOMAIN_SUFFIX="TID-S3F-RD01.local"

FLOORS=(
    N1F N2F N3F N4F N5F
    N6F N7F N8F N9F
    S1F S2F S3F S4F
)

# ========================================
# Checks
# ========================================

command -v nmcli >/dev/null 2>&1 || {
    echo "Error: nmcli が見つかりません"
    exit 1
}

[[ -f "$CA_CERT" ]] || {
    echo "Error: CA証明書が見つかりません: $CA_CERT"
    exit 1
}

sudo -v

# ========================================
# Password
# ========================================

read -rsp "Wi-Fiパスワード: " WIFI_PASSWORD
echo

[[ -n "$WIFI_PASSWORD" ]] || {
    echo "Error: パスワードが空です"
    exit 1
}

# ========================================
# Setup
# ========================================

SUCCESS=0
FAILED=0

for floor in "${FLOORS[@]}"; do
    SSID="tid-student_${floor}"
    PROFILE="$SSID"

    echo "[SETUP] $PROFILE"

    if ! nmcli connection show "$PROFILE" >/dev/null 2>&1; then
        if ! sudo nmcli connection add \
            type wifi \
            con-name "$PROFILE" \
            ifname "*" \
            ssid "$SSID"; then
            echo "[ERROR] 作成失敗"
            ((FAILED+=1))
            continue
        fi
    fi

    if sudo nmcli connection modify "$PROFILE" \
        connection.id "$PROFILE" \
        connection.autoconnect yes \
        802-11-wireless.ssid "$SSID" \
        802-11-wireless.mode infrastructure \
        802-11-wireless-security.key-mgmt wpa-eap \
        802-1x.optional no \
        802-1x.eap peap \
        802-1x.identity "$IDENTITY" \
        802-1x.password-flags 1 \
        802-1x.phase2-auth mschapv2 \
        802-1x.ca-cert "$CA_CERT" \
        802-1x.domain-suffix-match "$DOMAIN_SUFFIX" \
        ipv4.method auto \
        ipv6.method auto; then

        echo "[OK] $PROFILE"
        ((SUCCESS+=1))
    else
        echo "[ERROR] 設定失敗: $PROFILE"
        ((FAILED+=1))
    fi

    echo
done

unset WIFI_PASSWORD

# ========================================
# Summary
# ========================================

echo "================================"
echo "成功: $SUCCESS"
echo "失敗: $FAILED"
echo "================================"

nmcli -f NAME,TYPE connection show

(( FAILED == 0 ))
