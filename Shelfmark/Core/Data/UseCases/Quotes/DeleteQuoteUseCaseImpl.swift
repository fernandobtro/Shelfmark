//
//  DeleteQuoteUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Implements `DeleteQuoteUseCase` using data repositories.
//

import Foundation

/// Implements `DeleteQuoteUseCase` using data repositories.
final class DeleteQuoteUseCaseImpl: DeleteQuoteUseCaseProtocol {
    
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quoteId: UUID) async throws {
        try await repository.delete(by: quoteId)
    }
}
