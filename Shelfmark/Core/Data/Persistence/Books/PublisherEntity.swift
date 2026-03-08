//
//  PublisherEntity.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//

import Foundation
import SwiftData

@Model
class PublisherEntity {
    @Attribute(.unique) var id: UUID
    
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
