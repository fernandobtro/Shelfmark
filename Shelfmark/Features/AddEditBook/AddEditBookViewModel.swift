//
//  AddEditBookViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Book form state manager for add/edit/prefill modes, validation, normalization, and save execution.
//

import Foundation
import Observation

/// Transforms form input into a domain `Book` and persists through `SaveBookUseCaseProtocol`.
enum AddEditBookMode {
    case add
    case addWithInitialData(Book)
    case edit(existing: Book)
}

@Observable
final class AddEditBookViewModel {
   
    var title: String
    var subtitle: String
    var authorsText: String
    var isbn: String
    var publisherName: String
    var pagesText: String
    var publicationDate: Date?
    var language: String
    var descriptionText: String

    // Screen state
    var isFavorite: Bool
    var readingStatus: ReadingStatus
    var currentPageText: String
    var isSaving = false
    var errorMessage: String?
    
    /// Current cover image URL (from API metadata or local capture).
    var coverURL: URL?

    private let saveBookUseCase: SaveBookUseCaseProtocol
    private let mode: AddEditBookMode
    /// Original book payload (scanner prefill or edit mode) to preserve non-form fields such as thumbnail URL.
    private let originalBook: Book?

    init(mode: AddEditBookMode, saveBookUseCase: SaveBookUseCaseProtocol) {
        self.mode = mode
        self.saveBookUseCase = saveBookUseCase

        switch mode {
        case .add:
            originalBook = nil
            title = ""
            subtitle = ""
            authorsText = ""
            isbn = ""
            publisherName = ""
            pagesText = ""
            publicationDate = nil
            language = "es"
            descriptionText = ""
            isFavorite = false
            readingStatus = .none
            currentPageText = ""
            coverURL = nil

        case .addWithInitialData(let book):
            originalBook = book
            title = book.title
            subtitle = book.subtitle ?? ""
            authorsText = book.authors.map(\.name).joined(separator: ", ")
            isbn = book.isbn
            publisherName = book.publisher?.name ?? ""
            pagesText = book.numberOfPages.map(String.init) ?? ""
            publicationDate = book.publicationDate
            language = book.language
            descriptionText = book.bookDescription ?? ""
            isFavorite = false
            readingStatus = .none
            currentPageText = book.currentPage.map(String.init) ?? ""
            coverURL = book.thumbnailURL

        case .edit(let existing):
            originalBook = existing
            title = existing.title
            subtitle = existing.subtitle ?? ""
            authorsText = existing.authors.map(\.name).joined(separator: ", ")
            isbn = existing.isbn
            publisherName = existing.publisher?.name ?? ""
            pagesText = existing.numberOfPages.map(String.init) ?? ""
            publicationDate = existing.publicationDate
            language = existing.language
            descriptionText = existing.bookDescription ?? ""
            isFavorite = existing.isFavorite
            readingStatus = existing.readingStatus
            currentPageText = existing.currentPage.map(String.init) ?? ""
            coverURL = existing.thumbnailURL
        }
    }

    var navigationTitle: String {
        switch mode {
        case .add, .addWithInitialData: return "Añadir libro"
        case .edit: return "Editar libro"
        }
    }

    func save() async {
        await MainActor.run {
            errorMessage = nil
            isSaving = true
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            await MainActor.run {
                errorMessage = "El título es obligatorio."
                isSaving = false
            }
            return
        }

        let pagesParsed = Int(pagesText.trimmingCharacters(in: .whitespacesAndNewlines))
        if let msg = Book.validationErrorMessage(currentPageText: currentPageText, numberOfPages: pagesParsed) {
            await MainActor.run {
                errorMessage = msg
                isSaving = false
            }
            return
        }

        let book = buildBook()

        do {
            try await saveBookUseCase.execute(book)
            await MainActor.run {
                isSaving = false
            }
        } catch {
            await MainActor.run {
                errorMessage = UserFacingError.message(error, fallback: "No se pudo guardar el libro. Intenta de nuevo.")
                isSaving = false
            }
        }
    }
    
    func updateCover(url: URL) {
        coverURL = url
    }


    private func buildBook() -> Book {
        let bookId: UUID
        switch mode {
        case .add, .addWithInitialData:
            bookId = UUID()
        case .edit(let existing):
            bookId = existing.id
        }

        let titleValue = title.trimmingCharacters(in: .whitespacesAndNewlines)

        let authors = parseAuthors(from: authorsText)
        let publisher: Publisher? = publisherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil
            : Publisher(id: UUID(), name: publisherName.trimmingCharacters(in: .whitespacesAndNewlines))

        let numberOfPages = Int(pagesText.trimmingCharacters(in: .whitespacesAndNewlines))

        let isbnValue = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalIsbn = isbnValue.isEmpty ? "SIN-ISBN" : isbnValue

        let subtitleValue = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalSubtitle = subtitleValue.isEmpty ? nil : subtitleValue

        let descriptionValue = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = descriptionValue.isEmpty ? nil : descriptionValue

        let pageTrimmed = currentPageText.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentPageParsed: Int? = pageTrimmed.isEmpty ? nil : Int(pageTrimmed)

        return Book(
            id: bookId,
            isbn: finalIsbn,
            authors: authors,
            title: titleValue,
            numberOfPages: numberOfPages,
            publisher: publisher,
            publicationDate: publicationDate,
            thumbnailURL: coverURL,
            bookDescription: finalDescription,
            subtitle: finalSubtitle,
            language: language.isEmpty ? "es" : language,
            isFavorite: isFavorite,
            readingStatus: readingStatus,
            currentPage: currentPageParsed
        )
    }

    private func parseAuthors(from text: String) -> [Author] {
        let names = text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if names.isEmpty {
            return []
        }

        return names.map { name in
            Author(id: UUID(), name: name)
        }
    }
}

