//
//  BookScannerViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 07/03/26.
//

import Foundation
import Observation

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
                state = .error(error.localizedDescription)
            }
        }
    }

    /// Para que la vista pueda volver a escanear tras notFound/error sin crear otro ViewModel.
    func reset() {
        state = .idle
    }
}
