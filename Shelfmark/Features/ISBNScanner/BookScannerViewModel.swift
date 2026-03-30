//
//  BookScannerViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 07/03/26.
//
//  Purpose: ISBN scanner state manager that performs lookup and exposes scan result states.
//

import Foundation
import Observation

/// Executes ISBN lookups and publishes scanner lifecycle transitions.
enum ScannerState: Equatable {
    case idle
    case scanning
    case loading
    case found(Book)
    case notFound(isbn: String)
    case error(String)
}

@Observable
final class BookScannerViewModel {
    var state: ScannerState = .idle

    private let lookUpByISBNUseCase: LookUpByISBNUseCaseProtocol

    init(lookUpByISBNUseCase: LookUpByISBNUseCaseProtocol) {
        self.lookUpByISBNUseCase = lookUpByISBNUseCase
    }

    func handleScannedCode(_ code: String) async {
        state = .loading
        do {
            let book = try await lookUpByISBNUseCase.execute(isbn: code)
            await MainActor.run {
                if let book = book {
                    state = .found(book)
                } else {
                    state = .notFound(isbn: code)
                }
            }
        } catch {
            await MainActor.run {
                state = .error(UserFacingError.message(error, fallback: "No se pudo completar el escaneo. Intenta de nuevo."))
            }
        }
    }

    /// Allows the view to restart scanning after not-found/error without recreating the view model.
    func reset() {
        state = .idle
    }
}
