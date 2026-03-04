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
}
