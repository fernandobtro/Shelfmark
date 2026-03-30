//
//  SwiftDataQuoteRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: SwiftData-backed repository implementation for quote persistence operations.
//

import Foundation
import SwiftData

/// Persists quote entities and maps them into domain quote models.
class SwiftDataQuoteRepository: QuoteRepositoryProtocol {
    
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [Quote] {
        let descriptor = FetchDescriptor<QuoteEntity>()
        let entities = try modelContext.fetch(descriptor)
        return entities.map { QuotePersistenceMapper.toDomain($0) }
    }

    func fetchPaginated(limit: Int, offset: Int) async throws -> [Quote] {
        var descriptor = FetchDescriptor<QuoteEntity>()
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        let entities = try modelContext.fetch(descriptor)
        return entities.map { QuotePersistenceMapper.toDomain($0) }
    }

    func fetch(by id: UUID) async throws -> Quote? {
        let predicate = #Predicate<QuoteEntity> { $0.id == id }
        let descriptor = FetchDescriptor<QuoteEntity>(predicate: predicate)
        let entities: [QuoteEntity] = try modelContext.fetch(descriptor)
        
        if let entity = entities.first {
            return QuotePersistenceMapper.toDomain(entity)
        } else {
            return nil
        }
    }
    
    func save(_ quote: Quote) async throws {
        let entity = QuotePersistenceMapper.toEntity(quote)
        let quoteId = quote.id
        
        let descriptor = FetchDescriptor<QuoteEntity>(predicate: #Predicate<QuoteEntity> { $0.id == quoteId })
        let existing = try modelContext.fetch(descriptor)
        
        if let existingQuote = existing.first {
            existingQuote.text = entity.text
            existingQuote.bookId = entity.bookId
            existingQuote.pageReference = entity.pageReference
        } else {
            modelContext.insert(entity)
        }
        
        try modelContext.save()
        
    }
    
    func delete(by quoteId: UUID) async throws {
        let predicate = #Predicate<QuoteEntity> { $0.id == quoteId }
        let descriptor = FetchDescriptor<QuoteEntity>(predicate: predicate)
        let entities: [QuoteEntity] = try modelContext.fetch(descriptor)
        if let entity = entities.first {
            modelContext.delete(entity)
            try modelContext.save()
        }
    }
    
    
}
