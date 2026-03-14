//
//  ReadingListItemPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
import Foundation

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
