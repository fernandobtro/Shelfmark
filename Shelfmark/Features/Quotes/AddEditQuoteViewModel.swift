//
//  AddEditQuoteViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation
import Observation

enum AddEditQuoteMode {
    case add
    case addWithInitialText(String)
    /// Crear una nueva cita preseleccionando un libro concreto (por ejemplo, desde BookDetailView).
    case addForBook(Book)
    case edit(quoteId: UUID)
}

@Observable
final class AddEditQuoteViewModel {
    var text: String = ""
    /// Libro actualmente seleccionado para la cita (obligatorio para guardar).
    var selectedBook: Book?
    var pageReference: String = ""

    /// Biblioteca completa disponible para elegir libro en el selector.
    var books: [Book] = []
    var isSaving = false
    var errorMessage: String?
    var isLoading = true

    /// Conveniencia para las vistas: id del libro seleccionado.
    var selectedBookId: UUID? {
        selectedBook?.id
    }

    var isEditMode: Bool {
        if case .edit = mode { return true }
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
                    // No seleccionamos libro automáticamente: el usuario debe elegirlo.
                    isLoading = false
                }

            case .addForBook(let book):
                await MainActor.run {
                    books = library
                    // Intentamos usar la instancia de la biblioteca si existe, para mantener coherencia.
                    selectedBook = library.first(where: { $0.id == book.id }) ?? book
                    isLoading = false
                }

            case .add:
                await MainActor.run {
                    books = library
                    // Sin selección inicial: el usuario debe elegir libro en el selector.
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription; isLoading = false }
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
            await MainActor.run { errorMessage = error.localizedDescription; isSaving = false }
        }
    }

    func deleteQuote() async {
        guard case .edit(let quoteId) = mode else { return }
        do {
            try await deleteQuoteUseCase.execute(quoteId: quoteId)
            await MainActor.run { errorMessage = nil }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
