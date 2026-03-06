//
//  Book.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

struct Book: Equatable {
    let id: UUID
    let isbn: String
    let authors: [Author]
    let title: String
    let numberOfPages: Int?
    let publisher: Publisher?
    let publicationDate: Date?
    let thumbnailURL: URL?
    let bookDescription: String?
    let subtitle: String?
    let language: String
    let isFavorite: Bool
    let readingStatus: ReadingStatus
}

/// SwiftData no persiste enums personalizados. Usamos String como rawValue para guardar en BookEntity.
enum ReadingStatus: String {
    case pending = "pending"
    case reading = "reading"
    case read = "read"
    case none = "none"
}
