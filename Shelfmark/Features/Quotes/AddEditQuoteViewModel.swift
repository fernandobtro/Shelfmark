//
//  AddEditQuoteViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Quote form state manager for add/edit modes, book selection, and persistence.
//

import Foundation
import Observation

/// Loads quote context, validates input, and saves/deletes through quote use cases.
enum AddEditQuoteMode {
    case add
    case addWithInitialText(String)
    /// Creates a new quote with a preselected book (for example, from `BookDetailView`).
    case addForBook(Book)
    case edit(quoteId: UUID)
}

@Observable
final class AddEditQuoteViewModel {
    var text: String = ""
    /// Currently selected book for the quote (required before save).
    var selectedBook: Book?
    var pageReference: String = ""

    /// Full library snapshot available to choose a book in the selector.
    var books: [Book] = []
    var isSaving = false
    var errorMessage: String?
    var isLoading = true

    /// Convenience value for views: selected book identifier.
    var selectedBookId: UUID? {
        selectedBook?.id
    }

    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    /// True when the book was pre-selected by the caller (e.g. BookDetailView) and must not be changed.
    var isBookLocked: Bool {
        if case .addForBook = mode { return true }
        return false
    }

    var navigationTitle: String {
        isEditMode ? "Editar cita" : "Nueva cita"
    }

    private let mode: AddEditQuoteMode
    private let saveQuoteUseCase: SaveQuoteUseCaseProtocol
    private let fetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol
    private let fetchLibraryUseCase: FetchLibraryUseCaseProtocol
    private let deleteQuoteUseCase: DeleteQuoteUseCaseProtocol

    init(
        mode: AddEditQuoteMode,
        saveQuoteUseCase: SaveQuoteUseCaseProtocol,
        fetchQuoteByIdUseCase: FetchQuoteByIdUseCaseProtocol,
        fetchLibraryUseCase: FetchLibraryUseCaseProtocol,
        deleteQuoteUseCase: DeleteQuoteUseCaseProtocol
    ) {
        self.mode = mode
        self.saveQuoteUseCase = saveQuoteUseCase
        self.fetchQuoteByIdUseCase = fetchQuoteByIdUseCase
        self.fetchLibraryUseCase = fetchLibraryUseCase
        self.deleteQuoteUseCase = deleteQuoteUseCase
    }

    func load() async {
        await MainActor.run { isLoading = true }

        do {
            let library = try await fetchLibraryUseCase.execute()

            switch mode {
            case .edit(let quoteId):
                guard let quote = try await fetchQuoteByIdUseCase.execute(quoteId: quoteId) else {
                    await MainActor.run {
                        books = library
                        errorMessage = "No se encontró la cita"
                        isLoading = false
                    }
                    return
                }
                await MainActor.run {
                    books = library
                    text = quote.text
                    selectedBook = library.first(where: { $0.id == quote.bookId })
                    pageReference = quote.pageReference ?? ""
                    isLoading = false
                }

            case .addWithInitialText(let initialText):
                await MainActor.run {
                    books = library
                    text = initialText
                    // Do not auto-select a book; user must explicitly pick one.
                    isLoading = false
                }

            case .addForBook(let book):
                await MainActor.run {
                    books = library
                    // Prefer the in-library instance when available to keep data identity consistent.
                    selectedBook = library.first(where: { $0.id == book.id }) ?? book
                    isLoading = false
                }

            case .add:
                await MainActor.run {
                    books = library
                    // Without initial selection, user must choose a book in the selector.
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = UserFacingError.message(error, fallback: "No se pudo cargar la información de la cita. Intenta de nuevo.")
                isLoading = false
            }
        }
    }

    func save() async {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            errorMessage = "Escribe el texto de la cita."
            return
        }
        guard let bookId = selectedBookId else {
            errorMessage = "Elige un libro."
            return
        }

        await MainActor.run { isSaving = true; errorMessage = nil }

        do {
            let quote: Quote
            switch mode {
            case .add, .addWithInitialText, .addForBook:
                quote = Quote(
                    id: UUID(),
                    text: trimmedText,
                    bookId: bookId,
                    pageReference: pageReference.isEmpty ? nil : pageReference,
                    createdAt: Date()
                )
            case .edit(let quoteId):
                guard let existing = try await fetchQuoteByIdUseCase.execute(quoteId: quoteId) else {
                    await MainActor.run { errorMessage = "No se encontró la cita"; isSaving = false }
                    return
                }
                quote = Quote(
                    id: existing.id,
                    text: trimmedText,
                    bookId: bookId,
                    pageReference: pageReference.isEmpty ? nil : pageReference,
                    createdAt: existing.createdAt
                )
            }
            try await saveQuoteUseCase.execute(quote: quote)
            await MainActor.run { errorMessage = nil; isSaving = false }
        } catch {
            await MainActor.run {
                errorMessage = UserFacingError.message(error, fallback: "No se pudo guardar la cita. Intenta de nuevo.")
                isSaving = false
            }
        }
    }

    func deleteQuote() async {
        guard case .edit(let quoteId) = mode else { return }
        do {
            try await deleteQuoteUseCase.execute(quoteId: quoteId)
            await MainActor.run { errorMessage = nil }
        } catch {
            await MainActor.run {
                errorMessage = UserFacingError.message(error, fallback: "No se pudo eliminar la cita. Intenta de nuevo.")
            }
        }
    }
}
