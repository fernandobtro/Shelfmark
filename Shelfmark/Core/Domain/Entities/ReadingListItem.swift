//
//  ReadingListItem.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

struct ReadingListItem: Equatable, Identifiable {
    let id: UUID
    let listId: UUID
    let book: Book?
    let position: Int?
    let createdAt: Date
}
