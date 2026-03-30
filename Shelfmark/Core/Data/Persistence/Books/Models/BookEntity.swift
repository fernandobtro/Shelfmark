//
//  BookEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: SwiftData persistence component `BookEntity`.
//

import Foundation
import SwiftData

/// SwiftData persistence component `BookEntity`.
@Model
class BookEntity {
    @Attribute(.unique) var id: UUID
    
    var isbn: String
    var authors: [AuthorEntity]
    var title: String
    var numberOfPages: Int?
    var publisher: PublisherEntity?
    var publicationDate: Date?
    var thumbnailURL: URL?
    var bookDescription: String?
    var subtitle: String?
    var language: String
    var isFavorite: Bool
    /// SwiftData does not persist enums directly so store domain `ReadingStatus` raw value.
    var readingStatusRaw: String
    var currentPage: Int?

    init(id: UUID = UUID(), isbn: String, authors: [AuthorEntity], title: String, numberOfPages: Int? = nil, publisher: PublisherEntity? = nil, publicationDate: Date? = nil, thumbnailURL: URL? = nil, bookDescription: String? = nil, subtitle: String? = nil, language: String, isFavorite: Bool = false, readingStatusRaw: String = "none", currentPage: Int? = nil) {
        self.id = id
        self.isbn = isbn
        self.authors = authors
        self.title = title
        self.numberOfPages = numberOfPages
        self.publisher = publisher
        self.publicationDate = publicationDate
        self.thumbnailURL = thumbnailURL
        self.bookDescription = bookDescription
        self.subtitle = subtitle
        self.language = language
        self.isFavorite = isFavorite
        self.readingStatusRaw = readingStatusRaw
        self.currentPage = currentPage
    }
}
