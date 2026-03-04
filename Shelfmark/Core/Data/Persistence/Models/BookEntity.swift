//
//  BookEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation
import SwiftData

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
    
    init(id: UUID = UUID(), isbn: String, authors: [AuthorEntity], title: String, numberOfPages: Int? = nil, publisher: PublisherEntity? = nil, publicationDate: Date? = nil, thumbnailURL: URL? = nil, bookDescription: String? = nil, subtitle: String? = nil, language: String) {
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
    }
}
