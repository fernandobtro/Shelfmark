//
//  ReadingListItemEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: SwiftData persistence component `ReadingListItemEntity`.
//

import Foundation
import SwiftData

/// SwiftData persistence component `ReadingListItemEntity`.
@Model
class ReadingListItemEntity {
    @Attribute(.unique) var id: UUID
    
    var listId: ReadingListEntity?
    var book: BookEntity?
    
    var position: Int?
    var createdAt: Date
    
    init(id: UUID = UUID(), position: Int? = nil, createdAt: Date = .now) {
        self.id = id
        self.position = position
        self.createdAt = createdAt
    }
}
