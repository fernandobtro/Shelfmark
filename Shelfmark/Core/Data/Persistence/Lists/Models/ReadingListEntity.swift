//
//  ReadingListEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: SwiftData persistence component `ReadingListEntity`.
//

import Foundation
import SwiftData

/// SwiftData persistence component `ReadingListEntity`.
@Model
class ReadingListEntity {
    @Attribute(.unique) var id: UUID
    
    var name: String
    var createdAt: Date
    var iconName: String?
    var notes: String?
    
    // Define Relationship
    @Relationship(deleteRule: .cascade)
    var items: [ReadingListItemEntity] = []
    
    init(id: UUID = UUID(), name: String, createdAt: Date, iconName: String? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.iconName = iconName
        self.notes = notes
    }
}
