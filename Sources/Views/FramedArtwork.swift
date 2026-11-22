import SwiftUI
import UIKit

/// 壁にかかった一枚。作品 → マット → 額縁の順に重ね、2 層の影と傾きを付ける。
struct FramedArtwork: View {
    let image: UIImage
    let layout: FrameLayout
    let style: FrameStyle
    let tilt: Double
    let sideColor: Color

    var body: some View {
        artwork
            .padding(layout.matWidth)
            .background(Theme.matPaper)
            .padding(layout.frameWidth)
            .background(FrameBorder(style: style,
                                    frameWidth: layout.frameWidth,
                                    unit: unit,
                                    sideColor: sideColor))
            // 接地した濃い影
            .shadow(color: .black.opacity(contactOpacity), radius: contactRadius, x: 0.4, y: contactOffset)
            // 壁に広がる淡い影
            .shadow(color: .black.opacity(ambientOpacity), radius: ambientRadius, x: unit * 3, y: unit * 8)
            .rotationEffect(.degrees(tilt))
    }

    private var artwork: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: max(1, layout.artworkSize.width), height: max(1, layout.artworkSize.height))
            .clipped()
            .overlay(Rectangle().strokeBorder(Color.black.opacity(0.12), lineWidth: 0.6))
            .shadow(color: .black.opacity(0.20), radius: matBevel, x: 0, y: matBevel * 0.5)
    }

    private var unit: CGFloat { max(layout.pointPerMM, 0.05) }

    /// 額縁が厚いほど影を濃く、遠くへ。
    private var depth: Double { style.depthMM / 24 }

    private var contactOpacity: Double { min(0.34, 0.20 + 0.06 * depth) }
    private var contactRadius: CGFloat { max(0.7, unit * 1.1) }
    private var contactOffset: CGFloat { max(0.9, unit * 2.0) }
    private var ambientOpacity: Double { min(0.16, 0.08 + 0.03 * depth) }
    private var ambientRadius: CGFloat { max(7, unit * 18) }

    /// マットの切り口の影。マットがなければごく薄く。
    private var matBevel: CGFloat {
        min(max(layout.matWidth * 0.14, 0.4), 3.5)
    }
}
