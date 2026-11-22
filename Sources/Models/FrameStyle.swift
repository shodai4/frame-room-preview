import Foundation

/// 額縁。画像素材は使わず、面の勾配と稜線だけで質感を作る。
enum FrameStyle: String, CaseIterable, Identifiable, Hashable {
    /// 額なし（キャンバスの側面塗り）
    case none
    /// 木枠ナチュラル
    case woodNatural
    /// ウォルナット
    case walnut
    /// アンティーク金縁
    case antiqueGold
    /// 黒細アルミ
    case aluminiumBlack

    var id: String { rawValue }

    var name: String {
        switch self {
        case .none: return "額なし"
        case .woodNatural: return "木枠"
        case .walnut: return "ウォルナット"
        case .antiqueGold: return "金縁"
        case .aluminiumBlack: return "アルミ黒"
        }
    }

    /// 一辺の見付け幅（mm）。額なしは側面の塗り縁。
    var sideWidthMM: Double {
        switch self {
        case .none: return 3
        case .woodNatural: return 28
        case .walnut: return 34
        case .antiqueGold: return 42
        case .aluminiumBlack: return 10
        }
    }

    /// 木目の線を入れるか。
    var hasGrain: Bool {
        self == .woodNatural || self == .walnut
    }

    /// 額縁の厚み（壁から出る量、mm）。影の強さに使う。
    var depthMM: Double {
        switch self {
        case .none: return 2
        case .woodNatural: return 24
        case .walnut: return 30
        case .antiqueGold: return 34
        case .aluminiumBlack: return 16
        }
    }
}
