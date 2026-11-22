import SwiftUI

// MARK: - 寸法の基準色と書体

/// 引き算の美学。アイボリーの紙、墨の文字、消炭の補助。
enum Theme {
    /// アイボリー #F9F8F5
    static let paper = Color(hex: 0xF9F8F5)
    /// 一段沈んだ紙（プレビューの縁、区切り）
    static let paperDeep = Color(hex: 0xF1EFE8)
    /// 墨色 #1A1A1B
    static let ink = Color(hex: 0x1A1A1B)
    /// 消炭色 #4A4A4A
    static let charcoal = Color(hex: 0x4A4A4A)
    /// 罫線。細く、濃すぎない。
    static let hairline = Color(hex: 0x2E2E2E).opacity(0.14)
    /// マット紙の白。壁の白よりわずかに明るい。
    static let matPaper = Color(hex: 0xFCFBF7)

    /// 本文・操作の文字。
    static func label(_ size: CGFloat = 12, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    /// 寸法・数値の文字。等幅で、美術館のキャプションのように。
    static func mono(_ size: CGFloat = 11, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    /// 明るさを保ったまま濃くする（額なしの側面塗りに使う）。
    func deepened(by amount: Double) -> Color {
        let ui = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard ui.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return self }
        let factor = CGFloat(max(0, 1 - amount))
        return Color(.sRGB,
                     red: Double(red * factor),
                     green: Double(green * factor),
                     blue: Double(blue * factor),
                     opacity: Double(alpha))
    }
}

// MARK: - 細い線

/// 高さ 1pt の罫線。影をつけず、紙の上に置く。
struct Hairline: View {
    var body: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
    }
}
