//
//  PreviewHelpers.swift
//  Shelfmark
//
//  Datos mock solo para Previews de SwiftUI. No usar en producción.
//

import Foundation

enum PreviewHelpers {
    static let previewAuthor1 = Author(id: UUID(), name: "J.R.R. Tolkien")
    static let previewAuthor2 = Author(id: UUID(), name: "Ursula K. Le Guin")
    static let previewPublisher = Publisher(id: UUID(), name: "Minotauro")

    static var previewBook1: Book {
        Book(
            id: UUID(),
            isbn: "978-84-206-4750-0",
            authors: [previewAuthor1],
            title: "El Hobbit",
            numberOfPages: 366,
            publisher: previewPublisher,
            publicationDate: Date(),
            thumbnailURL: nil,
            bookDescription: "Un clásico de la fantasía.",
            subtitle: nil,
            language: "es",
            isFavorite: false,
            readingStatus: .none,
            currentPage: nil
        )
    }

    static var previewBook2: Book {
        Book(
            id: UUID(),
            isbn: "978-84-7223-458-5",
            authors: [previewAuthor2],
            title: "Los desposeídos",
            numberOfPages: 352,
            publisher: nil,
            publicationDate: nil,
            thumbnailURL: nil,
            bookDescription: nil,
            subtitle: "Una utopía ambigua",
            language: "es",
            isFavorite: true,
            readingStatus: .read,
            currentPage: 120
        )
    }

    static var previewBooks: [Book] { [previewBook1, previewBook2] }

    static var previewReadingList: ReadingList {
        ReadingList(id: UUID(), name: "Lecturas 2026", createdAt: Date(), iconName: nil, notes: nil)
    }

    static func previewQuote(bookId: UUID) -> Quote {
        Quote(
            id: UUID(),
            text: "No todo el que vaga anda perdido.",
            bookId: bookId,
            pageReference: "27",
            createdAt: Date()
        )
    }
}
