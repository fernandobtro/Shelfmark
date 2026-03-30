//
//  SwiftDataBookRepository.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: SwiftData-backed repository implementation for domain book reads and writes.
//

import Foundation
import SwiftData

/// Persists and queries book aggregates using SwiftData entities and mappers.
class SwiftDataBookRepository: BookRepositoryProtocol {
    
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(_ book: Book) async throws {
        let bookId = book.id
        let descriptor = FetchDescriptor<BookEntity>(predicate: #Predicate<BookEntity> { $0.id == bookId })
        let existing = try modelContext.fetch(descriptor)
        let authors = try resolveAuthorEntities(from: book.authors)
        let publisher = try resolvePublisherEntity(from: book.publisher)

        if let existingBook = existing.first {
            apply(book: book, to: existingBook, authors: authors, publisher: publisher)
        } else {
            let newBook = BookEntity(
                id: book.id,
                isbn: book.isbn,
                authors: authors,
                title: book.title,
                numberOfPages: book.numberOfPages,
                publisher: publisher,
                publicationDate: book.publicationDate,
                thumbnailURL: book.thumbnailURL,
                bookDescription: book.bookDescription,
                subtitle: book.subtitle,
                language: book.language,
                isFavorite: book.isFavorite,
                readingStatusRaw: book.readingStatus.rawValue,
                currentPage: book.currentPage
            )
            modelContext.insert(newBook)
        }

        try modelContext.save()
    }

    private func apply(book: Book, to entity: BookEntity, authors: [AuthorEntity], publisher: PublisherEntity?) {
        entity.isbn = book.isbn
        entity.title = book.title
        entity.numberOfPages = book.numberOfPages
        entity.publicationDate = book.publicationDate
        entity.thumbnailURL = book.thumbnailURL
        entity.bookDescription = book.bookDescription
        entity.subtitle = book.subtitle
        entity.language = book.language
        entity.authors = authors
        entity.publisher = publisher
        entity.isFavorite = book.isFavorite
        entity.readingStatusRaw = book.readingStatus.rawValue
        entity.currentPage = book.currentPage
    }

    private func resolveAuthorEntities(from authors: [Author]) throws -> [AuthorEntity] {
        var resolved: [AuthorEntity] = []
        for author in authors {
            let authorId = author.id
            let descriptor = FetchDescriptor<AuthorEntity>(
                predicate: #Predicate<AuthorEntity> { $0.id == authorId }
            )
            if let existing = try modelContext.fetch(descriptor).first {
                // If the name changed, update it to keep data consistent.
                if existing.name != author.name {
                    existing.name = author.name
                }
                resolved.append(existing)
            } else {
                let entity = AuthorEntity(id: author.id, name: author.name)
                modelContext.insert(entity)
                resolved.append(entity)
            }
        }
        return resolved
    }

    private func resolvePublisherEntity(from publisher: Publisher?) throws -> PublisherEntity? {
        guard let publisher else { return nil }
        let publisherId = publisher.id
        let descriptor = FetchDescriptor<PublisherEntity>(
            predicate: #Predicate<PublisherEntity> { $0.id == publisherId }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            if existing.name != publisher.name {
                existing.name = publisher.name
            }
            return existing
        } else {
            let entity = PublisherEntity(id: publisher.id, name: publisher.name)
            modelContext.insert(entity)
            return entity
        }
    }
    
    func fetchAll() async throws -> [Book] {
        let descriptor = FetchDescriptor<BookEntity>()
        let entities: [BookEntity] = try modelContext.fetch(descriptor)
        return entities.map { entity in
            BookPersistenceMapper.toDomain(entity)
        }
    }
    
    func fetchPaginated(limit: Int, offset: Int) async throws -> [Book] {
        var descriptor = FetchDescriptor<BookEntity>()
        
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        
        descriptor.sortBy = [SortDescriptor(\.title, order: .forward)]
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { BookPersistenceMapper.toDomain($0) }
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
