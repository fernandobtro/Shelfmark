//
//  QuoteEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: SwiftData persistence component `QuoteEntity`.
//

import Foundation
import SwiftData

/// SwiftData persistence component `QuoteEntity`.
@Model
class QuoteEntity {
    @Attribute(.unique) var id: UUID
    var text: String
    var bookId: UUID
    var pageReference: String?
    var createdAt: Date
    
    init(id: UUID = UUID(), text: String, bookId: UUID, pageReference: String? = nil, createdAt: Date) {
        self.id = id
        self.text = text
        self.bookId = bookId
        self.pageReference = pageReference
        self.createdAt = createdAt
    }
}
