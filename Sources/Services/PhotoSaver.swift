import Photos
import UIKit

/// 書き出した画像を写真に保存する。追加のみの権限を求める。
enum PhotoSaver {
    enum Outcome {
        case saved
        case denied
        case failed
    }

    static func save(_ image: UIImage) async -> Outcome {
        var status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .notDetermined {
            status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        }
        guard status == .authorized || status == .limited else { return .denied }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            return .saved
        } catch {
            return .failed
        }
    }
}
