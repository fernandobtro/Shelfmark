//
//  SaveQuoteUseCaseImpl.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 13/03/26.
//
//  Purpose: Implements `SaveQuoteUseCase` using data repositories.
//

import Foundation

/// Implements `SaveQuoteUseCase` using data repositories.
final class SaveQuoteUseCaseImpl: SaveQuoteUseCaseProtocol {
    
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quote: Quote) async throws {
        try await repository.save(quote)
    }
}
