//
//  ReadingList.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain entity `ReadingList`.
//

import Foundation

/// User-defined reading list metadata.
/// Domain layer stores list metadata only, list books are loaded separately.
struct ReadingList: Equatable, Identifiable {
    let id: UUID
    var name: String
    let createdAt: Date
    var iconName: String?
    var notes: String?
}
