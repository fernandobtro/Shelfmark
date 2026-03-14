//
//  BookDetailViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import Observation

// MARK: - Estado de la pantalla (igual que en Library: un solo estado posible a la vez)

enum BookDetailState: Equatable {
    case idle
    case loading
    case loaded(Book)
    case error(String)
}

@Observable
final class BookDetailViewModel {
    var state: BookDetailState = .idle

    private let bookId: UUID
    private let fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol
    private let deleteBookUseCase: DeleteBookUseCaseProtocol

    init(bookId: UUID, fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol, deleteBookUseCase: DeleteBookUseCaseProtocol) {
        self.bookId = bookId
        self.fetchBookDetailUseCase = fetchBookDetailUseCase
        self.deleteBookUseCase = deleteBookUseCase
    }

    var loadedBook: Book? {
        guard case .loaded(let book) = state else { return nil }
        return book
    }

    func loadDetail() async {
        state = .loading
        do {
            let book = try await fetchBookDetailUseCase.execute(bookId: bookId)
            await MainActor.run {
                if let book = book {
                    state = .loaded(book)
                } else {
                    state = .error("No se encontró el libro.")
                }
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }

    func delete() async {
        do {
            try await deleteBookUseCase.execute(bookId: bookId)
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }
}

