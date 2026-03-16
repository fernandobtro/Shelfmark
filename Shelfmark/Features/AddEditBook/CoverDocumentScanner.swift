//
//  CoverDocumentScanner.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import Foundation
import VisionKit
import SwiftUI

struct CoverDocumentScanner: UIViewControllerRepresentable {
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: CoverDocumentScanner
        
        init(_ parent: CoverDocumentScanner) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            parent.onImagePicked(image)
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Failed to scan document: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
    }
}



