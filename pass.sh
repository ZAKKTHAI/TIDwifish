
#!/usr/bin/env bash
set -euo pipefail

sudo -v

read -rsp "TID Wi-Fi パスワード: " WIFI_PASSWORD
echo

if [[ -z "$WIFI_PASSWORD" ]]; then
    echo "[ERROR] パスワードが空です"
    exit 1
fi

FLOORS=(
    N1F N2F N3F N4F N5F N6F N7F N8F N9F
    S1F S2F S3F S4F
)

for floor in "${FLOORS[@]}"; do
    PROFILE="tid-student_${floor}"

    if ! sudo nmcli connection show "$PROFILE" >/dev/null 2>&1; then
        echo "[SKIP] $PROFILE が存在しません"
        continue
    fi

    sudo nmcli connection modify "$PROFILE" \
        802-1x.password "$WIFI_PASSWORD" \
        802-1x.password-flags 0

    echo "[OK] $PROFILE"
done

unset WIFI_PASSWORD

echo "全プロファイルへのパスワード設定が完了しました"
