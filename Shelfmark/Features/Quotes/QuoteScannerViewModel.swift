//
//  QuoteScannerViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import Foundation
import Observation
import UIKit

@Observable
final class QuoteScannerViewModel {
    enum State: Equatable {
        case idle
        case processing
        case recognized(String)
        case error(String)
    }

    var state: State = .idle

    private let recognizeTextUseCase: RecognizeTextInImageUseCaseProtocol

    init(recognizeTextUseCase: RecognizeTextInImageUseCaseProtocol) {
        self.recognizeTextUseCase = recognizeTextUseCase
    }

    func processImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            state = .error("No se pudo usar la imagen.")
            return
        }
        state = .processing
        do {
            let text = try await recognizeTextUseCase.execute(image: cgImage)
            await MainActor.run {
                state = .recognized(text.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }

    func reset() {
        state = .idle
    }
}
