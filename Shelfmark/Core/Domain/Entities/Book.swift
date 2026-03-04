//
//  Book.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation

struct Book {
    let id: UUID
    let isbn: String
    let author: [Author]
    let title: String
    let numberOfPages: Int?
    let publisher: Publisher
    let publicationDate: Date?
    let thumbnailURL: URL?
    let description: String?
    let subtitle: String?
    let language: String
}
