//
//  CameraQuoteView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import SwiftUI
import UIKit

struct CameraQuoteView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage, dismiss: dismiss)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let selectedImage: Binding<UIImage?>
        let dismiss: DismissAction

        init(selectedImage: Binding<UIImage?>, dismiss: DismissAction) {
            self.selectedImage = selectedImage
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage.wrappedValue = image
            }
            dismiss()
        }
    }
}
