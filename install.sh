#!/bin/bash
# Install gpd-touch-calibrator system-wide and add a launcher entry.
set -euo pipefail
cd "$(dirname "$(realpath "$0")")"

sudo install -Dm755 gpd-touch-calibrator /usr/local/bin/gpd-touch-calibrator
sudo install -Dm755 gpd-touch-calibrator-apply /usr/local/bin/gpd-touch-calibrator-apply

mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/gpd-touch-calibrator.desktop <<DESKTOP
[Desktop Entry]
Type=Application
Name=Touch Calibrator
Name[ja]=タッチキャリブレーション
Comment=Calibrate the touchscreen
Comment[ja]=タッチパネルのキャリブレーション
Exec=/usr/local/bin/gpd-touch-calibrator
Icon=input-touchscreen
Terminal=false
Categories=Settings;HardwareSettings;
Actions=check;

[Desktop Action check]
Name=Check calibration
Name[ja]=キャリブレーションを確認
Exec=/usr/local/bin/gpd-touch-calibrator --check
DESKTOP

echo "Installed. Launch 'Touch Calibrator' from the app launcher or run gpd-touch-calibrator."
