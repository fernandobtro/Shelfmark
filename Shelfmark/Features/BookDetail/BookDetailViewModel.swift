//
//  BookDetailViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Book detail state and actions, including quote loading, status updates, progress edits, and deletion.
//

import Foundation
import Observation

// MARK: - Screen State (single active state at a time)

/// Loads a single book aggregate and executes mutation flows with user-facing error handling.
enum BookDetailState: Equatable {
    case idle
    case loading
    case loaded(Book)
    case error(String)
}

@Observable
final class BookDetailViewModel {
    var state: BookDetailState = .idle
    /// Quotes associated with this book, loaded together with detail data.
    var quotesForBook: [Quote] = []
    /// Error surfaced when quick updates fail (favorite, reading status, current page).
    var quickSaveError: String?

    private let bookId: UUID
    private let fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol
    private let deleteBookUseCase: DeleteBookUseCaseProtocol
    private let fetchQuotesUseCase: FetchQuotesUseCaseProtocol
    private let saveBookUseCase: SaveBookUseCaseProtocol

    init(
        bookId: UUID,
        fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol,
        deleteBookUseCase: DeleteBookUseCaseProtocol,
        fetchQuotesUseCase: FetchQuotesUseCaseProtocol,
        saveBookUseCase: SaveBookUseCaseProtocol
    ) {
        self.bookId = bookId
        self.fetchBookDetailUseCase = fetchBookDetailUseCase
        self.deleteBookUseCase = deleteBookUseCase
        self.fetchQuotesUseCase = fetchQuotesUseCase
        self.saveBookUseCase = saveBookUseCase
    }

    var loadedBook: Book? {
        guard case .loaded(let book) = state else { return nil }
        return book
    }

    func loadDetail() async {
        state = .loading
        do {
            async let bookTask = fetchBookDetailUseCase.execute(bookId: bookId)
            async let quotesTask = fetchQuotesUseCase.execute()
            let (book, allQuotes) = try await (bookTask, quotesTask)

            let quotesForThisBook = allQuotes
                .filter { $0.bookId == bookId }
                .sorted { $0.createdAt > $1.createdAt }

            await MainActor.run {
                quotesForBook = quotesForThisBook
                quickSaveError = nil
                if let book = book {
                    state = .loaded(book)
                } else {
                    state = .error("No se encontró el libro.")
                }
            }
        } catch {
            await MainActor.run {
                state = .error(UserFacingError.message(error, fallback: "No se pudo cargar la ficha del libro. Intenta de nuevo."))
            }
        }
    }

    func delete() async -> Bool {
        do {
            try await deleteBookUseCase.execute(bookId: bookId)
            return true
        } catch {
            await MainActor.run {
                state = .error(UserFacingError.message(error, fallback: "No se pudo eliminar el libro. Intenta de nuevo."))
            }
            return false
        }
    }

    // MARK: - Guardado rápido

    func toggleFavorite() async {
        guard case .loaded(let book) = state else { return }
        let updated = bookWithBase(book, isFavorite: !book.isFavorite)
        await persistQuick(updated)
    }

    func setReadingStatus(_ status: ReadingStatus) async {
        guard case .loaded(let book) = state else { return }
        let updated = bookWithBase(book, readingStatus: status)
        await persistQuick(updated)
    }

    func markAsCompleted() async {
        guard case .loaded(let book) = state else { return }
        guard let total = book.numberOfPages, total > 0 else {
            await MainActor.run {
                quickSaveError = "Añade el total de páginas del libro (Editar) antes de marcarlo como leído."
            }
            return
        }
        let updated = Book(
            id: book.id,
            isbn: book.isbn,
            authors: book.authors,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: book.isFavorite,
            readingStatus: .read,
            currentPage: total
        )
        await persistQuick(updated)
    }

    func startReading() async {
        guard case .loaded(let book) = state else { return }
        let updated = Book(
            id: book.id,
            isbn: book.isbn,
            authors: book.authors,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: book.isFavorite,
            readingStatus: .reading,
            currentPage: 1
        )
        await persistQuick(updated)
    }

    /// Resets reading progress back to the beginning.
    func resetProgress() async {
        guard case .loaded(let book) = state else { return }
        let updated = Book(
            id: book.id,
            isbn: book.isbn,
            authors: book.authors,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: book.isFavorite,
            readingStatus: .reading,
            currentPage: 1
        )
        await persistQuick(updated)
    }

    /// Sets the book back to pending state and clears current progress.
    func markAsPending() async {
        guard case .loaded(let book) = state else { return }
        let updated = Book(
            id: book.id,
            isbn: book.isbn,
            authors: book.authors,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: book.isFavorite,
            readingStatus: .pending,
            currentPage: nil
        )
        await persistQuick(updated)
    }

    func saveCurrentPage(from text: String) async {
        guard case .loaded(let book) = state else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let msg = Book.validationErrorMessage(currentPageText: trimmed, numberOfPages: book.numberOfPages) {
            await MainActor.run { quickSaveError = msg }
            return
        }
        let page: Int? = trimmed.isEmpty ? nil : Int(trimmed)
        let updated = Book(
            id: book.id,
            isbn: book.isbn,
            authors: book.authors,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: book.isFavorite,
            readingStatus: book.readingStatus,
            currentPage: page
        )
        await persistQuick(updated)
    }

    private func persistQuick(_ book: Book) async {
        await MainActor.run { quickSaveError = nil }
        do {
            try await saveBookUseCase.execute(book)
            await loadDetail()
        } catch {
            await MainActor.run {
                quickSaveError = UserFacingError.message(error, fallback: "No se pudieron guardar los cambios. Intenta de nuevo.")
            }
        }
    }

    private func bookWithBase(
        _ book: Book,
        isFavorite: Bool? = nil,
        readingStatus: ReadingStatus? = nil
    ) -> Book {
        Book(
            id: book.id,
            isbn: book.isbn,
            authors: book.authors,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: isFavorite ?? book.isFavorite,
            readingStatus: readingStatus ?? book.readingStatus,
            currentPage: book.currentPage
        )
    }
}

