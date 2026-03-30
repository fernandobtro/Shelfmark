//
//  AddBookToReadingListImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Implements `AddBookToReadingList` using data repositories.
//

import Foundation

/// Implements `AddBookToReadingList` using data repositories.
final class AddBookToReadingListImpl: AddBookToReadingListUseCaseProtocol {
    private let repository: ReadingListRepositoryProtocol
    
    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID, listId: UUID) async throws {
        try await repository.addBook(bookId, toList: listId)
    }
}
