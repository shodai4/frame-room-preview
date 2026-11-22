import Foundation

/// 号数。F0〜F20 の長辺 × 短辺（mm）。
///
/// 寸法は JIS 規格の F 判（図版）に合わせた呼び寸法で、実際の製品は数 mm の幅がある。
/// ここでは額装の見当をつけるための基準値として扱う。
enum CanvasSize: String, CaseIterable, Identifiable, Hashable {
    case f0, f1, f2, f3, f4, f5, f6, f8, f10, f12, f15, f20

    var id: String { rawValue }

    /// 「F10」のような表記。
    var name: String { rawValue.uppercased() }

    /// 長辺（mm）。
    var widthMm: Double {
        switch self {
        case .f0: return 180
        case .f1: return 220
        case .f2: return 240
        case .f3: return 273
        case .f4: return 333
        case .f5: return 350
        case .f6: return 410
        case .f8: return 455
        case .f10: return 530
        case .f12: return 606
        case .f15: return 652
        case .f20: return 727
        }
    }

    /// 短辺（mm）。
    var heightMm: Double {
        switch self {
        case .f0: return 140
        case .f1: return 160
        case .f2: return 190
        case .f3: return 220
        case .f4: return 242
        case .f5: return 250
        case .f6: return 318
        case .f8: return 380
        case .f10: return 455
        case .f12: return 500
        case .f15: return 530
        case .f20: return 606
        }
    }

    /// 長辺 ÷ 短辺。
    var aspectRatio: Double { widthMm / heightMm }

    /// 「530 × 455 mm」
    var dimensionText: String {
        String(format: "%d × %d mm", Int(widthMm.rounded()), Int(heightMm.rounded()))
    }

    /// 「1.16：1」
    var aspectText: String {
        String(format: "%.2f：1", aspectRatio)
    }

    /// 「F10　530 × 455 mm　1.16：1」
    var caption: String {
        "\(name)　\(dimensionText)　\(aspectText)"
    }

    /// 近い方の号数（読み込み直後の初期値に使う）。
    static func nearest(toRatio ratio: Double) -> CanvasSize {
        allCases.min { abs($0.aspectRatio - ratio) < abs($1.aspectRatio - ratio) } ?? .f10
    }
}
