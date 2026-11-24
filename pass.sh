
#!/usr/bin/env bash
set -euo pipefail

# sudo認証
sudo -v

# 既存のN1Fプロファイルからパスワードを取得
WIFI_PASSWORD="$(sudo nmcli --show-secrets -g 802-1x.password connection show TID-N1F)"

if [[ -z "$WIFI_PASSWORD" || "$WIFI_PASSWORD" == "--" ]]; then
    echo "[ERROR] TID-N1Fに保存済みパスワードがありません"
    exit 1
fi

FLOORS=(
    N1F N2F N3F N4F N5F N6F N7F N8F N9F
    S1F S2F S3F S4F
)

for floor in "${FLOORS[@]}"; do
    PROFILE="tid-student_${floor}"

    sudo nmcli connection modify "$PROFILE" \
        802-1x.password "$WIFI_PASSWORD" \
        802-1x.password-flags 0

    echo "[OK] $PROFILE"
done

unset WIFI_PASSWORD

echo "全13プロファイルへのパスワード設定が完了しました"

