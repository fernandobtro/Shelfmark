//
//  AuthorPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: SwiftData persistence component `AuthorPersistenceMapper`.
//

import Foundation

/// SwiftData persistence component `AuthorPersistenceMapper`.
enum AuthorPersistenceMapper {

    nonisolated static func toDomain(_ entity: AuthorEntity) -> Author {
        Author(id: entity.id, name: entity.name)
    }

    nonisolated static func toEntity(_ author: Author) -> AuthorEntity {
        AuthorEntity(id: author.id, name: author.name)
    }
}
