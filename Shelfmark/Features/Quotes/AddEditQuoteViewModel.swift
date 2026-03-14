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
    case edit(quoteId: UUID)
}

@Observable
final class AddEditQuoteViewModel {
    var text: String = ""
    var selectedBookId: UUID?
    var pageReference: String = ""

    var books: [Book] = []
    var isSaving = false
    var errorMessage: String?
    var isLoading = true

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
            await MainActor.run { books = library }

            if case .edit(let quoteId) = mode {
                guard let quote = try await fetchQuoteByIdUseCase.execute(quoteId: quoteId) else {
                    await MainActor.run { errorMessage = "No se encontró la cita"; isLoading = false }
                    return
                }
                await MainActor.run {
                    text = quote.text
                    selectedBookId = quote.bookId
                    pageReference = quote.pageReference ?? ""
                    isLoading = false
                }
            } else if case .addWithInitialText(let initialText) = mode {
                await MainActor.run { text = initialText }
                if let first = library.first {
                    await MainActor.run { selectedBookId = first.id }
                }
                await MainActor.run { isLoading = false }
            } else {
                if let first = library.first {
                    await MainActor.run { selectedBookId = first.id }
                }
                await MainActor.run { isLoading = false }
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
        defer { Task { @MainActor in isSaving = false } }

        do {
            let quote: Quote
            switch mode {
            case .add, .addWithInitialText:
                quote = Quote(
                    id: UUID(),
                    text: trimmedText,
                    bookId: bookId,
                    pageReference: pageReference.isEmpty ? nil : pageReference,
                    createdAt: Date()
                )
            case .edit(let quoteId):
                guard let existing = try await fetchQuoteByIdUseCase.execute(quoteId: quoteId) else {
                    await MainActor.run { errorMessage = "No se encontró la cita" }
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
            await MainActor.run { errorMessage = nil }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
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
