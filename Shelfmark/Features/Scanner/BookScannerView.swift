//
//  BookScannerView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 07/03/26.
//

import Foundation
import SwiftUI
import Observation

struct BookScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> BookScannerViewController {
            let vc = BookScannerViewController()
            vc.onCodeScanned = onCodeScanned
            return vc
        }

        func updateUIViewController(_ uiViewController: BookScannerViewController, context: Context) {}
}

struct BookScannerView: View {
    @Bindable var viewModel: BookScannerViewModel

    var body: some View {
        ZStack {
            
            BookScannerRepresentable { code in
                Task { await viewModel.handleScannedCode(code) }
            }
            .ignoresSafeArea()

            if case .loading = viewModel.state {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView("Buscando libro...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
}
