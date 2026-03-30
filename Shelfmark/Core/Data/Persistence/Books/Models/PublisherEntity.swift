//
//  PublisherEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: SwiftData persistence component `PublisherEntity`.
//

import Foundation
import SwiftData

/// SwiftData persistence component `PublisherEntity`.
@Model
class PublisherEntity {
    @Attribute(.unique) var id: UUID
    
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
