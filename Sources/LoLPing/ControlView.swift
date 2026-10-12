import SwiftUI
import AppKit
import PingCore

private enum Palette {
    static let background = Color(red: 0.035, green: 0.055, blue: 0.080)
    static let card = Color(red: 0.065, green: 0.090, blue: 0.120)
    static let gold = Color(red: 0.83, green: 0.70, blue: 0.44)
    static let secondary = Color(red: 0.59, green: 0.65, blue: 0.71)
}

struct ControlView: View {
    @ObservedObject var model: AppModel
    @State private var pointed: PingKind = .generic
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    statusCard
                    settingsCard
                    wheelCard
                    signalCard
                    emoteCard
                    footer
                }.padding(26)
            }
            sidePreview
        }
        .background(Palette.background)
        .preferredColorScheme(.dark)
        .tint(Palette.gold)
        .frame(minWidth: 1040, minHeight: 700)
    }

    /// Everything previewable lives here, outside the scroll view, so browsing the
    /// long emote list never scrolls the preview away.
    private var sidePreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            effectCard
            wheelCardPreview
            Spacer(minLength: 0)
        }
        .padding(.vertical, 26).padding(.trailing, 26)
        .frame(width: 372)
    }

    private var effectCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("信号预览").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(model.previewVisible ? model.previewKind.title : "点信号或表情试听")
                    .font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Palette.background)
                PreviewGrid().stroke(Palette.gold.opacity(0.06), lineWidth: 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                if model.previewVisible {
                    EffectPreview(kind: model.previewKind, scale: model.scale, token: model.previewToken)
                        .allowsHitTesting(false)
                } else {
                    VStack(spacing: 7) {
                        Image(systemName: "cursorarrow.rays").font(.system(size: 23, weight: .light)).foregroundStyle(Palette.gold.opacity(0.65))
                        Text("点选信号或表情，感受一下").font(.system(size: 11)).foregroundStyle(Palette.secondary)
                    }
                }
            }.frame(height: max(150, 150*model.scale)).clipped()
        }.padding(16).card()
    }

    /// The ring itself plus a 1:1 sample: the sample is drawn at the size the icon
    /// really gets on screen, so the two sliders show their effect immediately.
    private var wheelCardPreview: some View {
        let sample = Assets.wheelIconSide(pointed, weight: 0, iconScale: CGFloat(model.iconScale)) * CGFloat(model.wheelScale)
        let shown = min(sample, 300)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("轮盘预览").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("鼠标移入试方位 · 点一下试听").font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
            WheelPreview(order: model.wheelOrder, centreSignal: model.centreSignal) { kind in
                model.preview(kind)
            } onHover: { kind in
                pointed = kind
            }
            .frame(width: 300, height: 300)
            HStack(spacing: 8) {
                Text(pointed.isEmote || pointed == .generic ? pointed.title : "游戏信号 · " + pointed.title)
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(Color(nsColor: pointed.tint))
                Spacer()
                Text("\(WheelGeometry.compassLabel(forIndex: model.centreSignal.index(in: model.wheelOrder) ?? 0, count: max(model.wheelOrder.count, 1)))版式")
                    .font(.system(size: 9)).foregroundStyle(Palette.secondary)
            }
            if let icon = Assets.icon(pointed) {
                HStack(alignment: .bottom, spacing: 12) {
                    Image(nsImage: icon).resizable().interpolation(.high)
                        .frame(width: shown, height: shown)
                        .frame(width: 300, height: 120, alignment: .bottomLeading)
                        .clipped()
                    Spacer(minLength: 0)
                }
            }
            Text(sample <= 300
                 ? "尺寸样本（1:1）：轮盘 \(Int(model.wheelScale*100))% × 图标 \(Int(model.iconScale*100))% → 环内约 \(Int(sample))pt"
                 : "尺寸样本（截断）：实际约 \(Int(sample))pt，超出 300pt 放不下；轮盘 \(Int(model.wheelScale*100))% × 图标 \(Int(model.iconScale*100))%")
                .font(.system(size: 9)).foregroundStyle(Palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(16).card()
    }
    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "location.north.circle")
                .font(.system(size: 38, weight: .light)).foregroundStyle(Palette.gold)
                .frame(width: 54, height: 54)
                .background(Palette.gold.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .leading, spacing: 3) {
                Text("LoLPing").font(.system(size: 29, weight: .semibold, design: .rounded))
                Text("把信号，带到桌面。").font(.system(size: 12)).foregroundStyle(Palette.secondary)
            }
            Spacer()
            Text("MAC EDITION").font(.system(size: 9, weight: .semibold, design: .monospaced))
                .tracking(2).foregroundStyle(Palette.gold)
        }
    }
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().fill(model.isEnabled ? Color.green : (model.awaitingPermission ? Palette.gold : Palette.secondary))
                    .frame(width: 7, height: 7)
                Text("启用 Ping").font(.system(size: 17, weight: .semibold))
                Text(model.isEnabled ? "已开启" : (model.awaitingPermission ? "等待授权" : "已关闭"))
                    .font(.system(size: 11)).foregroundStyle(Palette.secondary)
                Spacer()
                Toggle("启用 Ping", isOn: Binding(get: { model.isEnabled || model.awaitingPermission }, set: { model.setEnabled($0) }))
                    .labelsHidden().toggleStyle(.switch).accessibilityLabel("启用 Ping")
            }
            Text(model.message).font(.system(size: 11)).foregroundStyle(Palette.secondary)
                .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("pingStatus")
            if model.awaitingPermission {
                HStack(spacing: 10) {
                    Button("打开辅助功能设置") { model.openAccessibility() }.buttonStyle(.borderedProminent)
                    Button("已授权，重新检查") { model.checkPermission() }.buttonStyle(.bordered)
                }.controlSize(.small)
                Text("仅监听操作所需按键，不读取或保存输入内容。授权后会自动开启。")
                    .font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
        }.padding(16).card()
    }
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("触发组合键", systemImage: "keyboard").font(.system(size: 12))
                Spacer()
                Picker("触发组合键", selection: $model.chord) {
                    ForEach(TriggerChord.allCases) { Text($0.title).tag($0) }
                }.labelsHidden().frame(width: 320).accessibilityLabel("触发组合键")
            }
            HStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("音量", systemImage: model.volume == 0 ? "speaker.slash" : "speaker.wave.2")
                        Spacer(); Text("\(Int(model.volume*100))%")
                    }.font(.system(size: 11)).foregroundStyle(Palette.secondary)
                    Slider(value: $model.volume, in: 0...1).accessibilityLabel("音量")
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("效果大小", systemImage: "arrow.up.left.and.arrow.down.right")
                        Spacer(); Text("\(Int(model.scale*100))%")
                    }.font(.system(size: 11)).foregroundStyle(Palette.secondary)
                    Slider(value: $model.scale, in: 0.75...1.5, step: 0.05).accessibilityLabel("效果大小")
                }
            }
            HStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("轮盘大小", systemImage: "circle.dashed")
                        Spacer(); Text("\(Int(model.wheelScale*100))%")
                    }.font(.system(size: 11)).foregroundStyle(Palette.secondary)
                    Slider(value: $model.wheelScale, in: 0.5...4, step: 0.05).accessibilityLabel("轮盘大小")
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("图标大小", systemImage: "photo")
                        Spacer(); Text("\(Int(model.iconScale*100))%")
                    }.font(.system(size: 11)).foregroundStyle(Palette.secondary)
                    Slider(value: $model.iconScale, in: 0.8...2.5, step: 0.05).accessibilityLabel("图标大小")
                }
            }
            Text("轮盘大小 0.5×–4×，同时决定中央判定圈；图标大小 0.8×–2.5×，只影响轮盘里的图标。表情（比如弱爆）默认就比线稿信号画得大，看不清就再放大这两项——右侧「尺寸样本」是环内真实大小。")
                .font(.system(size: 10)).foregroundStyle(Palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("按住 0.18 秒 → 移动选择 → 松开发送　 ·　 Esc / 右键取消")
                .font(.system(size: 10)).foregroundStyle(Palette.secondary)
        }.padding(16).card()
    }
    private var signalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("游戏信号").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("点一下在右侧预览并试听 · 无需授权").font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(PingKind.alerts + [PingKind.generic]) { kind in
                    Button { model.preview(kind) } label: {
                        HStack(spacing: 9) {
                            if let icon = Assets.icon(kind) { Image(nsImage: icon).resizable().frame(width: 25, height: 25) }
                            Text(kind.title).font(.system(size: 11, weight: .medium))
                            Spacer(minLength: 0)
                        }.padding(.horizontal, 12).frame(height: 42)
                        .background(model.previewKind == kind && model.previewVisible ? Color(nsColor: kind.tint).opacity(0.14) : Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityLabel("预览\(kind.title)")
                }
            }
        }.padding(16).card()
    }
    /// 左上/正上 rather than slot numbers; a ring that is not eight slots would
    /// repeat a compass name, so those get a small index suffix.
    private func compassLabel(_ index: Int) -> String {
        let name = WheelGeometry.compassLabel(forIndex: index, count: model.wheelOrder.count)
        return model.wheelOrder.count == 8 ? name : "\(name)·\(index+1)"
    }
    private var wheelCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("信号轮盘").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(model.wheelOrder.count == 8 ? "方位与游戏一致，顺时针排列" : "顺时针排列，第 1 个在正上方")
                    .font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
            HStack(spacing: 8) {
                Text("中央").font(.system(size: 11)).foregroundStyle(Palette.secondary)
                    .frame(width: 40, alignment: .trailing)
                if let icon = Assets.icon(model.centreSignal) { Image(nsImage: icon).resizable().frame(width: 20, height: 20) }
                Picker("中央信号", selection: $model.centreSignal) {
                    Section("游戏信号") { ForEach(PingKind.alerts + [PingKind.generic]) { Text($0.title).tag($0) } }
                    Section("表情") { ForEach(PingKind.emotes) { Text($0.title).tag($0) } }
                }.labelsHidden().frame(width: 210).accessibilityLabel("中央信号")
                Text("不选方向、直接松开时发送的信号 · 正中央").font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(model.wheelOrder.enumerated()), id: \.offset) { index, kind in
                    HStack(spacing: 8) {
                        Text(compassLabel(index))
                            .font(.system(size: 11, weight: .medium)).foregroundStyle(Palette.gold)
                            .frame(width: 40, alignment: .trailing)
                        if let icon = Assets.icon(kind) { Image(nsImage: icon).resizable().frame(width: 20, height: 20) }
                        Picker(compassLabel(index), selection: Binding(get: { kind }, set: { model.setWheelSlot(index, to: $0) })) {
                            Section("游戏信号") { ForEach(PingKind.alerts) { Text($0.title).tag($0) } }
                            Section("表情") { ForEach(PingKind.emotes) { Text($0.title).tag($0) } }
                        }.labelsHidden().frame(width: 210).accessibilityLabel(compassLabel(index) + "的信号")
                        Spacer(minLength: 0)
                        Button { model.rotateWheelSlot(index, by: 1) } label: { Image(systemName: "arrow.down") }
                            .buttonStyle(.borderless).help("与下一个方位交换").accessibilityLabel(compassLabel(index) + "下移")
                        Button { model.removeWheelSlot(at: index) } label: { Image(systemName: "minus.circle") }
                            .buttonStyle(.borderless).disabled(model.wheelOrder.count <= AppModel.minWheelSlots)
                            .help("移除这个方位").accessibilityLabel("移除" + compassLabel(index))
                    }
                }
            }
            HStack(spacing: 10) {
                Button("添加一个位置") { model.addWheelSlot() }
                    .buttonStyle(.bordered).controlSize(.small)
                    .disabled(model.unusedSignals.isEmpty)
                    .help(model.unusedSignals.isEmpty ? "所有信号都已经在轮盘上" : "把尚未使用的信号加到轮盘上")
                Button("恢复默认排布") { model.resetWheelOrder() }.buttonStyle(.bordered).controlSize(.small)
                Spacer()
                Text(model.unusedSignals.isEmpty ? "全部 \(PingKind.ring.count) 个信号都在轮盘上"
                                                 : "未使用：" + model.unusedSignals.map(\.title).joined(separator: "、"))
                    .font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
        }.padding(16).card()
    }
    private var emoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("表情").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("点一下试听音效 · 在「信号轮盘」里放进方位").font(.system(size: 10)).foregroundStyle(Palette.secondary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(PingKind.emotes) { kind in
                    Button { model.preview(kind) } label: {
                        HStack(spacing: 8) {
                            if let icon = Assets.icon(kind) { Image(nsImage: icon).resizable().frame(width: 24, height: 24) }
                            Text(kind.title).font(.system(size: 11, weight: .medium)).lineLimit(1)
                            Spacer(minLength: 0)
                        }.padding(.horizontal, 10).frame(height: 42)
                        .background(model.previewKind == kind && model.previewVisible ? Color(nsColor: kind.tint).opacity(0.14) : Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityLabel("预览\(kind.title)")
                }
            }
        }.padding(16).card()
    }
    private var footer: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("关闭窗口后仍在菜单栏运行").font(.system(size: 10)).foregroundStyle(Palette.secondary)
                Spacer()
                Menu("权限帮助") {
                    Button("辅助功能设置") { model.openAccessibility() }
                    Button("输入监控设置（按系统要求）") { model.openInputMonitoring() }
                }.menuStyle(.borderlessButton).fixedSize().font(.system(size: 11))
                Button("退出软件") { NSApp.terminate(nil) }.buttonStyle(.bordered).controlSize(.small)
            }
            Text("独立桌面工具，非 Riot 官方产品。游戏图标、表情与音效归 Riot Games 所有；音效取自游戏客户端音频。")
                .font(.system(size: 9)).foregroundStyle(Palette.secondary.opacity(0.7)).fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension View {
    func card() -> some View {
        background(Palette.card, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.gold.opacity(0.12), lineWidth: 1))
    }
}

private struct PreviewGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: CGFloat(0), through: rect.width, by: 24) {
            path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: CGFloat(0), through: rect.height, by: 24) {
            path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

/// The settings-window ring: the same renderer and the same selection maths as the
/// desktop overlay, driven by the mouse instead of the trigger chord.
private struct WheelPreview: NSViewRepresentable {
    let order: [PingKind]
    let centreSignal: PingKind
    let onPick: (PingKind) -> Void
    let onHover: (PingKind) -> Void
    func makeNSView(context: Context) -> WheelView {
        let view = WheelView(frame: NSRect(x: 0, y: 0, width: 240, height: 240))
        view.isInteractive = true
        view.order = order
        view.centreSignal = centreSignal
        view.onPick = onPick
        view.onHover = onHover
        view.setSelection(centreSignal, angle: nil, animated: false)
        return view
    }
    func updateNSView(_ view: WheelView, context: Context) {
        view.order = order
        view.centreSignal = centreSignal
        view.onPick = onPick
        view.onHover = onHover
        // A changed layout invalidates whatever the pointer was pointing at.
        view.setSelection(centreSignal, angle: nil, animated: false)
        view.needsDisplay = true
    }
}

private struct EffectPreview: NSViewRepresentable {
    let kind: PingKind
    let scale: Double
    let token: UUID
    final class Coordinator { var token: UUID? }
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeNSView(context: Context) -> NSView { NSView() }
    func updateNSView(_ view: NSView, context: Context) {
        guard context.coordinator.token != token else { return }
        context.coordinator.token = token
        view.subviews.forEach { ($0 as? PingEffectView)?.stop(); $0.removeFromSuperview() }
        let effect = PingEffectView(frame: view.bounds, kind: kind, scale: CGFloat(scale))
        effect.autoresizingMask = [.width, .height]
        view.addSubview(effect)
        DispatchQueue.main.async { [weak effect] in effect?.start() }
    }
    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        nsView.subviews.forEach { ($0 as? PingEffectView)?.stop() }
    }
}
