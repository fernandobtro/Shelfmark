//
//  ReadingListPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

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
