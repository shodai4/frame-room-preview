import PhotosUI
import SwiftUI
import UIKit

/// 画面の状態と写真の読み込み・書き出しをまとめる。
@MainActor
final class StudioModel: ObservableObject {
    // 写真の受け口
    @Published var artworkItem: PhotosPickerItem?
    @Published var wallItem: PhotosPickerItem?
    @Published var isCameraPresented = false

    // 読み込んだ画像
    @Published private(set) var artworkThumbnail: UIImage?
    @Published private(set) var croppedArtwork: UIImage?
    @Published private(set) var artworkData: Data?
    @Published private(set) var artworkAverage: UIColor?
    @Published private(set) var wallPhoto: UIImage?

    // 飾り付け
    @Published var canvas: CanvasSize = .f10
    @Published var frame: FrameStyle = .woodNatural
    @Published var mat: MatWidth = .standard
    @Published var wall: WallStyle = .gallery
    @Published var tilt: Double = 0
    @Published var insets: ArtworkInsets = .zero
    @Published var zoom: Double = 1
    @Published var exportShape: ExportShape = .square

    // 書き出し
    @Published private(set) var isExporting = false
    @Published private(set) var message: String?

    var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    /// 額なしの側面に使う色。
    var sideColor: Color {
        artworkAverage.map { Color(uiColor: $0) } ?? Theme.charcoal
    }

    var hasArtwork: Bool { croppedArtwork != nil }

    // MARK: - 読み込み

    func loadArtworkItem() {
        guard let item = artworkItem else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                message = "写真を読み込めませんでした。"
                return
            }
            adoptArtwork(data: data)
        }
    }

    func loadWallItem() {
        guard let item = wallItem else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                message = "部屋の写真を読み込めませんでした。"
                return
            }
            if let photo = PhotoLoader.downsample(data: data, maxPixel: 1600) {
                wallPhoto = photo
                wall = .roomPhoto
                message = nil
            }
        }
    }

    func adoptCameraImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.95) else { return }
        adoptArtwork(data: data)
    }

    private func adoptArtwork(data: Data) {
        let hadArtwork = artworkData != nil
        guard let thumbnail = PhotoLoader.downsample(data: data, maxPixel: 1200) else {
            message = "写真を読み込めませんでした。"
            return
        }
        artworkData = data
        artworkThumbnail = thumbnail
        artworkAverage = PhotoLoader.averageColor(of: thumbnail)
        if !hadArtwork {
            let ratio = Double(thumbnail.size.width / max(thumbnail.size.height, 1))
            canvas = CanvasSize.nearest(toRatio: ratio)
            insets = .zero
            zoom = 1
        }
        refreshCrop()
        message = nil
    }

    /// 裁ち落としを掛け直す。インセットが変わったときに呼ぶ。
    func refreshCrop() {
        guard let thumbnail = artworkThumbnail else {
            croppedArtwork = nil
            return
        }
        croppedArtwork = PhotoLoader.cropped(thumbnail, insets: insets)
    }

    // MARK: - 書き出し

    func export() async {
        guard let data = artworkData, !isExporting else { return }
        isExporting = true
        message = nil
        let image = ExportRenderer.makeImage(data: data,
                                             insets: CropGeometry.normalized(insets),
                                             wall: wall,
                                             wallPhoto: wallPhoto,
                                             canvas: canvas,
                                             frame: frame,
                                             mat: mat,
                                             tilt: PreviewGeometry.clampedTilt(tilt),
                                             shape: exportShape)
        guard let image else {
            isExporting = false
            message = "書き出しに失敗しました。"
            return
        }
        let outcome = await PhotoSaver.save(image)
        isExporting = false
        switch outcome {
        case .saved:
            message = "写真に保存しました。"
        case .denied:
            message = "写真への保存が許可されていません。設定から許可してください。"
        case .failed:
            message = "保存できませんでした。時間をおいてお試しください。"
        }
    }

    func clearMessage() {
        message = nil
    }
}
