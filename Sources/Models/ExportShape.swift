import Foundation

/// 書き出しの比率。
enum ExportShape: String, CaseIterable, Identifiable, Hashable {
    case square
    case portrait

    var id: String { rawValue }

    var name: String {
        switch self {
        case .square: return "1:1"
        case .portrait: return "4:5"
        }
    }

    /// 幅 ÷ 高さ。
    var ratio: Double {
        switch self {
        case .square: return 1.0
        case .portrait: return 0.8
        }
    }
}
