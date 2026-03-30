//
//  ReadingListPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: SwiftData persistence component `ReadingListPersistenceMapper`.
//

import Foundation

/// SwiftData persistence component `ReadingListPersistenceMapper`.
enum ReadingListPersistenceMapper {
    nonisolated static func toDomain(_ entity: ReadingListEntity) -> ReadingList {
        ReadingList(
            id: entity.id,
            name: entity.name,
            createdAt: entity.createdAt,
            iconName: entity.iconName,
            notes: entity.notes
        )
    }
}
