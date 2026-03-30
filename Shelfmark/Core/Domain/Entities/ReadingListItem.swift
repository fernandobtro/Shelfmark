//
//  ReadingListItem.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Domain entity `ReadingListItem`.
//

import Foundation

/// Domain entity `ReadingListItem`.
struct ReadingListItem: Equatable, Identifiable {
    let id: UUID
    let listId: UUID
    let book: Book?
    let position: Int?
    let createdAt: Date
}
