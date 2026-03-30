//
//  BookScannerView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 07/03/26.
//
//  Purpose: ISBN scanner screen that captures barcodes and reports lookup states.
//

import Foundation
import SwiftUI
import Observation

/// Presents camera scanner UI and binds to `BookScannerViewModel` state.
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

            if case .error(let message) = viewModel.state {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack(spacing: 12) {
                        ContentUnavailableView(
                            "Error al escanear",
                            systemImage: "exclamationmark.triangle",
                            description: Text(message)
                        )
                        Button("Reintentar escaneo") {
                            viewModel.reset()
                            lastScannedCode = nil
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .padding(24)
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
