import SwiftUI

/// 額縁の断面。画像素材を使わず、面の勾配・稜線・溝の重なりで質感を作る。
struct FrameBorder: View {
    let style: FrameStyle
    let frameWidth: CGFloat
    /// 1mm あたりの pt。線の太さを実寸に合わせる。
    let unit: CGFloat
    /// 額なしの側面に塗る色（作品の平均色）。
    let sideColor: Color

    var body: some View {
        ZStack {
            Rectangle().fill(base)
            Rectangle().fill(sheen)
            if style.hasGrain {
                FrameGrain(color: Color(hex: 0x2A1B10), alpha: style == .walnut ? 0.20 : 0.13)
            }
            Rectangle().fill(specular)
            // 内側の溝
            Rectangle()
                .strokeBorder(Color.black.opacity(innerShadowOpacity), lineWidth: max(0.6, unit * 1.0))
                .padding(max(0, frameWidth - unit * 1.2))
            // 外周の稜線
            Rectangle()
                .strokeBorder(Color.white.opacity(edgeLightOpacity), lineWidth: max(0.4, unit * 0.4))
                .padding(unit * 0.25)
        }
    }

    private var base: LinearGradient {
        let colors: [Color]
        switch style {
        case .none:
            colors = [sideColor.deepened(by: 0.10), sideColor.deepened(by: 0.30), sideColor.deepened(by: 0.48)]
        case .woodNatural:
            colors = [Color(hex: 0xE2CCA9), Color(hex: 0xCDB084), Color(hex: 0xB39468)]
        case .walnut:
            colors = [Color(hex: 0x7E573B), Color(hex: 0x61432D), Color(hex: 0x483020)]
        case .antiqueGold:
            colors = [Color(hex: 0xE9D8A6), Color(hex: 0xC2A157), Color(hex: 0x90712D)]
        case .aluminiumBlack:
            colors = [Color(hex: 0x3C3C40), Color(hex: 0x2A2A2D), Color(hex: 0x1A1A1C)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// 上左が明るく、下右が沈む面の勾配。
    private var sheen: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(style == .aluminiumBlack ? 0.12 : 0.22),
                Color.clear,
                Color.black.opacity(style == .aluminiumBlack ? 0.26 : 0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 金の照り、アルミの反射。
    private var specular: LinearGradient {
        switch style {
        case .antiqueGold:
            return LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.00), location: 0.00),
                    .init(color: Color.white.opacity(0.50), location: 0.16),
                    .init(color: Color.clear, location: 0.28),
                    .init(color: Color.black.opacity(0.26), location: 0.58),
                    .init(color: Color.white.opacity(0.28), location: 0.84),
                    .init(color: Color.clear, location: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .aluminiumBlack:
            return LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.30), location: 0.00),
                    .init(color: Color.clear, location: 0.22),
                    .init(color: Color.clear, location: 0.80),
                    .init(color: Color.white.opacity(0.12), location: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .walnut:
            return LinearGradient(colors: [Color.white.opacity(0.10), Color.clear], startPoint: .topLeading, endPoint: .center)
        default:
            return LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom)
        }
    }

    private var innerShadowOpacity: Double {
        switch style {
        case .none: return 0.45
        case .aluminiumBlack: return 0.55
        default: return 0.38
        }
    }

    private var edgeLightOpacity: Double {
        switch style {
        case .aluminiumBlack: return 0.30
        case .antiqueGold: return 0.40
        case .none: return 0.18
        default: return 0.34
        }
    }
}

/// 木目の細い線。額縁の幅の中だけに走らせる。
struct FrameGrain: View {
    let color: Color
    let alpha: Double

    var body: some View {
        Canvas { context, size in
            guard size.width > 1, size.height > 1 else { return }
            var random = SeededRandom(seed: 13)
            for _ in 0..<30 {
                let x = CGFloat(random.next()) * size.width
                let lineWidth = 0.4 + CGFloat(random.next()) * 1.1
                let opacity = alpha * (0.35 + random.next() * 0.65)
                context.fill(Path(CGRect(x: x, y: 0, width: lineWidth, height: size.height)),
                             with: .color(color.opacity(opacity)))
            }
        }
        .clipped()
    }
}
