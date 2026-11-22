import SwiftUI
import UIKit

/// 壁。画像素材を使わず、面の勾配と薄い重なりだけで作る。
struct WallSurface: View {
    let style: WallStyle
    let photo: UIImage?

    var body: some View {
        ZStack {
            base
            light
        }
        .clipped()
    }

    @ViewBuilder private var base: some View {
        switch style {
        case .roomPhoto:
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                Canvas { context, size in
                    WallTexture.draw(style: .gallery, context: context, size: size)
                }
            }
        default:
            Canvas { context, size in
                WallTexture.draw(style: style, context: context, size: size)
            }
        }
    }

    /// 照明むら。壁ごとに落とす濃さを変える。
    private var light: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.05),
                Color.clear,
                Color.black.opacity(style.isDark ? 0.18 : 0.07)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

/// 壁の下地。細かい粒と木目は決まった並びで描く（毎回同じ見た目にする）。
enum WallTexture {
    static func draw(style: WallStyle, context: GraphicsContext, size: CGSize) {
        guard size.width > 1, size.height > 1 else { return }
        let bounds = CGRect(origin: .zero, size: size)
        let full = Path(bounds)

        switch style {
        case .gallery:
            fill(full, context: context, size: size,
                 top: Color(hex: 0xF8F6F1), middle: Color(hex: 0xEFEBE2), bottom: Color(hex: 0xE2DDD2))
            // 左からの柔らかい光
            context.fill(
                Path(CGRect(x: 0, y: 0, width: size.width * 0.7, height: size.height)),
                with: .linearGradient(Gradient(colors: [Color.white.opacity(0.16), Color.clear]),
                                      startPoint: CGPoint(x: 0, y: 0),
                                      endPoint: CGPoint(x: size.width * 0.7, y: 0))
            )
            baseboard(context: context, size: size, darkness: 0.10)

        case .wood:
            fill(full, context: context, size: size,
                 top: Color(hex: 0xCBA97C), middle: Color(hex: 0xBB9868), bottom: Color(hex: 0xA5835A))
            var random = SeededRandom(seed: 21)
            let plank = max(28, size.width / 5)
            var x: CGFloat = 0
            while x < size.width {
                let tint = 0.02 + random.next() * 0.05
                context.fill(Path(CGRect(x: x, y: 0, width: plank, height: size.height)),
                             with: .color(Color.black.opacity(tint)))
                context.stroke(Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }, with: .color(Color.black.opacity(0.13)), lineWidth: 1)
                x += plank
            }
            for _ in 0..<70 {
                let grainX = CGFloat(random.next()) * size.width
                let grainWidth = 0.6 + CGFloat(random.next()) * 1.6
                let alpha = 0.03 + random.next() * 0.05
                context.fill(Path(CGRect(x: grainX, y: 0, width: grainWidth, height: size.height)),
                             with: .color(Color.black.opacity(alpha)))
            }
            baseboard(context: context, size: size, darkness: 0.22)

        case .concrete:
            fill(full, context: context, size: size,
                 top: Color(hex: 0xD6D2CB), middle: Color(hex: 0xC5C1BA), bottom: Color(hex: 0xB1ADA6))
            var random = SeededRandom(seed: 7)
            for _ in 0..<9 {
                let width = size.width * (0.25 + CGFloat(random.next()) * 0.5)
                let height = size.height * (0.15 + CGFloat(random.next()) * 0.4)
                let originX = CGFloat(random.next()) * size.width - width * 0.3
                let originY = CGFloat(random.next()) * size.height - height * 0.3
                let alpha = 0.02 + random.next() * 0.04
                context.fill(Path(ellipseIn: CGRect(x: originX, y: originY, width: width, height: height)),
                             with: .color(Color.black.opacity(alpha)))
            }
            for _ in 0..<340 {
                let dotX = CGFloat(random.next()) * size.width
                let dotY = CGFloat(random.next()) * size.height
                let dotSize = 0.6 + CGFloat(random.next()) * 1.6
                let alpha = 0.03 + random.next() * 0.07
                context.fill(Path(ellipseIn: CGRect(x: dotX, y: dotY, width: dotSize, height: dotSize)),
                             with: .color(Color.black.opacity(alpha)))
            }
            baseboard(context: context, size: size, darkness: 0.16)

        case .darkHall:
            fill(full, context: context, size: size,
                 top: Color(hex: 0x2E2E31), middle: Color(hex: 0x232326), bottom: Color(hex: 0x121213))
            // 天井からのスポット
            context.fill(full, with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.11), Color.clear]),
                center: CGPoint(x: size.width * 0.32, y: -size.height * 0.15),
                startRadius: 0,
                endRadius: size.height * 0.85))
            context.fill(full, with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.07), Color.clear]),
                center: CGPoint(x: size.width * 0.78, y: -size.height * 0.25),
                startRadius: 0,
                endRadius: size.height * 0.9))
            // 床
            context.fill(Path(CGRect(x: 0, y: size.height * 0.9, width: size.width, height: size.height * 0.1)),
                         with: .linearGradient(Gradient(colors: [Color.black.opacity(0.35), Color.black.opacity(0.6)]),
                                               startPoint: CGPoint(x: 0, y: size.height * 0.9),
                                               endPoint: CGPoint(x: 0, y: size.height)))

        case .roomPhoto:
            fill(full, context: context, size: size,
                 top: Color(hex: 0xE9E5DE), middle: Color(hex: 0xDCD8D0), bottom: Color(hex: 0xCEC9C1))
        }
    }

    private static func fill(_ path: Path, context: GraphicsContext, size: CGSize,
                             top: Color, middle: Color, bottom: Color) {
        context.fill(path, with: .linearGradient(
            Gradient(colors: [top, middle, bottom]),
            startPoint: CGPoint(x: size.width * 0.2, y: 0),
            endPoint: CGPoint(x: size.width * 0.6, y: size.height)))
    }

    /// 幅木と床の落ち影。
    private static func baseboard(context: GraphicsContext, size: CGSize, darkness: Double) {
        let height = size.height * 0.055
        let top = size.height - height
        context.fill(Path(CGRect(x: 0, y: top, width: size.width, height: height)),
                     with: .linearGradient(Gradient(colors: [Color.black.opacity(darkness), Color.black.opacity(darkness * 0.25)]),
                                           startPoint: CGPoint(x: 0, y: top),
                                           endPoint: CGPoint(x: 0, y: size.height)))
        context.stroke(Path { path in
            path.move(to: CGPoint(x: 0, y: top))
            path.addLine(to: CGPoint(x: size.width, y: top))
        }, with: .color(Color.black.opacity(darkness * 0.9)), lineWidth: 1)
    }
}

/// 決まった並びの乱数。壁の粒と木目を毎回同じ位置に置く。
struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &* 6364136223846793005 &+ 1442695040888963407
    }

    /// 0〜1。
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double((state >> 11) & 0xFFFF_FFFF) / Double(0xFFFF_FFFF)
    }
}
