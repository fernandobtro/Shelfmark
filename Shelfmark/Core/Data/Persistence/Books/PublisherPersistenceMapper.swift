//
//  PublisherPersistenceMapper.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: SwiftData persistence component `PublisherPersistenceMapper`.
//

import Foundation

/// SwiftData persistence component `PublisherPersistenceMapper`.
enum PublisherPersistenceMapper {
    
    nonisolated static func toDomain(_ entity: PublisherEntity) -> Publisher {
        Publisher(id: entity.id, name: entity.name)
    }

    nonisolated static func toEntity(_ publisher: Publisher) -> PublisherEntity {
        PublisherEntity(id: publisher.id, name: publisher.name)
    }
}
