//
//  Quote.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

struct Quote: Equatable, Identifiable {
    let id: UUID
    let text: String
    let bookId: UUID
    let pageReference: String?
    let createdAt: Date
}
