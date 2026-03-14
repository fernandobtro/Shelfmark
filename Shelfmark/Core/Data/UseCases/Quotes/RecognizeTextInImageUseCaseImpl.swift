//
//  RecognizeTextInImageUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import Foundation
import CoreGraphics
@preconcurrency import Vision

final class RecognizeTextInImageUseCaseImpl: RecognizeTextInImageUseCaseProtocol {

    func execute(image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                continuation.resume(returning: recognizedText)
            }
            request.recognitionLevel = .accurate
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
