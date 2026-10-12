import Foundation
import CoreGraphics

public enum PingKind: String, CaseIterable, Identifiable {
    /// Riot's eight alerts, then the centre signal.
    case retreat, push, onMyWay, allIn, assist, needVision, missing, enemyVision, generic
    /// Emotes — the taunt/expression signals. The raw value is the asset base
    /// name: art at `Resources/Emotes/<raw>.png`, voice at `Resources/Sounds/<raw>.mp3`.
    /// Generated from `darrenprx/lolPing`'s emote catalog (see asset-sources.json).
    case unworthy
    case unworthyCn = "unworthy_cn"
    case facepalm
    case poroSnax = "poro_snax"
    case sadKitten = "sad_kitten"
    case cheekyPoro = "cheeky_poro"
    case angryKitty = "angry_kitty"
    case ggHeart = "gg_heart"
    case beeHappy = "bee_happy"
    case beeMad = "bee_mad"
    case beeSad = "bee_sad"
    case snoozyPoro = "snoozy_poro"
    case wahaha
    case omgLoveIt = "omg_love_it"
    case poroRide = "poro_ride"
    case dontMakeMeLaugh = "dont_make_me_laugh"
    case woahDizzy = "woah_dizzy"
    case hahaHilarious = "haha_hilarious"
    case gasp
    case superApproved = "super_approved"
    case pain
    case laughingOutLoud = "laughing_out_loud"
    case hatsOff = "hats_off"
    case callMe = "call_me"
    case thinkAboutIt = "think_about_it"
    case unimpressed
    case didYouJust = "did_you_just"
    case niceTry = "nice_try"
    case nice
    case despair
    case doesNotCompute = "does_not_compute"
    case comeAtMe = "come_at_me"
    case howCouldYou = "how_could_you"
    case scoutApproved = "scout_approved"
    case maybeNextTime = "maybe_next_time"
    case okay
    case goodJobBuddy = "good_job_buddy"
    case teamwork
    case iWillDestroyYou = "i_will_destroy_you"
    case notToday = "not_today"
    case oh
    case comeAgain = "come_again"
    case magpieOopsie = "magpie_oopsie"
    case suchFoolishness = "such_foolishness"
    public var id: String { rawValue }
    /// Riot's alerts, clockwise from north in the game's own order.
    public static let alerts: [PingKind] = [.retreat, .push, .onMyWay, .allIn, .assist, .needVision, .missing, .enemyVision]
    public static let emotes: [PingKind] = [
        .unworthy,
        .unworthyCn,
        .facepalm,
        .poroSnax,
        .sadKitten,
        .cheekyPoro,
        .angryKitty,
        .ggHeart,
        .beeHappy,
        .beeMad,
        .beeSad,
        .snoozyPoro,
        .wahaha,
        .omgLoveIt,
        .poroRide,
        .dontMakeMeLaugh,
        .woahDizzy,
        .hahaHilarious,
        .gasp,
        .superApproved,
        .pain,
        .laughingOutLoud,
        .hatsOff,
        .callMe,
        .thinkAboutIt,
        .unimpressed,
        .didYouJust,
        .niceTry,
        .nice,
        .despair,
        .doesNotCompute,
        .comeAtMe,
        .howCouldYou,
        .scoutApproved,
        .maybeNextTime,
        .okay,
        .goodJobBuddy,
        .teamwork,
        .iWillDestroyYou,
        .notToday,
        .oh,
        .comeAgain,
        .magpieOopsie,
        .suchFoolishness,
    ]
    /// Everything that can be placed on the ring, alerts first. `generic` stays
    /// out: it is the centre, sent by a plain press.
    public static let ring: [PingKind] = alerts + emotes
    /// Ships with the game's own wheel; any slot can be swapped for an emote in
    /// the settings window.
    public static let defaultWheel: [PingKind] = alerts
    public var isEmote: Bool { PingKind.emotes.contains(self) }
    static let emoteTitles: [PingKind: String] = [
        .unworthy: "弱爆",
        .unworthyCn: "弱爆（文字版）",
        .facepalm: "捂脸",
        .poroSnax: "魄罗佳肴",
        .sadKitten: "悲伤猫咪",
        .cheekyPoro: "调皮魄罗",
        .angryKitty: "我生气了！",
        .ggHeart: "精彩的对局 <3",
        .beeHappy: "小蜜蜂 高兴",
        .beeMad: "小蜜蜂 疯狂",
        .beeSad: "小蜜蜂 悲伤",
        .snoozyPoro: "打盹魄罗",
        .wahaha: "笑哭我了",
        .omgLoveIt: "我的天，爱死它了",
        .poroRide: "溜了溜了",
        .dontMakeMeLaugh: "xswl",
        .woahDizzy: "晕晕",
        .hahaHilarious: "哈哈笑死",
        .gasp: "倒吸一口凉气！",
        .superApproved: "超赞的",
        .pain: "强颜欢笑",
        .laughingOutLoud: "哈哈哈",
        .hatsOff: "脱帽致意",
        .callMe: "双击666！",
        .thinkAboutIt: "脑子是个好东西",
        .unimpressed: "凡人！动态表情",
        .didYouJust: "动态 我太难了！",
        .niceTry: "棒棒哒",
        .nice: "干得漂亮",
        .despair: "呜呜呜---",
        .doesNotCompute: "无法求解",
        .comeAtMe: "放马过来",
        .howCouldYou: "你怎能这样",
        .scoutApproved: "提莫说很好",
        .maybeNextTime: "也许下次",
        .okay: "OK",
        .goodJobBuddy: "干得好，伙计！",
        .teamwork: "团队协作！",
        .iWillDestroyYou: "你瞅啥？",
        .notToday: "没门！",
        .oh: "大受震撼",
        .comeAgain: "一脸问号",
        .magpieOopsie: "雀实有问题",
        .suchFoolishness: "如此愚蠢",
    ]
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
        case .generic: return "普通信号"
        default: return PingKind.emoteTitles[self] ?? rawValue
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
        case .generic: return "ping"
        /// An emote's asset base name.
        default: return rawValue
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
        case .generic: return "alert"
        /// An emote's asset base name.
        default: return rawValue
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
    /// Compass name of a slot, so settings can talk about 左上/正上 instead of
    /// slot numbers. Rings that are not eight slots reuse the nearest name.
    public static func compassLabel(forIndex index: Int, count: Int) -> String {
        let names = ["正上", "右上", "正右", "右下", "正下", "左下", "正左", "左上"]
        guard count > 0 else { return "" }
        let slot = Int((angle(forIndex: index, count: count) / (.pi / 4)).rounded()) % 8
        return names[(slot + 8) % 8]
    }

    /// Clockwise from north; nil in the ordinary Ping region.
    public static func direction(at point: CGPoint, center: CGPoint, deadZone: CGFloat) -> CGFloat? {
        let dx = point.x - center.x, dy = point.y - center.y
        guard hypot(dx, dy) > deadZone else { return nil }
        return atan2(dx, dy)
    }
    /// Slot under a point, clockwise from north; nil means the hub. Coordinates
    /// use the AppKit convention: y increases upwards.
    public static func slotIndex(at point: CGPoint, center: CGPoint, deadZone: CGFloat, count: Int) -> Int? {
        guard count > 0 else { return nil }
        let dx = point.x - center.x, dy = point.y - center.y
        guard hypot(dx, dy) > deadZone else { return nil }
        let step = step(count)
        let index = Int(floor((atan2(dx, dy) + step / 2) / step))
        return (index % count + count) % count
    }
    /// `centreSignal` is what a plain press sends, so it can be any signal the
    /// user picked — including an emote.
    public static func selection(at point: CGPoint, center: CGPoint, deadZone: CGFloat,
                                 order: [PingKind] = PingKind.defaultWheel,
                                 centreSignal: PingKind = .generic) -> PingKind {
        guard !order.isEmpty else { return centreSignal }
        guard let index = slotIndex(at: point, center: center, deadZone: deadZone, count: order.count) else {
            return centreSignal
        }
        return order[index]
    }

    public static func clampedCenter(anchor: CGPoint, frame: CGRect, radius: CGFloat) -> CGPoint {
        func clamp(_ value: CGFloat, _ low: CGFloat, _ high: CGFloat) -> CGFloat {
            low > high ? (low + high) / 2 : min(max(value, low), high)
        }
        return CGPoint(x: clamp(anchor.x, frame.minX + radius, frame.maxX - radius),
                       y: clamp(anchor.y, frame.minY + radius, frame.maxY - radius))
    }
}
