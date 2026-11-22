import CoreGraphics
import Foundation

/// プレビューと書き出しの寸法計算。
///
/// 号数（mm）→ 画面上の pt は、プレビュー領域の高さが壁の 900mm に当たると決めて換算する。
/// つまり F0 は小さく、F20 は大きい。大きすぎる作品は 86% に収め、ピンチの拡大には
/// 96% の上限を置く。書き出しも同じ関数を通すので、プレビューと仕上がりが一致する。
enum PreviewGeometry {
    /// プレビューが映す壁の高さ（mm）。
    static let visibleWallHeightMM: Double = 900
    /// 画面に収めるときの上限（プレビュー領域に対する割合）。
    static let fitLimit: Double = 0.86
    /// ピンチで拡大したときの上限。
    static let hardLimit: Double = 0.96
    /// ピンチの範囲。
    static let zoomRange: ClosedRange<Double> = 0.6...1.6
    /// 傾きの範囲（度）。
    static let tiltRange: ClosedRange<Double> = -5...5
    /// 書き出しの長辺（px）。
    static let exportMaxEdge: Double = 2048

    /// 一辺に足す余白（マット＋額縁）を含めた仕上がり外寸（mm）。
    static func outerSizeMM(canvas: CanvasSize, mat: MatWidth, frame: FrameStyle) -> CGSize {
        let margin = 2 * (mat.widthMM + frame.sideWidthMM)
        return CGSize(width: canvas.widthMm + margin, height: canvas.heightMm + margin)
    }

    /// 画面上の割り付け。すべて pt。
    static func layout(canvas: CanvasSize,
                       mat: MatWidth,
                       frame: FrameStyle,
                       zoom: Double,
                       previewSize: CGSize) -> FrameLayout {
        let matMM = mat.widthMM
        let frameMM = frame.sideWidthMM
        let outerWidthMM = canvas.widthMm + 2 * (matMM + frameMM)
        let outerHeightMM = canvas.heightMm + 2 * (matMM + frameMM)

        let previewWidth = Double(previewSize.width)
        let previewHeight = Double(previewSize.height)
        guard previewWidth > 1, previewHeight > 1, outerWidthMM > 0, outerHeightMM > 0 else {
            return .zero
        }

        let clampedZoom = min(max(zoom, zoomRange.lowerBound), zoomRange.upperBound)
        let pointPerMMBase = previewHeight / visibleWallHeightMM

        var width = outerWidthMM * pointPerMMBase
        var height = outerHeightMM * pointPerMMBase

        let fit = min(1, min(previewWidth * fitLimit / width, previewHeight * fitLimit / height))
        width *= fit * clampedZoom
        height *= fit * clampedZoom

        let hard = min(1, min(previewWidth * hardLimit / width, previewHeight * hardLimit / height))
        width *= hard
        height *= hard

        let pointPerMM = width / outerWidthMM
        return FrameLayout(
            outerSize: CGSize(width: width, height: height),
            artworkSize: CGSize(width: canvas.widthMm * pointPerMM, height: canvas.heightMm * pointPerMM),
            frameWidth: CGFloat(frameMM * pointPerMM),
            matWidth: CGFloat(matMM * pointPerMM),
            pointPerMM: CGFloat(pointPerMM)
        )
    }

    /// 書き出しの画素数（px）。長辺 2048、1:1 か 4:5。
    static func exportPixelSize(shape: ExportShape, maxEdge: Double = exportMaxEdge) -> CGSize {
        let height = maxEdge
        let width = (maxEdge * shape.ratio).rounded()
        return CGSize(width: width, height: height)
    }

    /// 度を −5〜5 に収める。
    static func clampedTilt(_ degrees: Double) -> Double {
        min(max(degrees, tiltRange.lowerBound), tiltRange.upperBound)
    }

    /// 拡大率を 0.6〜1.6 に収める。
    static func clampedZoom(_ zoom: Double) -> Double {
        min(max(zoom, zoomRange.lowerBound), zoomRange.upperBound)
    }
}

/// 割り付けの結果。外寸・作品の寸法・額縁とマットの幅を pt で持つ。
struct FrameLayout: Equatable {
    var outerSize: CGSize
    var artworkSize: CGSize
    var frameWidth: CGFloat
    var matWidth: CGFloat
    var pointPerMM: CGFloat

    static let zero = FrameLayout(outerSize: .zero,
                                  artworkSize: .zero,
                                  frameWidth: 0,
                                  matWidth: 0,
                                  pointPerMM: 0)
}
