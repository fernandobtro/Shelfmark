//
//  QuoteTextScannerView.swift
//  Shelfmark
//
//  Created by Cursor on 24/03/26.
//
//  Purpose: OCR capture screen used to extract quote text from camera input.
//

import SwiftUI
import Observation
import VisionKit
import UIKit

/// Presents scanner UI and emits captured text or fallback actions.
struct QuoteTextScannerView: View {
    @Bindable var viewModel: QuoteTextScannerViewModel
    let onTextCaptured: (String) -> Void
    let onFallbackToManual: () -> Void
    let onClose: () -> Void

    @State private var hasCapturedText = false
    @State private var scannedTextDraft = ""
    @State private var isPresentingReviewSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .checkingAvailability:
                    ProgressView("Preparando escáner…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .scanning:
                    scannerContent

                case .unavailable(let message), .error(let message):
                    unavailableView(message: message)
                }
            }
            .background(Color.theme.mainBackground)
            .navigationTitle("Escanear texto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        onClose()
                    }
                }
            }
            .task {
                viewModel.onAppear()
            }
            .sheet(isPresented: $isPresentingReviewSheet) {
                reviewSheet
            }
        }
    }

    private var scannerContent: some View {
        ZStack(alignment: .top) {
            QuoteTextScannerRepresentable(
                onTextTapped: { rawText in
                    guard !hasCapturedText else { return }
                    guard let normalized = viewModel.normalizeCapturedText(rawText) else { return }
                    hasCapturedText = true
                    scannedTextDraft = normalized
                    isPresentingReviewSheet = true
                },
                onScannerUnavailable: { error in
                    viewModel.handleScannerError(error)
                }
            )
            .ignoresSafeArea()

            Text("Apunta y toca el texto para usarlo en tu cita")
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )
                .padding(.top, 12)
                .padding(.horizontal, 16)
        }
    }

    private var reviewSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ajusta el texto antes de usarlo")
                    .font(.headline)

                Text("Puedes recortar o editar el contenido detectado.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $scannedTextDraft)
                    .padding(8)
                    .frame(minHeight: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.theme.secondaryBackground.opacity(0.72))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
            .padding(16)
            .navigationTitle("Texto detectado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reescanear") {
                        scannedTextDraft = ""
                        hasCapturedText = false
                        isPresentingReviewSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Usar texto") {
                        let trimmed = scannedTextDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        isPresentingReviewSheet = false
                        onTextCaptured(trimmed)
                    }
                    .disabled(scannedTextDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func unavailableView(message: String) -> some View {
        VStack(spacing: 12) {
            ContentUnavailableView(
                "No disponible",
                systemImage: "camera.viewfinder",
                description: Text(message)
            )
            Button("Reintentar") {
                hasCapturedText = false
                viewModel.retry()
            }
            .buttonStyle(.bordered)
            Button("Escribir manualmente") {
                onFallbackToManual()
            }
            .buttonStyle(.borderedProminent)
            .tint(.primaryGreen)
            Button("Abrir Ajustes") {
                openAppSettings()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct QuoteTextScannerRepresentable: UIViewControllerRepresentable {
    let onTextTapped: (String) -> Void
    let onScannerUnavailable: (DataScannerViewController.ScanningUnavailable) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onTextTapped: onTextTapped,
            onScannerUnavailable: onScannerUnavailable
        )
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onTextTapped: (String) -> Void
        private let onScannerUnavailable: (DataScannerViewController.ScanningUnavailable) -> Void

        init(
            onTextTapped: @escaping (String) -> Void,
            onScannerUnavailable: @escaping (DataScannerViewController.ScanningUnavailable) -> Void
        ) {
            self.onTextTapped = onTextTapped
            self.onScannerUnavailable = onScannerUnavailable
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .text(let recognizedText) = item {
                onTextTapped(recognizedText.transcript)
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable
        ) {
            onScannerUnavailable(error)
        }
    }
}

