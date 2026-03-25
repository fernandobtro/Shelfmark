//
//  BookScannerViewController.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 10/03/26.
//

import Foundation
import UIKit
import VisionKit

final class BookScannerViewController: UIViewController {
    private var bookScanner: DataScannerViewController?
    /// Closure que se llama cuando se detecta un código de barras. Quien presenta el VC asigna aquí qué hacer (p. ej. llamar al ViewModel).
    var onCodeScanned: ((String) -> Void)?
    /// Para no disparar el callback varias veces si el mismo código se reconoce en varios frames.
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
