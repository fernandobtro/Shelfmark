//
//  DeleteBookUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 04/03/26.
//
//  Purpose: Implements `DeleteBookUseCase` using data repositories.
//

import Foundation

/// Implements `DeleteBookUseCase` using data repositories.
final class DeleteBookUseCaseImpl: DeleteBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws {
        try await repository.delete(by: bookId)
    }
}

