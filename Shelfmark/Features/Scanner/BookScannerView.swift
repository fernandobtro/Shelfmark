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
    @State private var lastScannedCode: String?

    var body: some View {
        ZStack {
            BookScannerRepresentable { code in
                lastScannedCode = code
            }
            .ignoresSafeArea()
            .task(id: lastScannedCode) {
                if let code = lastScannedCode {
                    await viewModel.handleScannedCode(code)
                    await MainActor.run { lastScannedCode = nil }
                }
            }

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

// MARK: - Preview

#Preview("Escáner (mock idle)") {
    let vm = BookScannerViewModel(lookUpByISBNUseCase: PreviewLookUpByISBNUseCase())
    return BookScannerView(viewModel: vm)
}

private struct PreviewLookUpByISBNUseCase: LookUpByISBNUseCaseProtocol {
    func execute(isbn: String) async throws -> Book? { nil }
}
