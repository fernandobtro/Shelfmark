//
//  TestHelpers.swift
//  ShelfmarKTests
//

import Foundation
@testable import Shelfmark

enum TestError: Error, Equatable {
    case fake
}

func makeSampleBook(id: UUID = UUID(), title: String = "Test Book") -> Book {
    Book(
        id: id,
        isbn: "978-0-00-000000-0",
        authors: [Author(id: UUID(), name: "Author")],
        title: title,
        numberOfPages: nil,
        publisher: nil,
        publicationDate: nil,
        thumbnailURL: nil,
        bookDescription: nil,
        subtitle: nil,
        language: "es",
        isFavorite: false,
        readingStatus: .none
    )
}

func makeSampleReadingList(id: UUID = UUID(), name: String = "List") -> ReadingList {
    ReadingList(
        id: id,
        name: name,
        createdAt: Date(),
        iconName: nil,
        notes: nil
    )
}
