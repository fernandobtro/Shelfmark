//
//  RemoveBookFromReadingListUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Implements `RemoveBookFromReadingListUseCase` using data repositories.
//

import Foundation

/// Implements `RemoveBookFromReadingListUseCase` using data repositories.
final class RemoveBookFromReadingListUseCaseImpl: RemoveBookFromReadingListUseCaseProtocol {
    
    private let repository: ReadingListRepositoryProtocol
    
    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID, listId: UUID) async throws {
        try await repository.removeBook(bookId, fromList: listId)
    }
}
