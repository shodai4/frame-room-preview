import Foundation

/// 作品をかける壁。
enum WallStyle: String, CaseIterable, Identifiable, Hashable {
    /// ギャラリーの白壁
    case gallery
    /// 木目のリビング
    case wood
    /// モルタル
    case concrete
    /// 暗い展示室
    case darkHall
    /// 自分の部屋の写真
    case roomPhoto

    var id: String { rawValue }

    var name: String {
        switch self {
        case .gallery: return "白壁"
        case .wood: return "木目"
        case .concrete: return "モルタル"
        case .darkHall: return "暗室"
        case .roomPhoto: return "自室"
        }
    }

    /// 暗い壁かどうか（キャプションや枠の色を決める）。
    var isDark: Bool {
        self == .darkHall
    }
}
