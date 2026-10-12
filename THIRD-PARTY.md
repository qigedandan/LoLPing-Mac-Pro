# 第三方素材与许可 / Third-party notices

LoLPing（本仓库）是个人桌面工具，基于下面两个开源项目。代码与素材的归属如下。

## 1. AllenTHT/LoLPing-Mac —— 代码基础

<https://github.com/AllenTHT/LoLPing-Mac>

- 借用范围：**代码与整体设计**。菜单栏应用结构、`⌃⌥⌘` 手势状态机（`Sources/PingCore/GestureMachine.swift`）、轮盘与落点动画的原生 AppKit/Quartz 渲染、控制窗口、`scripts/build.sh` / `check-assets` / `visual-check` 自检流程，以及 `Resources/Artwork/` 里由游戏轮盘图集重建的矢量轮廓（`ping-vectors.json`）。
- 该仓库未附带 LICENSE 文件。本仓库是它的分支版本，保留了其提交历史（`git log` 可见 `Update README.md` 等上游提交），并在此基础上追加了「弱爆」等改动。

## 2. darrenprx/lolPing —— 仅素材

<https://github.com/darrenprx/lolPing> · MIT License, Copyright (c) 2026 Danrui Meng

- 借用范围：**只有素材，没有界面与功能**。
  - `Resources/Emotes/*.png`：44 个表情的 128×128 RGBA 贴图（含「弱爆（文字版）」）。
  - `Resources/Sounds/*.mp3`：44 段表情语音（源文件 `assets/emotes/*.ogg`）+ 八个警报与中央信号的音频（源文件 `assets/sounds/*.wav`）。这些音频由该项目用 `tools/extract-assets` 从游戏 `Common.wad.client` 提取（Wwise 事件 `Play_sfx_hud_base_Pings_*`），本仓库仅做 mp3 转码以便 `AVAudioPlayer` 播放。
  - 完整的文件对应关系见 `Resources/asset-sources.json` 的 `soundMapping` 与 `emoteSource`。
- 该项目的功能实现（Electron 应用、联机房间、热键助手等）**没有被使用**。

MIT 许可全文：

```
MIT License

Copyright (c) 2026 Danrui Meng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 3. CommunityDragon —— 轮盘图集

<https://raw.communitydragon.org/>（社区维护的 Riot 资源镜像，非 Riot 官方服务）

- 借用范围：`Resources/Icons/` 与 `Resources/Artwork/` 里的游戏轮盘图集与图标 PNG，用于重建可缩放的矢量轮廓。

## 4. Riot Games

游戏图标、表情贴图与音效均归 Riot Games 所有。LoLPing 是独立的个人桌面工具，非 Riot 官方产品，与 Riot Games 无任何隶属关系，不用于商业用途。

## 免责与发布提醒

- 本仓库包含 Riot 的游戏素材（图标、表情贴图、音效）。公开托管时请保留上述出处与致谢，并说明仅用于个人、非商业用途。
- 「弱爆」是本地新增的信号，不是官方游戏的轮盘功能；它默认不出现在轮盘上，需要在设置窗口里手动放进某个方位。
