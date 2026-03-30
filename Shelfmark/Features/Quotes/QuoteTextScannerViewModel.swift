//
//  QuoteTextScannerViewModel.swift
//  Shelfmark
//
//  Created by Cursor on 24/03/26.
//
//  Purpose: OCR scanner state manager that coordinates recognition lifecycle and output text.
//

import Foundation
import Observation
import VisionKit
import AVFoundation

/// Manages scanner state transitions and recognized text payloads.
enum QuoteTextScannerState: Equatable {
    case checkingAvailability
    case scanning
    case unavailable(String)
    case error(String)
}

@Observable
final class QuoteTextScannerViewModel {
    var state: QuoteTextScannerState = .checkingAvailability

    func onAppear() {
        evaluateScannerAvailability()
    }

    func retry() {
        state = .checkingAvailability
        evaluateScannerAvailability()
    }

    func handleScannerError(_ error: DataScannerViewController.ScanningUnavailable) {
        state = .error("No se pudo iniciar el escáner de texto. Intenta de nuevo.")
    }

    func normalizeCapturedText(_ rawText: String) -> String? {
        let normalized = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            state = .error("No se detectó texto válido. Intenta nuevamente.")
            return nil
        }
        return normalized
    }

    private func evaluateScannerAvailability() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.evaluateScannerAvailability()
                    } else {
                        self.state = .unavailable("No diste permiso de cámara. Puedes activarlo en Ajustes o escribir la cita manualmente.")
                    }
                }
            }
            return
        case .denied, .restricted:
            state = .unavailable("No tenemos acceso a la cámara. Actívalo en Ajustes para escanear texto.")
            return
        @unknown default:
            state = .unavailable("No se pudo acceder a la cámara en este dispositivo.")
            return
        }

        guard DataScannerViewController.isSupported else {
            state = .unavailable("Tu dispositivo no soporta escaneo de texto en tiempo real.")
            return
        }

        guard DataScannerViewController.isAvailable else {
            state = .unavailable("La cámara no está disponible en este momento. Revisa permisos o intenta más tarde.")
            return
        }

        state = .scanning
    }
}

