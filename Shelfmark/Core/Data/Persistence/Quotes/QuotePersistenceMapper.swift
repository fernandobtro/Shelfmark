//
//  QuoteMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

enum QuotePersistenceMapper {
    nonisolated static func toDomain(_ entity: QuoteEntity) -> Quote {
        Quote(id: entity.id, text: entity.text, bookId: entity.bookId, pageReference: entity.pageReference, createdAt: entity.createdAt)
    }
    
    nonisolated static func toEntity(_ quote: Quote) -> QuoteEntity {
        QuoteEntity(
            id: quote.id,
            text: quote.text,
            bookId: quote.bookId,
            pageReference: quote.pageReference,
            createdAt: quote.createdAt
        )
    }
}
