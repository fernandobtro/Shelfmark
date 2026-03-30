//
//  FetchBookDetailUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Implements `FetchBookDetailUseCase` using data repositories.
//

import Foundation

/// Implements `FetchBookDetailUseCase` using data repositories.
final class FetchBookDetailUseCaseImpl: FetchBookDetailUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws -> Book? {
        try await repository.fetchBook(by: bookId)
    }
}

