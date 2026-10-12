import Foundation
import CoreGraphics

public enum PingKind: String, CaseIterable, Identifiable {
    case retreat, push, onMyWay, allIn, assist, needVision, missing, enemyVision, weak, generic
    public var id: String { rawValue }
    /// Signals that can sit on the ring, clockwise from north in the game's own
    /// order. `generic` stays out: it is the centre, sent by a plain press.
    public static let ring: [PingKind] = [.retreat, .push, .onMyWay, .allIn, .assist, .needVision, .missing, .enemyVision, .weak]
    /// Ships with the local 弱爆 signal at the top in place of the retreat alert.
    /// Eight slots keep the game's exact 45° spacing, so every other alert stays
    /// where players expect it; the layout is editable in the app.
    public static let defaultWheel: [PingKind] = [.weak, .push, .onMyWay, .allIn, .assist, .needVision, .missing, .enemyVision]
    /// Position on a given ring order, clockwise from north; nil when absent.
    public func index(in order: [PingKind]) -> Int? { order.firstIndex(of: self) }
    /// Decodes a persisted ring layout, dropping unknown names and the centre-only
    /// signal. Returns nil when too little survives to be a ring, so callers fall
    /// back to `defaultWheel` instead of showing a broken wheel.
    public static func decodeWheelOrder(_ raw: [String], minimumSlots: Int = 3) -> [PingKind]? {
        let order = raw.compactMap(PingKind.init(rawValue:)).filter { ring.contains($0) }
        return order.count >= minimumSlots ? order : nil
    }
    public var title: String {
        switch self {
        case .retreat: return "撤退"
        case .push: return "推进"
        case .onMyWay: return "正在路上"
        case .allIn: return "全力进攻"
        case .assist: return "请求协助"
        case .needVision: return "需要视野"
        case .missing: return "敌人消失"
        case .enemyVision: return "敌方视野"
        case .weak: return "弱爆"
        case .generic: return "普通信号"
        }
    }
    public var iconName: String {
        switch self {
        case .retreat: return "retreat"
        case .push: return "push"
        case .onMyWay: return "on_my_way_new"
        case .allIn: return "all_in"
        case .assist: return "assist"
        case .needVision: return "need_ward"
        case .missing: return "mia_new"
        case .enemyVision: return "area_is_warded_small_red_new"
        case .weak: return "weak"
        case .generic: return "ping"
        }
    }
    public var soundName: String {
        switch self {
        case .retreat: return "retreat"
        case .push: return "push"
        case .onMyWay: return "on_my_way"
        case .allIn: return "all_in"
        case .assist: return "assist_me"
        case .needVision: return "need_vision"
        case .missing: return "q_mark"
        case .enemyVision: return "enemy_vision"
        case .weak: return "weak"
        case .generic: return "alert"
        }
    }
}

public struct Modifiers: OptionSet, Equatable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let control = Modifiers(rawValue: 1)
    public static let option = Modifiers(rawValue: 2)
    public static let command = Modifiers(rawValue: 4)
    public static let shift = Modifiers(rawValue: 8)
}

public enum TriggerChord: String, CaseIterable, Identifiable {
    case controlOptionCommand, controlOptionShift, controlCommandShift
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .controlOptionCommand: return "⌃ ⌥ ⌘  Control + Option + Command"
        case .controlOptionShift: return "⌃ ⌥ ⇧  Control + Option + Shift"
        case .controlCommandShift: return "⌃ ⌘ ⇧  Control + Command + Shift"
        }
    }
    public var symbols: String {
        switch self {
        case .controlOptionCommand: return "⌃  ⌥  ⌘"
        case .controlOptionShift: return "⌃  ⌥  ⇧"
        case .controlCommandShift: return "⌃  ⌘  ⇧"
        }
    }
    public var modifiers: Modifiers {
        switch self {
        case .controlOptionCommand: return [.control, .option, .command]
        case .controlOptionShift: return [.control, .option, .shift]
        case .controlCommandShift: return [.control, .command, .shift]
        }
    }
}

public enum WheelGeometry {
    public static let centerRadius: CGFloat = 66
    public static let iconRadius: CGFloat = 101
    public static let outerRadius: CGFloat = 140

    /// Slot 0 sits on north and slots run clockwise, so an eight-slot ring keeps
    /// the game's 45° spacing and a reordered ring stays predictable.
    public static func step(_ count: Int) -> CGFloat { 2 * .pi / CGFloat(max(count, 1)) }
    /// Clockwise-from-north angle of a slot centre, matching `direction(at:)`.
    public static func angle(forIndex index: Int, count: Int) -> CGFloat { CGFloat(index) * step(count) }

    /// Clockwise from north; nil in the ordinary Ping region.
    public static func direction(at point: CGPoint, center: CGPoint, deadZone: CGFloat) -> CGFloat? {
        let dx = point.x - center.x, dy = point.y - center.y
        guard hypot(dx, dy) > deadZone else { return nil }
        return atan2(dx, dy)
    }
    /// Coordinates use the AppKit convention: y increases upwards.
    public static func selection(at point: CGPoint, center: CGPoint, deadZone: CGFloat,
                                 order: [PingKind] = PingKind.defaultWheel) -> PingKind {
        let dx = point.x - center.x, dy = point.y - center.y
        guard hypot(dx, dy) > deadZone, !order.isEmpty else { return .generic }
        let clockwiseFromNorth = atan2(dx, dy)
        let step = step(order.count)
        let index = Int(floor((clockwiseFromNorth + step / 2) / step))
        return order[(index % order.count + order.count) % order.count]
    }

    public static func clampedCenter(anchor: CGPoint, frame: CGRect, radius: CGFloat) -> CGPoint {
        func clamp(_ value: CGFloat, _ low: CGFloat, _ high: CGFloat) -> CGFloat {
            low > high ? (low + high) / 2 : min(max(value, low), high)
        }
        return CGPoint(x: clamp(anchor.x, frame.minX + radius, frame.maxX - radius),
                       y: clamp(anchor.y, frame.minY + radius, frame.maxY - radius))
    }
}
