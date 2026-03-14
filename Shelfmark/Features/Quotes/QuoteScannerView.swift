//
//  QuoteScannerView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import SwiftUI
import UIKit
import AVFoundation

struct QuoteScannerView: View {
    @Bindable var viewModel: QuoteScannerViewModel
    let container: AppDIContainer
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage?
    @State private var showCamera = true
    @State private var showAddEditQuote = false
    @State private var textToEdit: String = ""
    @State private var cameraAuthorized: Bool? = nil

    var body: some View {
        ZStack {
            if showCamera, cameraAuthorized == true {
                cameraLayer
            }

            overlayLayer

            if cameraAuthorized == false {
                cameraDeniedOverlay
            }

            if cameraAuthorized == nil, showCamera {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView("Comprobando cámara…")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
        .task {
            await checkCameraPermission()
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .padding()
        }
        .sheet(isPresented: $showAddEditQuote, onDismiss: {
            dismiss()
        }) {
            AddEditQuoteView(
                viewModel: container.makeAddEditQuoteViewModel(mode: AddEditQuoteMode.addWithInitialText(textToEdit)),
                onDelete: nil
            )
        }
    }

    private var cameraLayer: some View {
        CameraQuoteView(selectedImage: $selectedImage)
            .ignoresSafeArea()
            .onChange(of: selectedImage) { _, newImage in
                guard let image = newImage else { return }
                showCamera = false
                Task { await viewModel.processImage(image) }
            }
    }

    @ViewBuilder
    private var overlayLayer: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .processing:
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            ProgressView("Reconociendo texto…")
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)

        case .recognized(let text):
            if text.isEmpty {
                noTextDetectedOverlay
            } else {
                recognizedOverlay(text: text)
            }

        case .error(let message):
            errorOverlay(message: message)
        }
    }

    private func recognizedOverlay(text: String) -> some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Texto reconocido")
                        .font(.headline)
                    Spacer()
                }
                Text(text)
                    .font(.body)
                    .lineLimit(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                HStack(spacing: 12) {
                    Button("Guardar") {
                        textToEdit = text
                        showAddEditQuote = true
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Editar") {
                        textToEdit = text
                        showAddEditQuote = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(20)
            .background(.regularMaterial)
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
    }

    private func errorOverlay(message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                HStack(spacing: 12) {
                    Button("Intentar de nuevo") {
                        viewModel.reset()
                        selectedImage = nil
                        showCamera = true
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Añadir a mano") {
                        textToEdit = ""
                        showAddEditQuote = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
            .background(.regularMaterial)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
    }

    private var noTextDetectedOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "text.viewfinder")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                Text("No se detectó texto")
                    .font(.headline)
                Text("Apunta mejor al texto o añade la cita manualmente.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Button("Añadir a mano") {
                        textToEdit = ""
                        showAddEditQuote = true
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Intentar de nuevo") {
                        viewModel.reset()
                        selectedImage = nil
                        showCamera = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
            .background(.regularMaterial)
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
    }

    private var cameraDeniedOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Cámara no permitida")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Activa el acceso en Ajustes para escanear texto.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            }
            .padding(32)
        }
    }

    private func checkCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run { cameraAuthorized = granted }
        case .denied, .restricted:
            await MainActor.run { cameraAuthorized = false }
        case .authorized:
            await MainActor.run { cameraAuthorized = true }
        @unknown default:
            await MainActor.run { cameraAuthorized = true }
        }
    }
}
