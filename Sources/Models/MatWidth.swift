import Foundation

/// マット（額縁と作品のあいだの白い紙）の幅。
enum MatWidth: String, CaseIterable, Identifiable, Hashable {
    case none
    case thin
    case standard
    case wide

    var id: String { rawValue }

    var name: String {
        switch self {
        case .none: return "なし"
        case .thin: return "細"
        case .standard: return "標準"
        case .wide: return "広"
        }
    }

    /// 一辺の幅（mm）。
    var widthMM: Double {
        switch self {
        case .none: return 0
        case .thin: return 30
        case .standard: return 60
        case .wide: return 100
        }
    }
}
