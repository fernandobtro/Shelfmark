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
    /// Citas asociadas a este libro (se cargan junto con el detalle).
    var quotesForBook: [Quote] = []
    /// Error al guardar cambios rápidos (favorito, estado, página).
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

    /// Reinicia el progreso de lectura al inicio.
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

    /// Devuelve el libro al estado "pendiente" y limpia su progreso actual.
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
                quickSaveError = error.localizedDescription
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

