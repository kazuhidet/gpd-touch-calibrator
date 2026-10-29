# gpd-touch-calibrator

[English](README.md) | 日本語

GPD Pocket 3（Omarchy / Hyprland）向けのタッチパネル キャリブレーションツール。

全画面のターゲットをタッチして実際のタッチ位置を記録し、補正を求めて次の 2 段階で設定します。

- 回転・反転: Hyprland の `input:touchdevice:transform`（`~/.config/hypr/touch_calibration.lua`）
- 拡大縮小・オフセット: udev の `EVDEV_ABS_xx` でカーネルの軸範囲を上書き

Hyprland 0.55 以降は `transform` を設定していなくても libinput のキャリブレーション行列を
単位行列で上書きするため、udev の `LIBINPUT_CALIBRATION_MATRIX` は効きません。
そのため回転は Hyprland に任せ、微調整は libinput より手前（軸範囲）で行います。
わずかな傾き（せん断）は補正できません。

![確認モードの画面](preview.png)

## 使い方

```bash
./install.sh                  # /usr/local/bin にインストール + ランチャー登録
gpd-touch-calibrator          # 5点キャリブレーション
gpd-touch-calibrator --points 9
gpd-touch-calibrator --dry-run  # 設定を表示するだけでインストールしない
gpd-touch-calibrator --show     # 検出したデバイスと現在の設定
gpd-touch-calibrator --check    # ターゲットをタッチして現在の誤差を測るだけ（設定は変更しない）
gpd-touch-calibrator --reset    # キャリブレーションを削除
gpd-touch-calibrator --lang ja  # 表示言語を指定（en / ja）
```

1. 赤い十字の中心をタッチして離す（Backspace でひとつ戻る）
2. テスト画面でタッチすると、灰色 = 現在位置、緑 = 補正後の位置 が表示される
3. 「適用」（Enter）で pkexec 経由で udev ルールを書き込んで HID ドライバを再バインドし、Hyprland の transform を設定して即時反映

`--check` では同じ手順でターゲットをタッチすると、各点の誤差（px）、平均/最大/RMS 誤差、
再キャリブレーションした場合の推定誤差を表示します（標準出力にも出力）。適用ボタンはありません。
判定は誤差の絶対値ではなく、再キャリブレーションでどれだけ改善するかで決まります
（改善が 2px 未満かつ現在の RMS の 25% 未満なら「良好」）。指のタッチは数 mm ばらつくため、
補正では取りきれない誤差が残ります。

ほかの点から求めた補正に対して 40px 以上（かつその補正自体の誤差の 3 倍以上）外れたタッチは
押し間違いとみなし、ターゲットを黄色の丸で囲んでやり直しを促します。この検出には
`--points 9` を使ってください。5 点では押し間違いの半分程度しか見分けられません。

表示言語は `--lang` で指定します。省略時は `LC_ALL` / `LC_MESSAGES` / `LANG` が `ja` で始まれば
日本語、それ以外は英語です。

## 仕組み

- ルール: `/etc/udev/rules.d/99-gpd-touch-calibration.rules`（元の軸範囲と倍率を JSON でヘッダに保存）
- Hyprland: `~/.config/hypr/touch_calibration.lua` を作成し、`hyprland.lua` の末尾に
  `require("hypr.touch_calibration")` を追記（初回のみ、`hyprland.lua.bak.*` にバックアップ）
- 対象: `ID_INPUT_TOUCHSCREEN=1` かつデバイス名一致（`GXTP7380:00 27C6:0113`）。スタイラスは対象外
- 再実行時は現在の transform と軸範囲を考慮して合成するので、何度でも追い込めます
- `--reset` はルール・Lua モジュール・`require` 行をすべて削除します
