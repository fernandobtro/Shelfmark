//
//  SwiftDataBookRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation
import SwiftData

class SwiftDataBookRepository: BookRepositoryProtocol {
    
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(_ book: Book) async throws {
        let entity = BookPersistenceMapper.toEntity(book)

        let bookId = book.id
        let descriptor = FetchDescriptor<BookEntity>(predicate: #Predicate<BookEntity> { $0.id == bookId })
        let existing = try modelContext.fetch(descriptor)

        if let existingBook = existing.first {
            
            for authorEntity in entity.authors {
                modelContext.insert(authorEntity)
            }
            if let publisherEntity = entity.publisher {
                modelContext.insert(publisherEntity)
            }
            existingBook.isbn = entity.isbn
            existingBook.title = entity.title
            existingBook.numberOfPages = entity.numberOfPages
            existingBook.publicationDate = entity.publicationDate
            existingBook.thumbnailURL = entity.thumbnailURL
            existingBook.bookDescription = entity.bookDescription
            existingBook.subtitle = entity.subtitle
            existingBook.language = entity.language
            existingBook.authors = entity.authors
            existingBook.publisher = entity.publisher
        } else {
            
            for authorEntity in entity.authors {
                modelContext.insert(authorEntity)
            }
            if let publisherEntity = entity.publisher {
                modelContext.insert(publisherEntity)
            }
            modelContext.insert(entity)
        }

        try modelContext.save()
    }
    
    func fetchAll() async throws -> [Book] {
        let descriptor = FetchDescriptor<BookEntity>()
        let entities: [BookEntity] = try modelContext.fetch(descriptor)
        return entities.map { entity in
            BookPersistenceMapper.toDomain(entity)
        }
    }
    
    func fetchBook(by id: UUID) async throws -> Book? {
        let predicate = #Predicate<BookEntity> { $0.id == id }
        let descriptor = FetchDescriptor<BookEntity>(predicate: predicate)
        let entities: [BookEntity] = try modelContext.fetch(descriptor)
        if let entity = entities.first {
            return BookPersistenceMapper.toDomain(entity)
        } else {
            return nil
        }
    }
    
    func fetchBooks(byAuthorId id: UUID) async throws -> [Book] {
        let descriptor = FetchDescriptor<BookEntity>()
        let entities = try modelContext.fetch(descriptor)
        let filtered = entities.filter { entity in
            entity.authors.contains { $0.id == id }
        }
        return filtered.map(BookPersistenceMapper.toDomain)
    }
    
    func fetchBooks(byPublisherId id: UUID) async throws -> [Book] {
        let predicate = #Predicate<BookEntity> { entity in
            entity.publisher?.id == id
        }
        let descriptor = FetchDescriptor<BookEntity>(predicate: predicate)
        let entities: [BookEntity] = try modelContext.fetch(descriptor)
        return entities.map { BookPersistenceMapper.toDomain($0) }
    }
    
    func delete(by bookId: UUID) async throws {
        let predicate = #Predicate<BookEntity> { $0.id == bookId }
        let descriptor = FetchDescriptor<BookEntity>(predicate: predicate)
        let entities: [BookEntity] = try modelContext.fetch(descriptor)
        if let entity = entities.first {
            modelContext.delete(entity)
            try modelContext.save()
        }
    }
}

