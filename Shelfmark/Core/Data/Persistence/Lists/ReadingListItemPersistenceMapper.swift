//
//  ReadingListItemPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: SwiftData persistence component `ReadingListItemPersistenceMapper`.
//
import Foundation

/// SwiftData persistence component `ReadingListItemPersistenceMapper`.
enum ReadingListItemPersistenceMapper {
    nonisolated static func toDomain(_ entity: ReadingListItemEntity) -> ReadingListItem {
        let bookDomain = entity.book.map(BookPersistenceMapper.toDomain)

        return ReadingListItem(
            id: entity.id,
            listId: entity.listId?.id ?? UUID(),
            book: bookDomain,
            position: entity.position,
            createdAt: entity.createdAt
        )
    }
}
