import SwiftUI
import UIKit

/// プレビューと同じ計算で、壁ごと高解像度に描き出す。
///
/// 表示用の 1200px 画像ではなく、元データから 4096px を上限に読み直す。
/// 2048px の書き出しで作品が占めるのは実測で 1800px 程度なので、
/// 画質は保ちつつ古い端末でもメモり不足になりにくい大きさに留める。
@MainActor
enum ExportRenderer {
    static func makeImage(data: Data,
                          insets: ArtworkInsets,
                          wall: WallStyle,
                          wallPhoto: UIImage?,
                          canvas: CanvasSize,
                          frame: FrameStyle,
                          mat: MatWidth,
                          tilt: Double,
                          shape: ExportShape) -> UIImage? {
        let pixelSize = PreviewGeometry.exportPixelSize(shape: shape)
        guard let source = PhotoLoader.downsample(data: data, maxPixel: 4096) else { return nil }
        let artwork = PhotoLoader.cropped(source, insets: insets)
        let sideColor = PhotoLoader.averageColor(of: artwork).map { Color(uiColor: $0) } ?? Theme.charcoal
        let content = ExportCanvas(pixelSize: pixelSize,
                                   artwork: artwork,
                                   wall: wall,
                                   wallPhoto: wallPhoto,
                                   canvas: canvas,
                                   frame: frame,
                                   mat: mat,
                                   tilt: tilt,
                                   sideColor: sideColor)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: pixelSize.width, height: pixelSize.height)
        return autoreleasepool { renderer.uiImage }
    }
}

/// 書き出し専用の画面。プレビューと同じ割り付け関数を通す。
struct ExportCanvas: View {
    let pixelSize: CGSize
    let artwork: UIImage
    let wall: WallStyle
    let wallPhoto: UIImage?
    let canvas: CanvasSize
    let frame: FrameStyle
    let mat: MatWidth
    let tilt: Double
    let sideColor: Color

    var body: some View {
        let layout = PreviewGeometry.layout(canvas: canvas,
                                           mat: mat,
                                           frame: frame,
                                           zoom: 1,
                                           previewSize: pixelSize)
        ZStack {
            WallSurface(style: wall, photo: wallPhoto)
            FramedArtwork(image: artwork, layout: layout, style: frame, tilt: tilt, sideColor: sideColor)
        }
        .frame(width: pixelSize.width, height: pixelSize.height)
        .clipped()
    }
}
