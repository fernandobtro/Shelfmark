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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard DataScannerViewController.isSupported else {
            print("El dispositivo no soporta VisionKit")
            return
        }
        
        guard DataScannerViewController.isAvailable else {
            print("La cámara no está disponible")
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

        for item in addedItems {

            if case .barcode(let barcode) = item {

                let code = barcode.payloadStringValue ?? "No legible"
                print("Código detectado: \(code)")
                
            }
        }
    }
}
