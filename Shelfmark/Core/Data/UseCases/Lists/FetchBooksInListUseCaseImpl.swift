//
//  FetchBooksInListUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//

import Foundation

final class FetchBooksInListUseCaseImpl: FetchBooksInListUseCaseProtocol  {
    private let repository: ReadingListRepositoryProtocol
    
    init(repository: ReadingListRepositoryProtocol) {
        self.repository = repository
    }
    func execute(listId: UUID) async throws -> [Book] {
        try await repository.fetchBooks(inList: listId)
    }
}
