//
//  Quote.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain entity `Quote`.
//

import Foundation

/// Domain entity `Quote`.
struct Quote: Equatable, Identifiable {
    let id: UUID
    let text: String
    let bookId: UUID
    let pageReference: String?
    let createdAt: Date
}
