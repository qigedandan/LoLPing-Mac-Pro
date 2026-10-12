#!/bin/zsh
# Packages dist/LoLPing.app into a drag-to-Applications disk image.
set -euo pipefail
cd "${0:A:h:h}"

APP="$PWD/dist/LoLPing.app"
[[ -d "$APP" ]] || { print -u2 "先运行 scripts/build.sh"; exit 1 }
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP/Contents/Info.plist")
DMG="$PWD/dist/LoLPing-v$VERSION-macOS-arm64.dmg"

STAGE=$(mktemp -d)/LoLPing
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/应用程序"
cat > "$STAGE/安装说明.txt" <<'TEXT'
LoLPing · Mac 桌面信号

安装
1. 把 LoLPing.app 拖到「应用程序」文件夹（右侧链接）。
2. 首次打开若提示「无法验证开发者」：在「访达」里右键点 LoLPing.app →「打开」→ 再点「打开」。
3. 打开后，菜单栏会出现 LoLPing 图标；在「系统设置 → 隐私与安全性 → 辅助功能」里允许 LoLPing，然后重新打开应用，再打开「启用 Ping」。

使用
- 按住 Control + Option + Command 约 0.18 秒 → 移动鼠标选择信号 → 松开任意一键发送。Esc 或右键取消。
- 「信号轮盘」一节可以自定义每个方位放哪个信号（第 1 位在正上方，顺时针排列）。

说明
- 独立个人桌面工具，非 Riot 官方产品。游戏图标、表情与音效归 Riot Games 所有。
- 本应用未使用 Apple 公证；仅在你的机器上本地签名。
TEXT

rm -f "$DMG"
hdiutil create -quiet -volname "LoLPing $VERSION" -srcfolder "$STAGE" -ov -format UDZO -fs HFS+ "$DMG"
rm -rf "${STAGE:h}"
hdiutil verify -quiet "$DMG"
print "DMG: $DMG"
