import CoreGraphics
import ImageIO
import UIKit

/// 写真の読み込みと縮小。表示は長辺 1200px、書き出しは元の解像度を上限つきで読む。
enum PhotoLoader {
    /// 表示用の縮小。メモリを抑えるため、デコード時に縮小して作る。
    static func downsample(data: Data, maxPixel: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixel)
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
    }

    /// 裁ち落としを適用した画像。向きは読み込み時に正規化済み。
    static func cropped(_ image: UIImage, insets: ArtworkInsets) -> UIImage {
        let normalized = CropGeometry.normalized(insets)
        guard !normalized.isZero, let cgImage = image.cgImage else { return image }
        let imageSize = CGSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
        let rect = CropGeometry.pixelRect(imageSize: imageSize, insets: normalized)
        guard let cropped = cgImage.cropping(to: rect) else { return image }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: .up)
    }

    /// 1×1 に縮めて平均色を取る。額なしの側面塗りに使う。
    static func averageColor(of image: UIImage) -> UIColor? {
        guard let cgImage = image.cgImage else { return nil }
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        bytes.initialize(repeating: 0, count: 4)
        defer { bytes.deallocate() }
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: bytes,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: bitmapInfo) else { return nil }
        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return UIColor(red: CGFloat(bytes[0]) / 255.0,
                       green: CGFloat(bytes[1]) / 255.0,
                       blue: CGFloat(bytes[2]) / 255.0,
                       alpha: 1)
    }
}
