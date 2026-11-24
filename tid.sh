# setuwifi.sh

#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="TID-N1F"

# NetworkManagerの確認
if ! command -v nmcli >/dev/null 2>&1; then
    echo "Error: nmcli が見つかりません"
    exit 1
fi

# テンプレートの確認
if ! nmcli connection show "$TEMPLATE" >/dev/null 2>&1; then
    echo "Error: テンプレート '$TEMPLATE' がありません"
    exit 1
fi

# CA証明書の確認
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CA_CERT="$SCRIPT_DIR/src/nacacert-pem.cer"

if [[ ! -f "$CA_CERT" ]]; then
    echo "Error: CA証明書が見つかりません: $CA_CERT"
    exit 1
fi

FLOORS=(
    N1F N2F N3F N4F N5F
    N6F N7F N8F N9F
    S1F S2F S3F S4F
)

echo "Wi-Fi設定を登録します"
echo "Template: $TEMPLATE"
echo

for floor in "${FLOORS[@]}"; do
    SSID="tid-student_${floor}"
    PROFILE="$SSID"

    # 既に登録されている場合はスキップ
    if nmcli connection show "$PROFILE" >/dev/null 2>&1; then
        echo "[SKIP] $PROFILE は登録済み"
        continue
    fi

    echo "[ADD] $SSID"

    # 既存プロファイルを複製
    sudo nmcli connection clone "$TEMPLATE" "$PROFILE"

    # SSIDと接続名を設定
    sudo nmcli connection modify "$PROFILE" \
        connection.id "$PROFILE" \
        802-11-wireless.ssid "$SSID" \
        connection.autoconnect yes

    echo "[OK] $SSID"
done

echo
echo "Wi-Fi設定の登録が完了しました"
nmcli -f NAME,TYPE connection show

