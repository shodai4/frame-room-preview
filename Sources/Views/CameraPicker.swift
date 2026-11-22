import SwiftUI
import UIKit

/// 作品をその場で撮る。カメラのない端末では導線を出さない。
struct CameraPicker: UIViewControllerRepresentable {
    let onPick: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onClose: { dismiss() })
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onPick: (UIImage) -> Void
        private let onClose: () -> Void

        init(onPick: @escaping (UIImage) -> Void, onClose: @escaping () -> Void) {
            self.onPick = onPick
            self.onClose = onClose
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onPick(image)
            }
            onClose()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onClose()
        }
    }
}
