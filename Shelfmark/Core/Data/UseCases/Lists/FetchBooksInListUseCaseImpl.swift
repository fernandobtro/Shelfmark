//
//  FetchBooksInListUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Implements `FetchBooksInListUseCase` using data repositories.
//

import Foundation

/// Implements `FetchBooksInListUseCase` using data repositories.
final class FetchBooksInListUseCaseImpl: FetchBooksInListUseCaseProtocol  {
    private let repository: ReadingListRepositoryProtocol
    
    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }
    func execute(listId: UUID) async throws -> [Book] {
        try await repository.fetchBooks(inList: listId)
    }
}
