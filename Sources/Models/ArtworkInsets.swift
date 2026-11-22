import CoreGraphics
import Foundation

/// 四隅（上下左右）の裁ち落とし。画像の一辺に対する割合で持つ。
///
/// 額装では作品の縁が少し隠れる。ここでは簡易トリミングとして、
/// 表示の前に画像そのものを切り落とす（書き出しにも同じ割合をかける）。
struct ArtworkInsets: Equatable {
    var top: Double = 0
    var bottom: Double = 0
    var left: Double = 0
    var right: Double = 0

    static let zero = ArtworkInsets()

    var isZero: Bool {
        top == 0 && bottom == 0 && left == 0 && right == 0
    }

    /// 一辺あたりの上限（%). 上下（左右）を合わせて 80% まで。
    static let perSideLimit: Double = 0.45
    static let combinedLimit: Double = 0.80
}

/// 裁ち落としの矩形計算。UI から切り離して検証できるようにする。
enum CropGeometry {
    /// 入力を 0〜上限に収め、上下・左右の合計が 80% を超えないように縮める。
    static func normalized(_ insets: ArtworkInsets) -> ArtworkInsets {
        var result = ArtworkInsets(
            top: min(max(insets.top, 0), ArtworkInsets.perSideLimit),
            bottom: min(max(insets.bottom, 0), ArtworkInsets.perSideLimit),
            left: min(max(insets.left, 0), ArtworkInsets.perSideLimit),
            right: min(max(insets.right, 0), ArtworkInsets.perSideLimit)
        )
        let vertical = result.top + result.bottom
        if vertical > ArtworkInsets.combinedLimit {
            let scale = ArtworkInsets.combinedLimit / vertical
            result.top *= scale
            result.bottom *= scale
        }
        let horizontal = result.left + result.right
        if horizontal > ArtworkInsets.combinedLimit {
            let scale = ArtworkInsets.combinedLimit / horizontal
            result.left *= scale
            result.right *= scale
        }
        return result
    }

    /// 画素座標での切り出し矩形。左上原点、整数に切り下げ、境界内に収める。
    static func pixelRect(imageSize: CGSize, insets: ArtworkInsets) -> CGRect {
        let normalized = normalized(insets)
        let width = max(1, Double(imageSize.width))
        let height = max(1, Double(imageSize.height))
        let x = (width * normalized.left).rounded(.down)
        let y = (height * normalized.top).rounded(.down)
        var cropWidth = (width * (1 - normalized.left - normalized.right)).rounded(.down)
        var cropHeight = (height * (1 - normalized.top - normalized.bottom)).rounded(.down)
        cropWidth = min(max(cropWidth, 1), width - x)
        cropHeight = min(max(cropHeight, 1), height - y)
        return CGRect(x: x, y: y, width: cropWidth, height: cropHeight)
    }
}
