# LoLPing 1.5 验证记录

日期：2026-10-12。环境：Apple Silicon，macOS 26.6.2，Swift 6（Command Line Tools）。

本轮改动：轮盘大小与图标大小可调；中央信号可自定义（表情也能放进中央）；表情在轮盘与落点里画得更大；新增尺寸对照渲染。

## 已验证

- Release 构建成功，`dist/LoLPing.app` 版本 1.5.0（构建 6）；`codesign --verify --deep --strict` 通过。`--check-assets` 报告 53 个图标与 53 个音效全部解码成功。
- 手势与几何测试 **17 个场景、131 个断言**全部通过。新增用例「中央信号可自定义」：中央设为「弱爆（文字版）」时，`open()` 后 `selected` 即为该表情，中心区域的 `moved` 返回 `angle: nil`，松键提交的也是它；纯几何函数在传入 `centreSignal` 时同样返回该值、不传时仍返回 `generic`。
- 尺寸对照渲染 `Verification/Visuals/wheel-large-retina.png`：同一个「弱爆」表情分别以 100% 轮盘/100% 图标、150%/140%、200%/180% 绘制（2× 背景），另加一格把该表情放在中央。人工核对 200%/180% 一格：表情完整落在扇区内、未压分隔线、文字气泡里的「弱爆」清晰可读，其余线稿图标同样清晰；中央一格确认表情与标题正常绘制，且中央不留方向指示缺口。
- 中央信号改动涉及判定与渲染两处，均在同一渲染路径上验证：`WheelGeometry.selection` 与 `GestureMachine` 共用 `centreSignal`，`WheelView` 用同一个值决定中央图案与「无方向」状态。
- 素材与打包：`scripts/make_dmg.sh` 产出 `dist/LoLPing-v1.5.0-macOS-arm64.dmg`；`scripts/fetch_assets.py` 的镜像回退此前已实测可按字节重建素材。

## 素材来源

- 代码基础：`AllenTHT/LoLPing-Mac`（本仓库是其分支版本，保留上游提交历史）。
- 表情贴图与语音、八个警报音频：`darrenprx/lolPing` 的 `assets/`（MIT），只借素材。目录与全部 54 条音频映射见 `Resources/asset-sources.json`，完整第三方说明见 `THIRD-PARTY.md`。
- 轮盘矢量轮廓：CommunityDragon 15.24 的 `assets/ux/menu/` 图集，本地重建为可缩放路径。

## 实测限制

- 本机没有稳定的代码签名证书（`security find-identity` 为 0 条），每次重新构建都会改变 ad-hoc 签名，macOS 可能要求重新勾选辅助功能授权。
- 未在本机授予辅助功能权限，**全局组合键的实机触发（真实按住 ⌃⌥⌘ 出轮盘、松开发送）本轮未实测**；已实测的是同一条状态机的单元测试、渲染自检与从 DMG 安装后正常启动。
- 设置窗口里的交互控件（圆盘预览的移入/点击、四个滑块、「中央」下拉框）本机无法自动化点击验证：终端没有辅助功能权限，AppleScript 读不到窗口控件树。这些控件调用的判定逻辑（含中央信号、不同格数轮盘）都有单元测试覆盖，控件本身需人工点一下确认。
- 「轮盘大小」会同时决定中央判定圈的半径（视觉与判定必须一致），因此滑块只影响全局手势的判定圈，不影响「信号试用」区域里点击按钮的预览。
- 外接屏、全屏应用覆盖、系统显示缩放仍未实测。
