//
//  BookScannerViewController.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 10/03/26.
//
//  Purpose: UIKit camera controller for barcode capture used by the SwiftUI scanner flow.
//

import Foundation
import UIKit
import VisionKit

/// Bridges AVFoundation barcode detection callbacks into SwiftUI scanner features.
final class BookScannerViewController: UIViewController {
    private var bookScanner: DataScannerViewController?
    /// Callback fired when a barcode is detected; presenter defines follow-up behavior (for example, calling the view model).
    var onCodeScanned: ((String) -> Void)?
    /// Prevents firing the callback repeatedly when the same code is recognized across multiple frames.
    private var hasReportedCode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard DataScannerViewController.isSupported else {
            assertionFailure("El dispositivo no soporta VisionKit.")
            return
        }
        
        guard DataScannerViewController.isAvailable else {
            assertionFailure("La cámara no está disponible.")
            return
        }
        
        bookScanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        
        bookScanner?.delegate = self
        
        guard let bookScanner = bookScanner else { return }
        
        addChild(bookScanner)
        view.addSubview(bookScanner.view)
        bookScanner.view.frame = view.bounds
        bookScanner.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        try? bookScanner?.startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bookScanner?.stopScanning()
    }
}

extension BookScannerViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController,
                     didAdd addedItems: [RecognizedItem],
                     allItems: [RecognizedItem]) {
        guard !hasReportedCode else { return }

        for item in addedItems {
            if case .barcode(let barcode) = item {
                guard let code = barcode.payloadStringValue, !code.isEmpty else { continue }

                hasReportedCode = true
                dataScanner.stopScanning()

                DispatchQueue.main.async { [weak self] in
                    self?.onCodeScanned?(code)
                }
                return
            }
        }
    }
}
