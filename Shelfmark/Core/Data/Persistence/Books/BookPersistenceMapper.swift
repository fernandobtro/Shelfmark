//
//  BookPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: SwiftData persistence component `BookPersistenceMapper`.
//

import Foundation

/// SwiftData persistence component `BookPersistenceMapper`.
enum BookPersistenceMapper {
    nonisolated static func toDomain(_ entity: BookEntity) -> Book {
        let authors: [Author] = entity.authors.map(AuthorPersistenceMapper.toDomain)
        let publisher: Publisher? = entity.publisher.map(PublisherPersistenceMapper.toDomain)

        return Book(
            id: entity.id,
            isbn: entity.isbn,
            authors: authors,
            title: entity.title,
            numberOfPages: entity.numberOfPages,
            publisher: publisher,
            publicationDate: entity.publicationDate,
            thumbnailURL: entity.thumbnailURL,
            bookDescription: entity.bookDescription,
            subtitle: entity.subtitle,
            language: entity.language,
            isFavorite: entity.isFavorite,
            readingStatus: ReadingStatus(rawValue: entity.readingStatusRaw) ?? .none,
            currentPage: entity.currentPage
        )
    }

    nonisolated static func toEntity(_ book: Book) -> BookEntity {
        let authorEntities: [AuthorEntity] = book.authors.map(AuthorPersistenceMapper.toEntity)
        let publisherEntity: PublisherEntity? = book.publisher.map(PublisherPersistenceMapper.toEntity)

        return BookEntity(
            id: book.id,
            isbn: book.isbn,
            authors: authorEntities,
            title: book.title,
            numberOfPages: book.numberOfPages,
            publisher: publisherEntity,
            publicationDate: book.publicationDate,
            thumbnailURL: book.thumbnailURL,
            bookDescription: book.bookDescription,
            subtitle: book.subtitle,
            language: book.language,
            isFavorite: book.isFavorite,
            readingStatusRaw: book.readingStatus.rawValue,
            currentPage: book.currentPage
        )
    }
}
